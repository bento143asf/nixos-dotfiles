import QtQuick

Item {
    width: 16
    height: 16

    Canvas {
        anchors.fill: parent
        property color fg: Colors.textSecondary
        onFgChanged: requestPaint()
        Component.onCompleted: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.strokeStyle = fg
            ctx.fillStyle = fg
            ctx.lineWidth = 1.2
            ctx.lineJoin = "round"
            ctx.lineCap = "round"

            const x = 4
            const y = 4
            const s = 8

            ctx.strokeRect(x, y, s, s)

            for (let i = 0; i < 3; i++) {
                const p = y + 1.2 + i * 2.8
                ctx.beginPath()
                ctx.moveTo(1.5, p)
                ctx.lineTo(4, p)
                ctx.moveTo(12, p)
                ctx.lineTo(14.5, p)
                ctx.stroke()
            }

            for (let i = 0; i < 2; i++) {
                const p = x + 2.0 + i * 4
                ctx.beginPath()
                ctx.moveTo(p, 1.5)
                ctx.lineTo(p, 4)
                ctx.moveTo(p, 12)
                ctx.lineTo(p, 14.5)
                ctx.stroke()
            }
        }
    }
}
