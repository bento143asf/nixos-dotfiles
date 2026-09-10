import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string title: ""
    property var devices: []
    property var activeNode: null
    signal selected(var node)

    Layout.fillWidth: true
    spacing: 5
    visible: devices.length > 0

    Text {
        text: root.title
        color: Colors.textDim
        font.pixelSize: 9
        font.weight: Font.DemiBold
    }

    Repeater {
        model: root.devices

        delegate: Rectangle {
            id: row
            Layout.fillWidth: true
            height: 36
            radius: 9
            color: hoverArea.containsMouse ? Colors.popupHover : "transparent"
            Behavior on color { ColorAnimation { duration: Colors.animFast } }

            readonly property bool isActive: root.activeNode !== null && modelData.id === root.activeNode.id

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 9
                anchors.rightMargin: 9
                spacing: 9

                Rectangle {
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18
                    radius: 6
                    color: row.isActive ? Colors.withAlpha(Colors.accent, 0.16) : Colors.popupSurface
                    border.width: 1
                    border.color: row.isActive ? Colors.accent : Colors.withAlpha(Colors.textSecondary, 0.15)

                    Canvas {
                        anchors.fill: parent
                        anchors.margins: 5
                        property color fg: row.isActive ? Colors.accent : Colors.textDim
                        onFgChanged: requestPaint()
                        Component.onCompleted: requestPaint()
                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.reset()
                            ctx.fillStyle = fg
                            ctx.beginPath()
                            ctx.arc(width / 2, height / 2, row.isActive ? 3 : 2, 0, Math.PI * 2)
                            ctx.fill()
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: modelData.description || modelData.name || "Dispositivo"
                    color: Colors.textPrimary
                    font.pixelSize: 10
                    elide: Text.ElideRight
                }

                Text {
                    text: row.isActive ? "Ativo" : ""
                    color: Colors.success
                    font.pixelSize: 9
                }
            }

            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.selected(modelData)
            }
        }
    }
}
