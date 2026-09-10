import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    width: 19
    height: 19

    property bool powered: false
    property bool scanning: false
    property var devices: []

    function refresh() {
        if (!statusProc.running)
            statusProc.running = true
    }

    function scan() {
        if (!root.powered || scanProc.running)
            return

        root.scanning = true
        scanProc.running = true
    }

    function togglePower() {
        powerProc.command = ["bluetoothctl", "power", root.powered ? "off" : "on"]
        powerProc.running = true
    }

    function connectDevice(mac) {
        actionProc.command = ["bluetoothctl", "connect", mac]
        actionProc.running = true
    }

    function disconnectDevice(mac) {
        actionProc.command = ["bluetoothctl", "disconnect", mac]
        actionProc.running = true
    }

    Process {
        id: statusProc
        command: [
            "bash", "-c",
            "echo '--power--'; bluetoothctl show 2>/dev/null | grep -i 'Powered:'; " +
            "echo '--devices--'; bluetoothctl devices 2>/dev/null; " +
            "echo '--connected--'; bluetoothctl devices Connected 2>/dev/null"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const blocks = { power: [], devices: [], connected: [] }
                let current = ""

                text.split("\n").forEach(line => {
                    const trimmed = line.trim()
                    if (trimmed === "--power--") { current = "power"; return }
                    if (trimmed === "--devices--") { current = "devices"; return }
                    if (trimmed === "--connected--") { current = "connected"; return }
                    if (current && trimmed)
                        blocks[current].push(trimmed)
                })

                root.powered = (blocks.power[0] || "").toLowerCase().includes("yes")

                const connected = {}
                blocks.connected.forEach(line => {
                    const parts = line.split(/\s+/)
                    if (parts[1])
                        connected[parts[1]] = true
                })

                const byMac = {}
                blocks.devices.forEach(line => {
                    const parts = line.split(/\s+/)
                    const mac = parts[1]
                    if (!mac)
                        return

                    const name = parts.slice(2).join(" ") || mac
                    byMac[mac] = {
                        mac,
                        name,
                        connected: !!connected[mac]
                    }
                })

                root.devices = Object.keys(byMac).map(mac => byMac[mac]).sort((a, b) => {
                    if (a.connected !== b.connected)
                        return a.connected ? -1 : 1
                    return a.name.localeCompare(b.name, undefined, { sensitivity: "base" })
                })
            }
        }
    }

    Process {
        id: scanProc
        command: ["bluetoothctl", "--timeout", "6", "scan", "on"]
        stdout: StdioCollector { onStreamFinished: { root.scanning = false; root.refresh() } }
        stderr: StdioCollector { onStreamFinished: {} }
    }

    Process {
        id: powerProc
        stdout: StdioCollector { onStreamFinished: root.refresh() }
    }

    Process {
        id: actionProc
        stdout: StdioCollector { onStreamFinished: root.refresh() }
    }

    Timer {
        interval: 15000
        running: btPopup.visible
        repeat: true
        onTriggered: root.refresh()
    }

    Canvas {
        id: btCanvas
        anchors.fill: parent

        property color fg: hoverArea.containsMouse ? Colors.accent : Colors.textSecondary
        property bool powered_: root.powered
        onFgChanged: requestPaint()
        onPowered_Changed: requestPaint()
        Component.onCompleted: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.strokeStyle = fg
            ctx.lineWidth = 1.45
            ctx.lineCap = "round"
            ctx.lineJoin = "round"
            ctx.globalAlpha = powered_ ? 1 : 0.38

            const w = width
            const h = height
            const cx = w * 0.50

            ctx.beginPath()
            ctx.moveTo(cx, h * 0.08)
            ctx.lineTo(cx, h * 0.92)
            ctx.moveTo(cx, h * 0.08)
            ctx.lineTo(w * 0.82, h * 0.31)
            ctx.lineTo(cx, h * 0.50)
            ctx.lineTo(w * 0.82, h * 0.69)
            ctx.lineTo(cx, h * 0.92)
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(w * 0.18, h * 0.28)
            ctx.lineTo(w * 0.50, h * 0.50)
            ctx.lineTo(w * 0.18, h * 0.72)
            ctx.stroke()

            ctx.globalAlpha = 1
            if (!powered_) {
                ctx.beginPath()
                ctx.moveTo(w * 0.10, h * 0.10)
                ctx.lineTo(w * 0.90, h * 0.90)
                ctx.stroke()
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        anchors.margins: -5
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: btCanvas.requestPaint()
        onClicked: {
            root.refresh()
            btPopup.open()
            if (root.powered)
                root.scan()
        }
    }

    Popup {
        id: btPopup
        anchorLeft: true

        Rectangle {
            width: 390
            implicitHeight: Math.min(520, content.implicitHeight + 34)
            radius: Colors.popupRadius
            color: Colors.popupBackground
            border.width: 1
            border.color: Colors.withAlpha(Colors.textPrimary, 0.075)
            clip: true

            ColumnLayout {
                id: content
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: "Bluetooth"
                            color: Colors.textPrimary
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: root.powered
                                ? (root.scanning ? "Procurando dispositivos…" : root.devices.length + " dispositivo(s) encontrado(s)")
                                : "Desativado"
                            color: root.scanning ? Colors.accent : Colors.textDim
                            font.pixelSize: 10
                        }
                    }

                    Rectangle {
                        width: 42
                        height: 24
                        radius: 12
                        color: root.powered ? Colors.accent : Colors.trackBackground
                        Behavior on color { ColorAnimation { duration: Colors.animFast } }

                        Rectangle {
                            width: 18
                            height: 18
                            radius: 9
                            y: 3
                            x: root.powered ? parent.width - width - 3 : 3
                            color: root.powered ? Colors.accentText : Colors.textSecondary
                            Behavior on x { NumberAnimation { duration: Colors.animFast; easing.type: Colors.easeOut } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.togglePower()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Colors.withAlpha(Colors.textPrimary, 0.055)
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: 9
                    color: scanArea.containsMouse ? Colors.popupHover : Colors.popupSurface
                    Behavior on color { ColorAnimation { duration: Colors.animFast } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 11
                        anchors.rightMargin: 11
                        spacing: 8

                        Text {
                            Layout.fillWidth: true
                            text: root.scanning ? "Procurando…" : "Procurar dispositivos"
                            color: Colors.textSecondary
                            font.pixelSize: 10
                        }
                        Text {
                            text: root.scanning ? "6s" : "⌕"
                            color: Colors.accent
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                    }

                    MouseArea {
                        id: scanArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: root.powered && !root.scanning
                        onClicked: root.scan()
                    }
                }

                Repeater {
                    model: root.powered ? root.devices : []

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        radius: 10
                        color: deviceHover.containsMouse ? Colors.popupHover : "transparent"
                        Behavior on color { ColorAnimation { duration: Colors.animFast } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                radius: 9
                                color: modelData.connected
                                    ? Colors.withAlpha(Colors.accent, 0.16)
                                    : Colors.popupSurface

                                Canvas {
                                    anchors.fill: parent
                                    anchors.margins: 7
                                    property color fg: modelData.connected ? Colors.accent : Colors.textSecondary
                                    onFgChanged: requestPaint()
                                    Component.onCompleted: requestPaint()
                                    onPaint: {
                                        const ctx = getContext("2d")
                                        ctx.reset()
                                        ctx.strokeStyle = fg
                                        ctx.lineWidth = 1.2
                                        ctx.lineCap = "round"
                                        const w = width, h = height
                                        ctx.beginPath()
                                        ctx.moveTo(w * .5, h * .05)
                                        ctx.lineTo(w * .5, h * .95)
                                        ctx.moveTo(w * .5, h * .05)
                                        ctx.lineTo(w * .82, h * .28)
                                        ctx.lineTo(w * .5, h * .5)
                                        ctx.lineTo(w * .82, h * .72)
                                        ctx.lineTo(w * .5, h * .95)
                                        ctx.stroke()
                                        ctx.beginPath()
                                        ctx.moveTo(w * .15, h * .25)
                                        ctx.lineTo(w * .5, h * .5)
                                        ctx.lineTo(w * .15, h * .75)
                                        ctx.stroke()
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    color: Colors.textPrimary
                                    font.pixelSize: 11
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: modelData.connected ? "Conectado" : modelData.mac
                                    color: modelData.connected ? Colors.success : Colors.textDim
                                    font.pixelSize: 9
                                }
                            }

                            Text {
                                text: modelData.connected ? "Desconectar" : "Conectar"
                                color: modelData.connected ? Colors.textDim : Colors.accent
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                            }
                        }

                        MouseArea {
                            id: deviceHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.connected
                                ? root.disconnectDevice(modelData.mac)
                                : root.connectDevice(modelData.mac)
                        }
                    }
                }

                Text {
                    visible: root.powered && !root.scanning && root.devices.length === 0
                    Layout.fillWidth: true
                    text: "Nenhum dispositivo encontrado"
                    horizontalAlignment: Text.AlignHCenter
                    color: Colors.textDim
                    font.pixelSize: 11
                }
            }
        }
    }
}
