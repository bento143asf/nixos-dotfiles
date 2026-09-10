import Quickshell.Hyprland
import QtQuick

Rectangle {
    id: root

    readonly property int count: 9
    readonly property int slotWidth: 27
    readonly property int horizontalPadding: 5

    width: count * slotWidth + horizontalPadding * 2
    height: Colors.barHeight
    radius: Colors.cornerRadius
    color: Colors.pillBackground
    border.width: 1
    border.color: Colors.withAlpha(Colors.textPrimary, 0.055)
    clip: false

    readonly property int activeWorkspace: {
        const list = Hyprland.workspaces.values
        for (let i = 0; i < list.length; i++) {
            if (list[i].active)
                return list[i].id
        }
        return 1
    }

    // Soft glow behind the active slot.
    Rectangle {
        id: activeGlow
        visible: indicator.visible
        x: indicator.x - 3
        y: indicator.y - 3
        width: indicator.width + 6
        height: indicator.height + 6
        radius: indicator.radius + 3
        color: Colors.withAlpha(Colors.accent, 0.12)

        Behavior on x {
            NumberAnimation { duration: Colors.animMedium; easing.type: Colors.easeSmooth }
        }
    }

    Rectangle {
        id: indicator
        visible: root.activeWorkspace >= 1 && root.activeWorkspace <= root.count
        x: root.horizontalPadding + (root.activeWorkspace - 1) * root.slotWidth + 2
        y: 4
        width: root.slotWidth - 4
        height: root.height - 8
        radius: Colors.cornerRadius - 4
        color: Colors.accent

        Behavior on x {
            NumberAnimation { duration: Colors.animMedium; easing.type: Colors.easeSmooth }
        }
        Behavior on color {
            ColorAnimation { duration: Colors.animMedium }
        }
    }

    Row {
        x: root.horizontalPadding
        y: 0
        height: root.height
        spacing: 0

        Repeater {
            model: root.count

            Item {
                width: root.slotWidth
                height: root.height

                readonly property int wsNumber: index + 1
                readonly property bool active: wsNumber === root.activeWorkspace

                Text {
                    anchors.centerIn: parent
                    text: parent.wsNumber
                    color: parent.active
                        ? Colors.accentText
                        : (mouse.containsMouse ? Colors.textPrimary : Colors.textSecondary)
                    font.pixelSize: 12
                    font.weight: parent.active ? Font.DemiBold : Font.Medium

                    Behavior on color {
                        ColorAnimation { duration: Colors.animFast }
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + parent.wsNumber)
                }
            }
        }
    }
}
