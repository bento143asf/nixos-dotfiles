import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    width: 19
    height: 19

    property bool wifiEnabled: true
    property bool ethernetConnected: false
    property string connectedSsid: ""
    property string connectedDevice: ""
    property int connectedSignal: 0
    property var networks: []
    property bool scanning: false
    property string passwordTargetSsid: ""

    function splitEscaped(line) {
        const result = []
        let current = ""
        let escaped = false

        for (let i = 0; i < line.length; i++) {
            const ch = line[i]
            if (escaped) {
                current += ch
                escaped = false
            } else if (ch === "\\") {
                escaped = true
            } else if (ch === ":") {
                result.push(current)
                current = ""
            } else {
                current += ch
            }
        }
        if (escaped)
            current += "\\"
        result.push(current)
        return result
    }

    function refresh(rescan) {
        if (wifiProc.running)
            return

        root.scanning = rescan === true
        wifiProc.command = [
            "bash", "-c",
            "echo '--radio--'; nmcli -t -f WIFI g; " +
            "echo '--devices--'; nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev status; " +
            "echo '--networks--'; nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list --rescan " + (rescan ? "yes" : "no")
        ]
        wifiProc.running = true
    }

    function toggleWifiRadio() {
        const next = !root.wifiEnabled
        radioProc.command = ["nmcli", "radio", "wifi", next ? "on" : "off"]
        radioProc.running = true
    }

    function connectNetwork(ssid, password) {
        root.scanning = true
        connectProc.command = password
            ? ["nmcli", "dev", "wifi", "connect", ssid, "password", password]
            : ["nmcli", "dev", "wifi", "connect", ssid]
        connectProc.running = true
    }

    function disconnectCurrent() {
        if (!root.connectedDevice)
            return
        actionProc.command = ["nmcli", "device", "disconnect", root.connectedDevice]
        actionProc.running = true
    }

    Process {
        id: wifiProc

        stdout: StdioCollector {
            onStreamFinished: {
                const blocks = { radio: [], devices: [], networks: [] }
                let current = ""

                text.split("\n").forEach(line => {
                    const trimmed = line.trim()
                    if (trimmed === "--radio--") { current = "radio"; return }
                    if (trimmed === "--devices--") { current = "devices"; return }
                    if (trimmed === "--networks--") { current = "networks"; return }
                    if (current && trimmed)
                        blocks[current].push(trimmed)
                })

                const radio = blocks.radio[0] || ""
                root.wifiEnabled = radio.toLowerCase().includes("enabled")

                root.ethernetConnected = false
                root.connectedDevice = ""
                root.connectedSsid = ""

                blocks.devices.forEach(line => {
                    const parts = root.splitEscaped(line)
                    const device = parts[0] || ""
                    const type = parts[1] || ""
                    const state = parts[2] || ""
                    const connection = parts.slice(3).join(":")

                    if (type === "ethernet" && state.toLowerCase().startsWith("connected"))
                        root.ethernetConnected = true

                    if (type === "wifi" && state.toLowerCase().startsWith("connected")) {
                        root.connectedDevice = device
                        root.connectedSsid = connection === "--" ? "" : connection
                    }
                })

                const dedup = {}
                blocks.networks.forEach(line => {
                    const p = root.splitEscaped(line)
                    const active = (p[0] || "").trim() === "*"
                    const ssid = (p[1] || "").trim()
                    const signal = parseInt(p[2]) || 0
                    const security = (p[3] || "").trim()

                    if (!ssid)
                        return

                    const entry = {
                        ssid,
                        signal,
                        security,
                        active
                    }

                    if (!dedup[ssid] || signal > dedup[ssid].signal || active)
                        dedup[ssid] = entry
                })

                root.networks = Object.keys(dedup).map(key => dedup[key]).sort((a, b) => {
                    if (a.active !== b.active)
                        return a.active ? -1 : 1
                    return b.signal - a.signal
                })

                const active = root.networks.find(n => n.active)
                if (active) {
                    root.connectedSsid = active.ssid
                    root.connectedSignal = active.signal
                } else {
                    root.connectedSignal = 0
                }

                root.scanning = false
            }
        }
    }

    Process {
        id: radioProc
        stdout: StdioCollector { onStreamFinished: root.refresh(false) }
    }

    Process {
        id: connectProc
        stdout: StdioCollector { onStreamFinished: root.refresh(false) }
    }

    Process {
        id: actionProc
        stdout: StdioCollector { onStreamFinished: root.refresh(false) }
    }

    Timer {
        interval: 20000
        running: wifiPopup.visible
        repeat: true
        onTriggered: root.refresh(false)
    }

    Canvas {
        id: wifiCanvas
        anchors.fill: parent

        property color fg: hoverArea.containsMouse ? Colors.accent : Colors.textSecondary
        property bool enabled_: root.wifiEnabled
        property bool ethernet_: root.ethernetConnected
        property int signal_: root.connectedSignal

        onFgChanged: requestPaint()
        onEnabled_Changed: requestPaint()
        onEthernet_Changed: requestPaint()
        onSignal_Changed: requestPaint()
        Component.onCompleted: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.strokeStyle = fg
            ctx.fillStyle = fg
            ctx.lineWidth = 1.45
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            const w = width
            const h = height

            if (ethernet_) {
                ctx.strokeRect(w * 0.20, h * 0.12, w * 0.60, h * 0.46)
                ctx.beginPath()
                ctx.moveTo(w * 0.50, h * 0.58)
                ctx.lineTo(w * 0.50, h * 0.82)
                ctx.moveTo(w * 0.34, h * 0.82)
                ctx.lineTo(w * 0.66, h * 0.82)
                ctx.stroke()
                ctx.fillRect(w * 0.30, h * 0.28, w * 0.12, h * 0.10)
                ctx.fillRect(w * 0.58, h * 0.28, w * 0.12, h * 0.10)
                return
            }

            if (!enabled_) {
                ctx.globalAlpha = 0.45
            }

            const cx = w / 2
            const cy = h * 0.86
            const lit = signal_ > 75 ? 3 : signal_ > 45 ? 2 : signal_ > 0 ? 1 : 0

            ctx.beginPath()
            ctx.arc(cx, cy, 1.35, 0, Math.PI * 2)
            ctx.fill()

            for (let i = 0; i < 3; i++) {
                const radius = 4.0 + i * 3.0
                ctx.globalAlpha = enabled_ ? (i < lit ? 1 : 0.24) : 0.22
                ctx.beginPath()
                ctx.arc(cx, cy, radius, Math.PI * 1.22, Math.PI * 1.78)
                ctx.stroke()
            }

            ctx.globalAlpha = 1
            if (!enabled_) {
                ctx.beginPath()
                ctx.moveTo(w * 0.13, h * 0.14)
                ctx.lineTo(w * 0.87, h * 0.86)
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
        onContainsMouseChanged: wifiCanvas.requestPaint()
        onClicked: {
            root.refresh(true)
            wifiPopup.open()
        }
    }

    Popup {
        id: wifiPopup
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
                            text: "Wi-Fi"
                            color: Colors.textPrimary
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: root.wifiEnabled
                                ? (root.connectedSsid ? root.connectedSsid : (root.scanning ? "Procurando redes…" : "Nenhuma rede conectada"))
                                : "Desativado"
                            color: root.connectedSsid ? Colors.success : Colors.textDim
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        width: 42
                        height: 24
                        radius: 12
                        color: root.wifiEnabled ? Colors.accent : Colors.trackBackground
                        Behavior on color { ColorAnimation { duration: Colors.animFast } }

                        Rectangle {
                            width: 18
                            height: 18
                            radius: 9
                            y: 3
                            x: root.wifiEnabled ? parent.width - width - 3 : 3
                            color: root.wifiEnabled ? Colors.accentText : Colors.textSecondary
                            Behavior on x { NumberAnimation { duration: Colors.animFast; easing.type: Colors.easeOut } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleWifiRadio()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Colors.withAlpha(Colors.textPrimary, 0.055)
                }

                Text {
                    visible: root.scanning
                    text: "Procurando redes próximas…"
                    color: Colors.accent
                    font.pixelSize: 10
                }

                Repeater {
                    model: root.wifiEnabled ? root.networks : []

                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Rectangle {
                            Layout.fillWidth: true
                            height: 43
                            radius: 10
                            color: networkHover.containsMouse ? Colors.popupHover : "transparent"
                            Behavior on color { ColorAnimation { duration: Colors.animFast } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 10

                                Item {
                                    Layout.preferredWidth: 22
                                    Layout.preferredHeight: 22

                                    Canvas {
                                        anchors.fill: parent
                                        property color fg: modelData.active ? Colors.accent : Colors.textSecondary
                                        property int strength: modelData.signal
                                        onFgChanged: requestPaint()
                                        onStrengthChanged: requestPaint()
                                        Component.onCompleted: requestPaint()
                                        onPaint: {
                                            const ctx = getContext("2d")
                                            ctx.reset()
                                            ctx.strokeStyle = fg
                                            ctx.fillStyle = fg
                                            ctx.lineWidth = 1.35
                                            ctx.lineCap = "round"
                                            const cx = width / 2
                                            const cy = height * 0.82
                                            const lit = strength > 75 ? 3 : strength > 45 ? 2 : strength > 0 ? 1 : 0
                                            ctx.beginPath(); ctx.arc(cx, cy, 1.3, 0, Math.PI * 2); ctx.fill()
                                            for (let i = 0; i < 3; i++) {
                                                ctx.globalAlpha = i < lit ? 1 : 0.25
                                                ctx.beginPath()
                                                ctx.arc(cx, cy, 4 + i * 3, Math.PI * 1.22, Math.PI * 1.78)
                                                ctx.stroke()
                                            }
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.ssid
                                        color: Colors.textPrimary
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: modelData.active
                                            ? "Conectado · " + modelData.signal + "%"
                                            : ((modelData.security && modelData.security !== "--") ? "Protegida · " + modelData.signal + "%" : "Aberta · " + modelData.signal + "%")
                                        color: modelData.active ? Colors.success : Colors.textDim
                                        font.pixelSize: 9
                                    }
                                }

                                Text {
                                    text: modelData.active ? "✓" : ""
                                    color: Colors.accent
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                }
                            }

                            MouseArea {
                                id: networkHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.active) {
                                        root.disconnectCurrent()
                                    } else if (!modelData.security || modelData.security === "--") {
                                        root.connectNetwork(modelData.ssid, "")
                                    } else {
                                        root.passwordTargetSsid = root.passwordTargetSsid === modelData.ssid ? "" : modelData.ssid
                                    }
                                }
                            }
                        }

                        Rectangle {
                            visible: root.passwordTargetSsid === modelData.ssid
                            Layout.fillWidth: true
                            height: visible ? 44 : 0
                            radius: 10
                            color: Colors.popupSurface
                            clip: true

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 7
                                spacing: 7

                                TextInput {
                                    id: passwordInput
                                    Layout.fillWidth: true
                                    color: Colors.textPrimary
                                    selectionColor: Colors.accent
                                    selectedTextColor: Colors.accentText
                                    font.pixelSize: 11
                                    echoMode: TextInput.Password
                                    clip: true
                                    activeFocusOnPress: true
                                    onVisibleChanged: if (visible) forceActiveFocus()
                                    Text {
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                        text: "Senha da rede"
                                        color: Colors.textDim
                                        font.pixelSize: 10
                                        visible: !parent.text
                                    }
                                }

                                Rectangle {
                                    width: 62
                                    height: 30
                                    radius: 8
                                    color: Colors.accent

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Conectar"
                                        color: Colors.accentText
                                        font.pixelSize: 10
                                        font.weight: Font.DemiBold
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.connectNetwork(modelData.ssid, passwordInput.text)
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: root.wifiEnabled && !root.scanning && root.networks.length === 0
                    Layout.fillWidth: true
                    text: "Nenhuma rede encontrada"
                    horizontalAlignment: Text.AlignHCenter
                    color: Colors.textDim
                    font.pixelSize: 11
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 34
                    radius: 9
                    color: refreshArea.containsMouse ? Colors.popupHover : Colors.popupSurface
                    Behavior on color { ColorAnimation { duration: Colors.animFast } }

                    Text {
                        anchors.centerIn: parent
                        text: root.scanning ? "Procurando…" : "Atualizar redes"
                        color: Colors.textSecondary
                        font.pixelSize: 10
                    }

                    MouseArea {
                        id: refreshArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.refresh(true)
                    }
                }
            }
        }
    }
}
