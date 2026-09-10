import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    width: 19
    height: 19

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property int percent: Math.round(volume * 100)

    property bool observeReady: false
    property int lastShownPercent: -1
    property bool lastShownMuted: false

    readonly property var outputDevices: Pipewire.ready
        ? Pipewire.nodes.values.filter(n => !n.isStream && n.isSink && n.audio)
        : []

    readonly property var inputDevices: Pipewire.ready
        ? Pipewire.nodes.values.filter(n => !n.isStream && !n.isSink && n.audio)
        : []

    PwObjectTracker {
        objects: Pipewire.ready ? Pipewire.nodes.values : []
    }

    function showCurrent() {
        if (!root.observeReady || !root.sink?.audio)
            return

        const currentPercent = root.percent
        const currentMuted = root.muted

        if (currentPercent === root.lastShownPercent && currentMuted === root.lastShownMuted)
            return

        root.lastShownPercent = currentPercent
        root.lastShownMuted = currentMuted
        Osd.show("volume", currentPercent, currentMuted)
    }

    function toggleMute() {
        if (!sink?.audio)
            return
        sink.audio.muted = !sink.audio.muted
    }

    function setVolume(value) {
        if (!sink?.audio)
            return

        const next = Math.max(0, Math.min(1.5, value / 100))
        sink.audio.muted = false
        sink.audio.volume = next
    }

    function selectOutput(node) {
        Pipewire.preferredDefaultAudioSink = node
    }

    function selectInput(node) {
        Pipewire.preferredDefaultAudioSource = node
    }

    IpcHandler {
        target: "volume"
        function up(): void { root.setVolume(root.percent + 5) }
        function down(): void { root.setVolume(root.percent - 5) }
        function toggleMute(): void { root.toggleMute() }
    }

    Timer {
        interval: 450
        running: true
        repeat: false
        onTriggered: {
            root.observeReady = true
            root.lastShownPercent = root.percent
            root.lastShownMuted = root.muted
        }
    }

    Connections {
        target: root.sink?.audio ?? null

        function onVolumeChanged() { root.showCurrent() }
        function onMutedChanged() { root.showCurrent() }
    }

    Canvas {
        id: volCanvas
        anchors.fill: parent

        property color fg: hoverArea.containsMouse ? Colors.accent : Colors.textSecondary
        property int percent_: root.percent
        property bool muted_: root.muted

        onFgChanged: requestPaint()
        onPercent_Changed: requestPaint()
        onMuted_Changed: requestPaint()
        Component.onCompleted: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = fg
            ctx.strokeStyle = fg
            ctx.lineWidth = 1.35
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            const w = width
            const h = height

            ctx.beginPath()
            ctx.moveTo(w * .08, h * .39)
            ctx.lineTo(w * .30, h * .39)
            ctx.lineTo(w * .51, h * .19)
            ctx.lineTo(w * .51, h * .81)
            ctx.lineTo(w * .30, h * .61)
            ctx.lineTo(w * .08, h * .61)
            ctx.closePath()
            ctx.fill()

            if (muted_) {
                ctx.beginPath()
                ctx.moveTo(w * .63, h * .30)
                ctx.lineTo(w * .90, h * .70)
                ctx.moveTo(w * .90, h * .30)
                ctx.lineTo(w * .63, h * .70)
                ctx.stroke()
                return
            }

            const waves = percent_ > 70 ? 3 : percent_ > 30 ? 2 : percent_ > 0 ? 1 : 0
            for (let i = 0; i < waves; i++) {
                ctx.beginPath()
                ctx.arc(w * .48, h * .50, 4.0 + i * 3.0, -0.56, 0.56)
                ctx.stroke()
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        anchors.margins: -5
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: volCanvas.requestPaint()
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton)
                volumePopup.open()
        }
        onPressed: mouse => {
            if (mouse.button === Qt.RightButton)
                root.toggleMute()
        }
    }

    Popup {
        id: volumePopup
        anchorRight: true

        Rectangle {
            width: 360
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
                        text: "Volume"
                        color: Colors.textPrimary
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: root.muted ? "Mudo" : root.percent + "%"
                        color: root.muted ? Colors.textDim : Colors.accent
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
                        radius: 4
                        width: parent.width * Math.min(1, root.percent / 100)
                        color: root.muted ? Colors.textDim : Colors.accent
                        Behavior on width { NumberAnimation { duration: Colors.animFast; easing.type: Colors.easeOut } }
                    }

                    Rectangle {
                        width: 14
                        height: 14
                        radius: 7
                        y: (track.height - height) / 2
                        x: Math.max(0, Math.min(track.width - width, track.width * Math.min(1, root.percent / 100) - width / 2))
                        color: Colors.textPrimary
                        border.width: 2
                        border.color: root.muted ? Colors.textDim : Colors.accent
                        Behavior on x { NumberAnimation { duration: Colors.animFast; easing.type: Colors.easeOut } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.topMargin: -7
                        anchors.bottomMargin: -7
                        function apply(mouseX) {
                            root.setVolume((mouseX / track.width) * 100)
                        }
                        onPressed: mouse => apply(mouse.x)
                        onPositionChanged: mouse => { if (pressed) apply(mouse.x) }
                    }
                }

                DeviceList {
                    title: "Saída"
                    devices: root.outputDevices
                    activeNode: root.sink
                    onSelected: node => root.selectOutput(node)
                }

                DeviceList {
                    title: "Entrada"
                    devices: root.inputDevices
                    activeNode: root.source
                    onSelected: node => root.selectInput(node)
                }

                Text {
                    Layout.fillWidth: true
                    text: root.percent > 100
                        ? "Amplificação ativa · clique direito para silenciar"
                        : "Clique direito no ícone para silenciar"
                    horizontalAlignment: Text.AlignHCenter
                    color: Colors.textDim
                    font.pixelSize: 9
                }
            }
        }
    }
}
