pragma Singleton
import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    visible: false
    color: "transparent"
    implicitWidth: 330
    implicitHeight: 82

    anchors {
        top: true
        left: true
        right: true
    }

    margins.top: Colors.barHeight + Colors.barMargin + 13

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-bar-osd"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    property string kind: "volume"
    property int percent: 0
    property bool muted: false

    function show(type, value, isMuted) {
        root.kind = type
        root.percent = Math.max(0, Math.min(type === "volume" ? 150 : 100, Math.round(value)))
        root.muted = isMuted === true
        hideTimer.restart()

        if (!root.visible) {
            root.visible = true
            panel.opacity = 0
            panel.scale = 0.94
            entrance.restart()
        } else {
            // Do not replay the entrance animation for every keypress.
            // The contents and progress bar update immediately.
            panel.opacity = 1
            panel.scale = 1
        }
    }

    function hide() {
        if (!root.visible || exit.running)
            return
        exit.restart()
    }

    Timer {
        id: hideTimer
        interval: 1600
        repeat: false
        onTriggered: root.hide()
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: 330
        height: 82
        radius: 18
        color: Colors.popupBackground
        border.width: 1
        border.color: Colors.withAlpha(Colors.textPrimary, 0.08)
        opacity: 0
        scale: 0.94
        transformOrigin: Item.Center

        Row {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 14

            Item {
                width: 34
                height: 34
                anchors.verticalCenter: parent.verticalCenter

                Canvas {
                    anchors.fill: parent
                    property color fg: Colors.accent
                    property string type_: root.kind
                    property int value_: root.percent
                    property bool muted_: root.muted
                    onType_Changed: requestPaint()
                    onValue_Changed: requestPaint()
                    onMuted_Changed: requestPaint()
                    Component.onCompleted: requestPaint()

                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.reset()
                        ctx.strokeStyle = fg
                        ctx.fillStyle = fg
                        ctx.lineWidth = 1.8
                        ctx.lineCap = "round"
                        ctx.lineJoin = "round"

                        const w = width
                        const h = height

                        if (type_ === "brightness") {
                            const cx = w / 2
                            const cy = h / 2
                            ctx.beginPath()
                            ctx.arc(cx, cy, 5, 0, Math.PI * 2)
                            ctx.fill()
                            for (let i = 0; i < 8; i++) {
                                const a = i * Math.PI / 4
                                ctx.beginPath()
                                ctx.moveTo(cx + Math.cos(a) * 9, cy + Math.sin(a) * 9)
                                ctx.lineTo(cx + Math.cos(a) * 13, cy + Math.sin(a) * 13)
                                ctx.stroke()
                            }
                            return
                        }

                        ctx.beginPath()
                        ctx.moveTo(w * .08, h * .40)
                        ctx.lineTo(w * .27, h * .40)
                        ctx.lineTo(w * .46, h * .22)
                        ctx.lineTo(w * .46, h * .78)
                        ctx.lineTo(w * .27, h * .60)
                        ctx.lineTo(w * .08, h * .60)
                        ctx.closePath()
                        ctx.fill()

                        if (muted_) {
                            ctx.beginPath()
                            ctx.moveTo(w * .61, h * .31)
                            ctx.lineTo(w * .91, h * .69)
                            ctx.moveTo(w * .91, h * .31)
                            ctx.lineTo(w * .61, h * .69)
                            ctx.stroke()
                        } else {
                            const waves = value_ > 70 ? 3 : value_ > 30 ? 2 : value_ > 0 ? 1 : 0
                            for (let i = 0; i < waves; i++) {
                                ctx.beginPath()
                                ctx.arc(w * .46, h * .50, 6 + i * 4, -0.55, 0.55)
                                ctx.stroke()
                            }
                        }
                    }
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 48
                spacing: 7

                Row {
                    width: parent.width

                    Text {
                        text: root.kind === "brightness"
                            ? "Brilho"
                            : (root.muted ? "Volume · Mudo" : "Volume")
                        color: Colors.textPrimary
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    Text {
                        anchors.right: parent.right
                        text: root.muted ? "—" : root.percent + "%"
                        color: Colors.textSecondary
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 8
                    radius: 4
                    color: Colors.trackBackground

                    Rectangle {
                        width: parent.width * Math.min(1, root.percent / 100)
                        height: parent.height
                        radius: 4
                        color: root.muted ? Colors.textDim : Colors.accent
                        Behavior on width {
                            NumberAnimation { duration: Colors.animFast; easing.type: Colors.easeOut }
                        }
                    }
                }
            }
        }

        ParallelAnimation {
            id: entrance
            NumberAnimation { target: panel; property: "opacity"; from: 0; to: 1; duration: Colors.animMedium; easing.type: Colors.easeOut }
            NumberAnimation { target: panel; property: "scale"; from: 0.94; to: 1; duration: Colors.animMedium; easing.type: Colors.easeOut }
        }

        ParallelAnimation {
            id: exit
            NumberAnimation { target: panel; property: "opacity"; from: 1; to: 0; duration: Colors.animFast; easing.type: Colors.easeIn }
            NumberAnimation { target: panel; property: "scale"; from: 1; to: 0.96; duration: Colors.animFast; easing.type: Colors.easeIn }
            onFinished: {
                root.visible = false
                panel.opacity = 0
                panel.scale = 0.94
            }
        }
    }
}
