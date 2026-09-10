import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    height: Colors.barHeight
    width: row.implicitWidth + 22
    radius: Colors.cornerRadius
    color: Colors.pillBackground
    border.width: 1
    border.color: Colors.withAlpha(Colors.textPrimary, 0.055)

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 13

        Wifi { Layout.alignment: Qt.AlignVCenter }
        Bluetooth { Layout.alignment: Qt.AlignVCenter }
        Volume { Layout.alignment: Qt.AlignVCenter }
        SystemStats { Layout.alignment: Qt.AlignVCenter }
    }
}
