import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    visible: true
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Colors.barHeight + Colors.barMargin * 2

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-bar"
    WlrLayershell.exclusiveZone: Colors.barHeight + Colors.barMargin * 2
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Left: launcher, workspaces, media.
    Row {
        anchors.left: parent.left
        anchors.leftMargin: Colors.barMargin + 5
        anchors.verticalCenter: parent.verticalCenter
        spacing: Colors.pillSpacing

        NixButton {}
        Workspaces {}
        MediaPlayer {}
    }

    // Center: clock / calendar.
    ClockCalendar {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    // Right: Wi-Fi, Bluetooth, volume, RAM, CPU.
    StatusPill {
        anchors.right: parent.right
        anchors.rightMargin: Colors.barMargin + 5
        anchors.verticalCenter: parent.verticalCenter
    }
}
