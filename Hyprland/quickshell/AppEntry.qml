import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var entry
    signal clicked()

    height: 52
    radius: Theme.radiusItem
    color: hoverArea.containsMouse ? Theme.surfaceHover : "transparent"

    Behavior on color {
        ColorAnimation { duration: Theme.animFast }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        z: -1
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 12

        // Ícone, com fallback (letra) caso o tema de ícones não tenha um match
        Item {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32

            IconImage {
                id: icon
                anchors.fill: parent
                source: root.entry && root.entry.icon ? Quickshell.iconPath(root.entry.icon, "") : ""
                visible: status === Image.Ready
            }

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusSmall
                visible: icon.status !== Image.Ready
                color: Theme.accent

                Text {
                    anchors.centerIn: parent
                    text: root.entry && root.entry.name ? root.entry.name.charAt(0).toUpperCase() : "?"
                    color: Theme.textPrimary
                    font.bold: true
                    font.pixelSize: 14
                }
            }
        }

        // Nome + descrição curta (genericName)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.entry ? root.entry.name : ""
                color: Theme.textPrimary
                font.pixelSize: Theme.fontSizeItem
                font.family: Theme.fontFamily
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: root.entry && !!root.entry.genericName
                text: root.entry ? root.entry.genericName : ""
                color: Theme.textSecondary
                font.pixelSize: Theme.fontSizeHint
                font.family: Theme.fontFamily
                elide: Text.ElideRight
            }
        }

        // Botão de fixar
        Text {
            text: root.entry && PinStore.isPinned(root.entry.id) ? "\u2605" : "\u2606"
            color: root.entry && PinStore.isPinned(root.entry.id) ? Theme.pinnedIndicator : Theme.textSecondary
            font.pixelSize: 18

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                onClicked: {
                    if (root.entry) PinStore.toggle(root.entry.id)
                }
            }
        }
    }
}
