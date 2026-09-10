import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    width: 19
    height: 19
    visible: false

    property int percent: 50
    property bool ready: false
    property int lastShownPercent: -1

    function refresh(showChange) {
        if (readProc.running)
            return
        readProc.showChange = showChange === true
        readProc.running = true
    }

    function setBrightness(value) {
        const next = Math.max(1, Math.min(100, Math.round(value)))
        root.percent = next
        setProc.command = ["brightnessctl", "set", next + "%"]
        setProc.running = true
    }

    Process {
        id: readProc
        property bool showChange: false
        command: ["brightnessctl", "-m"]

        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim()
                if (!line)
                    return

                const parts = line.split(",")
                if (parts.length < 5)
                    return

                const value = parseInt(parts[3]) || 0
                const maximum = parseInt(parts[4]) || 0
                if (maximum <= 0)
                    return

                const next = Math.max(0, Math.min(100, Math.round((value / maximum) * 100)))
                const changed = root.ready && next !== root.percent

                root.percent = next
                root.ready = true

                if ((readProc.showChange || changed) && changed) {
                    root.lastShownPercent = next
                    Osd.show("brightness", next, false)
                }
            }
        }
    }

    Process {
        id: setProc
        stdout: StdioCollector { onStreamFinished: root.refresh(true) }
    }

    Timer {
        interval: 700
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh(false)
    }

    // Useful for Hyprland / Quickshell IPC bindings, without requiring them.
    IpcHandler {
        target: "brightness"
        function up(): void { root.setBrightness(root.percent + 5) }
        function down(): void { root.setBrightness(root.percent - 5) }
        function set(value: int): void { root.setBrightness(value) }
    }

    Canvas {
        id: sunCanvas
        anchors.fill: parent
        property color fg: Colors.accent
        property int value: root.percent
        onFgChanged: requestPaint()
        onValueChanged: requestPaint()
        Component.onCompleted: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const cx = width / 2
            const cy = height / 2
            const radius = 3.2

            ctx.strokeStyle = fg
            ctx.fillStyle = fg
            ctx.lineWidth = 1.25
            ctx.lineCap = "round"

            ctx.globalAlpha = 0.45 + value / 100 * 0.55
            ctx.beginPath()
            ctx.arc(cx, cy, radius, 0, Math.PI * 2)
            ctx.fill()
            ctx.globalAlpha = 1

            for (let i = 0; i < 8; i++) {
                const angle = i * Math.PI / 4
                ctx.beginPath()
                ctx.moveTo(cx + Math.cos(angle) * 6, cy + Math.sin(angle) * 6)
                ctx.lineTo(cx + Math.cos(angle) * 8.5, cy + Math.sin(angle) * 8.5)
                ctx.stroke()
            }
        }
    }

    Popup {
        id: brightnessPopup
        anchorRight: true

        Rectangle {
            width: 320
            implicitHeight: content.implicitHeight + 34
            radius: Colors.popupRadius
            color: Colors.popupBackground
            border.width: 1
            border.color: Colors.withAlpha(Colors.textPrimary, 0.075)

            ColumnLayout {
                id: content
                anchors.fill: parent
                anchors.margins: 18
                spacing: 13

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: "Brilho"
                        color: Colors.textPrimary
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: root.percent + "%"
                        color: Colors.accent
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                }

                Rectangle {
                    id: track
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: Colors.trackBackground

                    Rectangle {
                        height: parent.height
                        width: parent.width * root.percent / 100
                        radius: 4
                        color: Colors.accent
                        Behavior on width { NumberAnimation { duration: Colors.animFast; easing.type: Colors.easeOut } }
                    }

                    Rectangle {
                        width: 14
                        height: 14
                        radius: 7
                        y: (track.height - height) / 2
                        x: Math.max(0, Math.min(track.width - width, track.width * root.percent / 100 - width / 2))
                        color: Colors.textPrimary
                        border.width: 2
                        border.color: Colors.accent
                        Behavior on x { NumberAnimation { duration: Colors.animFast; easing.type: Colors.easeOut } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.topMargin: -7
                        anchors.bottomMargin: -7
                        function apply(mouseX) { root.setBrightness((mouseX / track.width) * 100) }
                        onPressed: mouse => apply(mouse.x)
                        onPositionChanged: mouse => { if (pressed) apply(mouse.x) }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "Arraste para ajustar · as teclas de brilho também atualizam este OSD"
                    horizontalAlignment: Text.AlignHCenter
                    color: Colors.textDim
                    font.pixelSize: 9
                }
            }
        }
    }
}
