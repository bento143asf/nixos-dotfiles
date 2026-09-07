import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

PanelWindow {
    id: root

    // Sem anchors definidos -> o compositor centraliza a superfície na tela
    implicitWidth: 600
    implicitHeight: 460
    color: "transparent"
    visible: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-launcher"

    property string query: ""

    IpcHandler {
        target: "launcher"
        function toggle() {
            if (root.visible) root.requestClose()
            else root.visible = true
        }
        function open() { root.visible = true }
        function close() { root.requestClose() }
    }

    // Retorna true se o app "combina" com a busca: substring no nome/descrição/
    // palavras-chave/id, OU as iniciais das palavras do nome começam com a busca
    // (ex: "vsc" ou "vs" casam com "Visual Studio Code").
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

    // ScriptModel evita recriar todos os delegates a cada tecla digitada,
    // o que mantém as animações de entrada/saída da lista funcionando.
    // Ordem final: fixados primeiro (A-Z), depois TODOS os outros apps (A-Z) —
    // nunca oculta quem não está fixado.
    ScriptModel {
        id: filteredModel
        onValuesChanged: list.positionViewAtBeginning()
        values: {
            const q = root.query.toLowerCase().trim()
            const all = [...DesktopEntries.applications.values]
            const visible = all.filter(a => !a.noDisplay && root.appMatches(a, q))

            const pinned = visible.filter(a => PinStore.isPinned(a.id))
                                   .sort((a, b) => a.name.localeCompare(b.name))
            const rest = visible.filter(a => !PinStore.isPinned(a.id))
                                 .sort((a, b) => a.name.localeCompare(b.name))

            return pinned.concat(rest)
        }
    }

    function launchCurrent() {
        if (list.currentItem) {
            list.currentItem.entry.execute()
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
            list.currentIndex = 0
            list.positionViewAtBeginning()
            entranceAnim.restart()
            searchField.forceActiveFocus()
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0
        scale: 0.94
        transformOrigin: Item.Center
        y: visible ? 0 : -8

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

        // Corpo principal: fundo em degradê translúcido (85% sólido) + borda com brilho azul
        Rectangle {
            id: panel
            anchors.fill: parent
            radius: Theme.radiusWindow
            border.width: 1.5
            border.color: Theme.withAlpha(Theme.accent, 0.45)

            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Theme.withAlpha(Theme.surface, Theme.windowOpacity) }
                GradientStop { position: 1.0; color: Theme.withAlpha(Theme.backgroundDeep, Theme.windowOpacity) }
            }

            // Friso superior sutil, dá sensação de "vidro"
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 1.5
                height: parent.height * 0.4
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
                spacing: 14

                // Campo de busca
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

                        // Lupa desenhada com formas simples (sem depender de fonte de ícones)
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

                            onTextChanged: root.query = text

                            Keys.onDownPressed: list.incrementCurrentIndex()
                            Keys.onUpPressed: list.decrementCurrentIndex()
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

                // Lista de resultados
                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    model: filteredModel
                    currentIndex: 0

                    highlightMoveDuration: Theme.animFast
                    highlightResizeDuration: Theme.animFast
                    highlightFollowsCurrentItem: true
                    boundsBehavior: Flickable.DragAndOvershootBounds
                    flickDeceleration: 1500
                    maximumFlickVelocity: 2500

                    add: Transition {
                        NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: Theme.animMedium }
                        NumberAnimation { properties: "x"; from: -16; to: 0; duration: Theme.animMedium; easing.type: Theme.easeOut }
                    }
                    remove: Transition {
                        NumberAnimation { properties: "opacity"; to: 0; duration: Theme.animFast }
                    }
                    displaced: Transition {
                        NumberAnimation { properties: "y"; duration: Theme.animMedium; easing.type: Theme.easeOut }
                    }

                    highlight: Rectangle {
                        radius: Theme.radiusItem
                        color: Theme.withAlpha(Theme.accent, 0.16)
                        border.width: 1.5
                        border.color: Theme.accent

                        Behavior on y { NumberAnimation { duration: Theme.animFast; easing.type: Theme.easeOut } }
                    }

                    delegate: AppEntry {
                        width: list.width
                        entry: modelData
                        onClicked: {
                            list.currentIndex = index
                            root.launchCurrent()
                        }
                    }

                    // Estado vazio, útil se a busca não achar nada
                    Text {
                        anchors.centerIn: parent
                        visible: list.count === 0
                        text: "Nenhum aplicativo encontrado"
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontSizeItem
                        font.family: Theme.fontFamily
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
