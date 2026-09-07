import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var entry
    signal clicked()

    height: 54
    radius: Theme.radiusItem
    color: hoverArea.containsMouse ? Theme.surfaceHover : "transparent"
    border.width: hoverArea.containsMouse ? 1 : 0
    border.color: Theme.withAlpha(Theme.accent, 0.35)

    scale: hoverArea.containsMouse ? 1.015 : 1.0
    transformOrigin: Item.Center

    Behavior on color { ColorAnimation { duration: Theme.animFast } }
    Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Theme.easeOut } }
    Behavior on border.width { NumberAnimation { duration: Theme.animFast } }

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

        // Ícone com anel sutil e fallback (letra) caso o tema não tenha um match
        Item {
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusSmall
                color: Theme.withAlpha(Theme.backgroundDeep, 0.6)
                border.width: 1
                border.color: Theme.withAlpha(Theme.accent, 0.25)
            }

            IconImage {
                id: icon
                anchors.fill: parent
                anchors.margins: 3
                source: root.entry && root.entry.icon ? Quickshell.iconPath(root.entry.icon, "") : ""
                visible: status === Image.Ready
            }

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusSmall
                visible: icon.status !== Image.Ready
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.accent }
                    GradientStop { position: 1.0; color: Theme.accentDim }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.entry && root.entry.name ? root.entry.name.charAt(0).toUpperCase() : "?"
                    color: Theme.textPrimary
                    font.bold: true
                    font.pixelSize: 15
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

        // Botão de fixar, com um pequeno "bounce" ao alternar
        Text {
            id: pinIcon
            text: root.entry && PinStore.isPinned(root.entry.id) ? "\u2605" : "\u2606"
            color: root.entry && PinStore.isPinned(root.entry.id) ? Theme.pinnedIndicator : Theme.textSecondary
            font.pixelSize: 18

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            SequentialAnimation {
                id: pinBounce
                NumberAnimation { target: pinIcon; property: "scale"; to: 1.4; duration: 90; easing.type: Easing.OutQuad }
                NumberAnimation { target: pinIcon; property: "scale"; to: 1.0; duration: 140; easing.type: Theme.easeBounce }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                onClicked: {
                    if (root.entry) {
                        PinStore.toggle(root.entry.id)
                        pinBounce.restart()
                    }
                }
            }
        }
    }
}
