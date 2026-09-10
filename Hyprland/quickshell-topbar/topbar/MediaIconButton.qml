import QtQuick

Item {
    id: root

    property string kind: "play"
    property bool accent: false
    signal clicked()

    width: 26
    height: 26

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: hover.containsMouse
            ? Colors.withAlpha(Colors.accent, 0.14)
            : "transparent"
        Behavior on color { ColorAnimation { duration: Colors.animFast } }
    }

    Canvas {
        id: canvas
        anchors.centerIn: parent
        width: 14
        height: 14
        property color fg: root.accent || hover.containsMouse ? Colors.accent : Colors.textSecondary
        onFgChanged: requestPaint()
        Component.onCompleted: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = fg
            ctx.strokeStyle = fg
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            if (root.kind === "play") {
                ctx.beginPath()
                ctx.moveTo(3, 1.5)
                ctx.lineTo(12, 7)
                ctx.lineTo(3, 12.5)
                ctx.closePath()
                ctx.fill()
            } else if (root.kind === "pause") {
                ctx.fillRect(2, 1.5, 3.4, 11)
                ctx.fillRect(8.6, 1.5, 3.4, 11)
            } else if (root.kind === "next") {
                ctx.beginPath()
                ctx.moveTo(1.5, 1.5)
                ctx.lineTo(8.5, 7)
                ctx.lineTo(1.5, 12.5)
                ctx.closePath()
                ctx.fill()
                ctx.fillRect(10, 1.5, 2.5, 11)
            } else {
                ctx.beginPath()
                ctx.moveTo(12.5, 1.5)
                ctx.lineTo(5.5, 7)
                ctx.lineTo(12.5, 12.5)
                ctx.closePath()
                ctx.fill()
                ctx.fillRect(1.5, 1.5, 2.5, 11)
            }
        }
    }

    scale: hover.containsMouse ? 1.08 : 1
    Behavior on scale { NumberAnimation { duration: Colors.animFast; easing.type: Colors.easeOut } }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: canvas.requestPaint()
        onClicked: root.clicked()
    }
}
