import Quickshell.Io
import QtQuick

Item {
    id: root

    width: Colors.barHeight
    height: Colors.barHeight

    property real visualScale: hover.containsMouse ? 1.035 : 1.0

    Rectangle {
        id: surface
        anchors.fill: parent
        radius: Colors.cornerRadius
        color: hover.containsMouse ? Colors.pillBackgroundHover : Colors.pillBackground
        border.width: 1
        border.color: hover.containsMouse
            ? Colors.withAlpha(Colors.accent, 0.42)
            : Colors.withAlpha(Colors.textPrimary, 0.055)
        scale: root.visualScale

        Behavior on color { ColorAnimation { duration: Colors.animFast } }
        Behavior on border.color { ColorAnimation { duration: Colors.animFast } }
        Behavior on scale { NumberAnimation { duration: Colors.animFast; easing.type: Colors.easeOut } }
    }

    Process {
        id: launcherProc
        command: ["quickshell", "-c", "launcher"]
    }

    Item {
        id: icon
        anchors.centerIn: surface
        width: 19
        height: 19
        rotation: hover.containsMouse ? 90 : 0

        Behavior on rotation {
            NumberAnimation { duration: Colors.animSlow; easing.type: Colors.easeSmooth }
        }

        Repeater {
            model: 3
            Rectangle {
                anchors.centerIn: parent
                width: 2.8
                height: 18
                radius: 1.4
                rotation: index * 60
                color: hover.containsMouse ? Colors.accent : Colors.textPrimary

                Behavior on color { ColorAnimation { duration: Colors.animFast } }
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 5
            height: 5
            radius: 2.5
            color: Colors.pillBackground
            border.width: 1.3
            border.color: hover.containsMouse ? Colors.accent : Colors.textPrimary

            Behavior on border.color { ColorAnimation { duration: Colors.animFast } }
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            clickAnim.restart()
            launcherProc.running = true
        }
    }

    SequentialAnimation {
        id: clickAnim
        NumberAnimation { target: surface; property: "scale"; to: 0.91; duration: 65; easing.type: Easing.OutQuad }
        NumberAnimation { target: surface; property: "scale"; to: root.visualScale; duration: 150; easing.type: Easing.OutBack }
    }
}
