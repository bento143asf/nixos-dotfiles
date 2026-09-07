import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

PanelWindow {
    id: root

    // Sem anchors definidos -> o compositor centraliza a superfície na tela
    implicitWidth: 640
    implicitHeight: 540
    color: "transparent"
    visible: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-launcher"

    property string query: ""

    // "pinned" ou "apps" + índice dentro daquela lista — essa é a única fonte
    // de verdade sobre qual item está selecionado via teclado.
    property string selectedSection: "apps"
    property int selectedIndex: 0

    IpcHandler {
        target: "launcher"
        function toggle() {
            if (root.visible) root.requestClose()
            else root.visible = true
        }
        function open() { root.visible = true }
        function close() { root.requestClose() }
    }

    function appMatches(app, q) {
        if (!q) return true
        const name = app.name.toLowerCase()
        const haystack = [
            name,
            app.genericName,
            app.comment,
            app.id,
            ...(app.keywords || [])
        ].filter(Boolean).join(" ").toLowerCase()

        if (haystack.includes(q)) return true

        const initials = name.split(/\s+/).map(w => w.charAt(0)).join("")
        return initials.length > 0 && initials.startsWith(q.replace(/\s+/g, ""))
    }

    // Cada lista filtra e ordena de forma independente e explícita (sem
    // depender de uma função auxiliar compartilhada), pra garantir que o
    // motor do QML sempre recalcule as duas quando query/pinned mudarem.
    property var pinnedAppsList: {
        const q = root.query.toLowerCase().trim()
        const all = [...DesktopEntries.applications.values]
        return all
            .filter(a => !a.noDisplay && root.appMatches(a, q) && PinStore.isPinned(a.id))
            .sort((a, b) => a.name.localeCompare(b.name))
    }

    property var restAppsList: {
        const q = root.query.toLowerCase().trim()
        const all = [...DesktopEntries.applications.values]
        return all
            .filter(a => !a.noDisplay && root.appMatches(a, q) && !PinStore.isPinned(a.id))
            .sort((a, b) => a.name.localeCompare(b.name))
    }

    // Se um pin for alternado (ex: clicando na estrela), a composição das
    // duas listas muda sem a busca mudar — garante que a seleção continue
    // dentro dos limites válidos.
    Connections {
        target: PinStore
        function onPinnedChanged() { root.resetSelection() }
    }

    function currentEntry() {
        if (root.selectedSection === "pinned") return root.pinnedAppsList[root.selectedIndex]
        return root.restAppsList[root.selectedIndex]
    }

    function resetSelection() {
        root.selectedSection = root.pinnedAppsList.length > 0 ? "pinned" : "apps"
        root.selectedIndex = 0
    }

    function moveDown() {
        if (root.selectedSection === "pinned") {
            const next = root.selectedIndex + 2
            if (next < root.pinnedAppsList.length) { root.selectedIndex = next; return }
            if (root.restAppsList.length > 0) { root.selectedSection = "apps"; root.selectedIndex = 0 }
            return
        }
        if (root.selectedIndex + 1 < root.restAppsList.length) root.selectedIndex += 1
    }

    function moveUp() {
        if (root.selectedSection === "apps") {
            if (root.selectedIndex > 0) { root.selectedIndex -= 1; return }
            if (root.pinnedAppsList.length > 0) {
                root.selectedSection = "pinned"
                root.selectedIndex = root.pinnedAppsList.length - 1
            }
            return
        }
        if (root.selectedIndex - 2 >= 0) root.selectedIndex -= 2
    }

    function scrollToSelected() {
        let target = root.selectedSection === "pinned"
            ? pinnedRepeater.itemAt(root.selectedIndex)
            : appsRepeater.itemAt(root.selectedIndex)
        if (!target) return

        const pos = target.mapToItem(mainColumn, 0, 0)
        const top = pos.y
        const bottom = top + target.height

        let newY = null
        if (top < scrollArea.contentY) newY = top
        else if (bottom > scrollArea.contentY + scrollArea.height) newY = bottom - scrollArea.height

        if (newY !== null) {
            scrollAnim.to = Math.max(0, newY)
            scrollAnim.restart()
        }
    }

    function launchCurrent() {
        const entry = root.currentEntry()
        if (entry) {
            entry.execute()
            root.requestClose()
        }
    }

    function requestClose() {
        exitAnim.action = () => { root.visible = false }
        exitAnim.restart()
    }

    function requestQuit() {
        exitAnim.action = () => { Qt.quit() }
        exitAnim.restart()
    }

    onVisibleChanged: {
        if (visible) {
            query = ""
            resetSelection()
            scrollArea.contentY = 0
            entranceAnim.restart()
            searchField.forceActiveFocus()
        }
    }

    NumberAnimation {
        id: scrollAnim
        target: scrollArea
        property: "contentY"
        duration: Theme.animFast
        easing.type: Theme.easeOut
    }

    // ---- Janela: entrada/saída (única animação de posição do arquivo,
    // e ela vive FORA de qualquer Layout — por isso é segura) ----
    Item {
        id: content
        anchors.fill: parent
        opacity: 0
        scale: 0.94
        transformOrigin: Item.Center
        y: -8

        ParallelAnimation {
            id: entranceAnim
            NumberAnimation { target: content; property: "opacity"; from: 0; to: 1; duration: Theme.animMedium; easing.type: Theme.easeOut }
            NumberAnimation { target: content; property: "scale"; from: 0.94; to: 1; duration: Theme.animMedium; easing.type: Theme.easeBounce }
            NumberAnimation { target: content; property: "y"; from: -14; to: 0; duration: Theme.animMedium; easing.type: Theme.easeOut }
        }

        ParallelAnimation {
            id: exitAnim
            property var action: null
            NumberAnimation { target: content; property: "opacity"; to: 0; duration: Theme.animFast; easing.type: Theme.easeIn }
            NumberAnimation { target: content; property: "scale"; to: 0.94; duration: Theme.animFast; easing.type: Theme.easeIn }
            NumberAnimation { target: content; property: "y"; to: -14; duration: Theme.animFast; easing.type: Theme.easeIn }
            onFinished: if (action) { action(); action = null }
        }

        Rectangle {
            id: panel
            anchors.fill: parent
            radius: Theme.radiusWindow
            border.width: 1.5

            // Brilho "respirando" na borda — anima só a cor, nunca posição,
            // então não tem como isso conflitar com nada.
            property real borderGlow: 0.45
            border.color: Theme.withAlpha(Theme.accent, borderGlow)
            SequentialAnimation on borderGlow {
                loops: Animation.Infinite
                NumberAnimation { to: 0.75; duration: 1900; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.45; duration: 1900; easing.type: Easing.InOutSine }
            }

            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Theme.withAlpha(Theme.surface, Theme.windowOpacity) }
                GradientStop { position: 0.55; color: Theme.withAlpha(Qt.darker(Theme.surface, 1.15), Theme.windowOpacity) }
                GradientStop { position: 1.0; color: Theme.withAlpha(Theme.backgroundDeep, Theme.windowOpacity) }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 1.5
                height: parent.height * 0.35
                radius: Theme.radiusWindow
                color: "transparent"
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.withAlpha(Theme.nixBlueLight, 0.08) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                // ---- Caixa: Pesquisar ----
                Rectangle {
                    Layout.fillWidth: true
                    height: 46
                    radius: Theme.radiusItem
                    color: Theme.withAlpha(Theme.backgroundDeep, 0.55)
                    border.width: searchField.activeFocus ? 1.5 : 1
                    border.color: searchField.activeFocus ? Theme.accent : Theme.withAlpha(Theme.border, 0.4)

                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                    Behavior on border.width { NumberAnimation { duration: Theme.animFast } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        Item {
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            Rectangle {
                                width: 11
                                height: 11
                                radius: 6
                                color: "transparent"
                                border.width: 2
                                border.color: searchField.activeFocus ? Theme.accent : Theme.textSecondary
                                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                            }
                            Rectangle {
                                width: 2
                                height: 7
                                radius: 1
                                rotation: 45
                                x: 10
                                y: 10
                                color: searchField.activeFocus ? Theme.accent : Theme.textSecondary
                                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            }
                        }

                        TextInput {
                            id: searchField
                            Layout.fillWidth: true
                            verticalAlignment: TextInput.AlignVCenter
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontSizeInput
                            font.family: Theme.fontFamily
                            focus: true
                            clip: true

                            onTextChanged: {
                                root.query = text
                                root.resetSelection()
                                scrollArea.contentY = 0
                            }

                            Keys.onDownPressed: { root.moveDown(); root.scrollToSelected() }
                            Keys.onUpPressed: { root.moveUp(); root.scrollToSelected() }
                            Keys.onReturnPressed: root.launchCurrent()
                            Keys.onEnterPressed: root.launchCurrent()
                            Keys.onEscapePressed: root.requestQuit()

                            Text {
                                visible: searchField.text.length === 0
                                text: "Buscar aplicativo..."
                                color: Theme.textSecondary
                                font: searchField.font
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // ---- Área rolável com as caixas de Fixados e Apps ----
                Flickable {
                    id: scrollArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    boundsBehavior: Flickable.DragAndOvershootBounds
                    flickDeceleration: 1500
                    maximumFlickVelocity: 2500
                    contentWidth: width
                    contentHeight: mainColumn.implicitHeight

                    ColumnLayout {
                        id: mainColumn
                        width: scrollArea.width
                        spacing: 10

                        // ---- Caixa: Fixados (grade de pílulas, 2 colunas) ----
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: pinnedBox.implicitHeight + 20
                            visible: root.pinnedAppsList.length > 0
                            radius: Theme.radiusItem
                            color: Theme.withAlpha(Theme.backgroundDeep, 0.35)
                            border.width: 1
                            border.color: Theme.withAlpha(Theme.accent, 0.2)

                            ColumnLayout {
                                id: pinnedBox
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    Text {
                                        text: "FIXADOS"
                                        color: Theme.accent
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.letterSpacing: 1.5
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 1
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0.0; color: Theme.withAlpha(Theme.accent, 0.5) }
                                            GradientStop { position: 1.0; color: "transparent" }
                                        }
                                    }
                                }

                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2
                                    columnSpacing: 8
                                    rowSpacing: 8

                                    Repeater {
                                        id: pinnedRepeater
                                        model: root.pinnedAppsList
                                        delegate: AppEntry {
                                            Layout.fillWidth: true
                                            compact: true
                                            entry: modelData
                                            selected: root.selectedSection === "pinned" && index === root.selectedIndex
                                            onClicked: {
                                                root.selectedSection = "pinned"
                                                root.selectedIndex = index
                                                root.launchCurrent()
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // ---- Caixa: Apps ----
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: appsBox.implicitHeight + 20
                            visible: root.restAppsList.length > 0
                            radius: Theme.radiusItem
                            color: Theme.withAlpha(Theme.backgroundDeep, 0.35)
                            border.width: 1
                            border.color: Theme.withAlpha(Theme.accent, 0.2)

                            ColumnLayout {
                                id: appsBox
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    Text {
                                        text: "APPS"
                                        color: Theme.accent
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.letterSpacing: 1.5
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 1
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0.0; color: Theme.withAlpha(Theme.accent, 0.5) }
                                            GradientStop { position: 1.0; color: "transparent" }
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Repeater {
                                        id: appsRepeater
                                        model: root.restAppsList
                                        delegate: AppEntry {
                                            Layout.fillWidth: true
                                            entry: modelData
                                            selected: root.selectedSection === "apps" && index === root.selectedIndex
                                            onClicked: {
                                                root.selectedSection = "apps"
                                                root.selectedIndex = index
                                                root.launchCurrent()
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.topMargin: 24
                            horizontalAlignment: Text.AlignHCenter
                            visible: root.pinnedAppsList.length === 0 && root.restAppsList.length === 0
                            text: "Nenhum aplicativo encontrado"
                            color: Theme.textSecondary
                            font.pixelSize: Theme.fontSizeItem
                            font.family: Theme.fontFamily
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            implicitWidth: 4
                            radius: 2
                            color: Theme.withAlpha(Theme.accent, 0.5)
                        }
                    }
                }
            }
        }
    }
}
