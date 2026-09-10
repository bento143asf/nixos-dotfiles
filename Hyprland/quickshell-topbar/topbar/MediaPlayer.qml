import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    readonly property var activePlayer: {
        const list = Mpris.players.values
        if (list.length === 0)
            return null

        const playing = list.find(p => p.isPlaying)
        return playing || list[0]
    }

    readonly property bool hasMedia: activePlayer !== null
    readonly property bool playing: hasMedia && activePlayer.isPlaying
    readonly property int targetWidth: hasMedia ? 310 : 140

    implicitWidth: targetWidth
    width: targetWidth
    height: Colors.barHeight
    radius: Colors.cornerRadius
    color: Colors.pillBackground
    border.width: 1
    border.color: Colors.withAlpha(Colors.textPrimary, hasMedia ? 0.07 : 0.055)
    clip: true

    Behavior on width {
        NumberAnimation { duration: Colors.animMedium; easing.type: Colors.easeSmooth }
    }

    Timer {
        interval: 700
        running: root.playing && root.activePlayer?.positionSupported
        repeat: true
        onTriggered: {
            // Firefox can disappear from D-Bus while its old MPRIS object is still around.
            // Only poke objects that are still registered with Quickshell.
            if (root.activePlayer && Mpris.players.values.indexOf(root.activePlayer) >= 0)
                root.activePlayer.positionChanged()
        }
    }

    function goNext() {
        if (hasMedia && activePlayer.canGoNext)
            activePlayer.next()
    }

    function goPrevious() {
        if (!hasMedia)
            return

        if (activePlayer.canGoPrevious)
            activePlayer.previous()
        else if (activePlayer.canSeek)
            activePlayer.position = 0
    }

    function togglePlay() {
        if (hasMedia && activePlayer.canTogglePlaying)
            activePlayer.togglePlaying()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 7
        anchors.rightMargin: 7
        spacing: 7

        Rectangle {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            radius: 8
            color: Colors.withAlpha(Colors.textPrimary, 0.06)
            clip: true

            Image {
                anchors.fill: parent
                anchors.margins: 1
                source: root.hasMedia ? root.activePlayer.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                visible: !root.hasMedia || parent.children[0].status !== Image.Ready
                text: root.hasMedia ? "♪" : "♪"
                color: Colors.textDim
                font.pixelSize: 15
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.hasMedia
                    ? (root.activePlayer.trackTitle || "Sem título")
                    : "Sem mídia"
                color: Colors.textPrimary
                font.pixelSize: 11
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.hasMedia
                    ? (root.activePlayer.trackArtist || root.activePlayer.identity || "Sem artista")
                    : ""
                color: Colors.textDim
                font.pixelSize: 9
                elide: Text.ElideRight
            }
        }

        Item {
            Layout.preferredWidth: 78
            Layout.fillHeight: true
            visible: root.hasMedia

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 6
                height: 3
                radius: 1.5
                color: Colors.trackBackground

                Rectangle {
                    width: parent.width * Math.min(1, Math.max(0, root.activePlayer?.length > 0 ? root.activePlayer.position / root.activePlayer.length : 0))
                    height: parent.height
                    radius: 1.5
                    color: Colors.accent
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -5
                    enabled: root.hasMedia && root.activePlayer.canSeek && root.activePlayer.lengthSupported
                    function seek(mouseX) {
                        const ratio = Math.max(0, Math.min(1, mouseX / width))
                        root.activePlayer.position = ratio * root.activePlayer.length
                    }
                    onPressed: mouse => seek(mouse.x)
                    onPositionChanged: mouse => { if (pressed) seek(mouse.x) }
                }
            }
        }

        Row {
            spacing: 1
            Layout.alignment: Qt.AlignVCenter

            MediaIconButton {
                kind: "prev"
                visible: root.hasMedia
                onClicked: root.goPrevious()
            }
            MediaIconButton {
                kind: root.playing ? "pause" : "play"
                accent: root.playing
                visible: root.hasMedia
                onClicked: root.togglePlay()
            }
            MediaIconButton {
                kind: "next"
                visible: root.hasMedia
                onClicked: root.goNext()
            }
        }
    }
}
