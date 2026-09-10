import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    spacing: 10

    property real ramGb: 0
    property int cpuPercent: 0
    property bool ready: false

    Process {
        id: statsProc
        command: ["bash", Quickshell.env("HOME") + "/.config/quickshell/topbar/stats.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|")
                if (parts.length !== 2)
                    return

                root.ramGb = parseFloat(parts[0]) || 0
                root.cpuPercent = Math.max(0, Math.min(100, parseInt(parts[1]) || 0))
                root.ready = true
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!statsProc.running)
                statsProc.running = true
        }
    }

    RowLayout {
        spacing: 5

        ChipIcon {}

        Text {
            text: root.ramGb.toFixed(1) + " GB"
            color: Colors.textSecondary
            font.pixelSize: 11
            font.weight: Font.Medium
        }
    }

    RowLayout {
        spacing: 5

        Item {
            width: 16
            height: 16

            Canvas {
                anchors.fill: parent
                property color fg: Colors.textSecondary
                property int value: root.cpuPercent
                onFgChanged: requestPaint()
                onValueChanged: requestPaint()
                Component.onCompleted: requestPaint()

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = fg
                    ctx.fillStyle = fg
                    ctx.lineWidth = 1.25
                    ctx.lineCap = "round"

                    const cx = width / 2
                    const cy = height / 2
                    const radius = 5

                    ctx.beginPath()
                    ctx.arc(cx, cy, radius, Math.PI * 0.75, Math.PI * 2.25)
                    ctx.stroke()

                    const angle = Math.PI * 0.75 + (Math.PI * 1.5) * (value / 100)
                    ctx.beginPath()
                    ctx.moveTo(cx, cy)
                    ctx.lineTo(cx + Math.cos(angle) * 4.2, cy + Math.sin(angle) * 4.2)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(cx, cy, 1.2, 0, Math.PI * 2)
                    ctx.fill()
                }
            }
        }

        Text {
            text: root.cpuPercent + "%"
            color: Colors.textSecondary
            font.pixelSize: 11
            font.weight: Font.Medium
        }
    }
}
