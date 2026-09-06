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
    implicitHeight: 440
    color: "transparent"
    visible: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-launcher"

    property string query: ""

    // Controle via IPC — usado pelo bind do Hyprland
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
    // (ex: "vsc" ou "vs c" casam com "Visual Studio Code").
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
    ScriptModel {
        id: filteredModel
        values: {
            const q = root.query.toLowerCase().trim()
            const all = [...DesktopEntries.applications.values]
            let filtered = all.filter(a => !a.noDisplay && root.appMatches(a, q))
            filtered.sort((a, b) => {
                const pa = PinStore.isPinned(a.id) ? 0 : 1
                const pb = PinStore.isPinned(b.id) ? 0 : 1
                if (pa !== pb) return pa - pb
                return a.name.localeCompare(b.name)
            })
            return filtered
        }
    }

    function launchCurrent() {
        if (list.currentItem) {
            list.currentItem.entry.execute()
            root.requestClose()
        }
    }

    // Toca a animação de saída e só então esconde ou encerra de fato.
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
            entranceAnim.restart()
            searchField.forceActiveFocus()
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0
        scale: 0.96
        transformOrigin: Item.Center

        ParallelAnimation {
            id: entranceAnim
            NumberAnimation { target: content; property: "opacity"; from: 0; to: 1; duration: Theme.animMedium; easing.type: Easing.OutCubic }
            NumberAnimation { target: content; property: "scale"; from: 0.96; to: 1; duration: Theme.animMedium; easing.type: Easing.OutCubic }
        }

        ParallelAnimation {
            id: exitAnim
            property var action: null
            NumberAnimation { target: content; property: "opacity"; to: 0; duration: Theme.animFast; easing.type: Easing.InCubic }
            NumberAnimation { target: content; property: "scale"; to: 0.96; duration: Theme.animFast; easing.type: Easing.InCubic }
            onFinished: if (action) { action(); action = null }
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.radiusWindow
            color: Theme.background
            border.width: 1
            border.color: Theme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Campo de busca
                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: Theme.radiusItem
                    color: Theme.surface
                    border.width: searchField.activeFocus ? 1 : 0
                    border.color: Theme.accent

                    Behavior on border.width { NumberAnimation { duration: Theme.animFast } }

                    TextInput {
                        id: searchField
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
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

                    add: Transition {
                        NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: Theme.animMedium }
                    }
                    displaced: Transition {
                        NumberAnimation { properties: "y"; duration: Theme.animMedium; easing.type: Easing.OutCubic }
                    }

                    highlight: Rectangle {
                        radius: Theme.radiusItem
                        color: Theme.surfaceHover
                        border.width: 1
                        border.color: Theme.accent
                    }

                    delegate: AppEntry {
                        width: list.width
                        entry: modelData
                        onClicked: {
                            list.currentIndex = index
                            root.launchCurrent()
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }
            }
        }
    }
}
