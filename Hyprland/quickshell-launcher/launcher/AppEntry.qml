import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var entry
    property bool selected: false
    property bool compact: false
    signal clicked()

    // Sempre visível — nenhuma animação de entrada controla isso.
    opacity: 1

    height: compact ? 40 : 54
    radius: compact ? height / 2 : Theme.radiusItem

    color: (selected || hoverArea.containsMouse)
        ? Theme.surfaceHover
        : (compact ? Theme.withAlpha(Theme.backgroundDeep, 0.5) : "transparent")
    border.width: (selected || hoverArea.containsMouse) ? 1.5 : (compact ? 1 : 0)
    border.color: selected ? Theme.accent : Theme.withAlpha(Theme.accent, compact ? 0.3 : 0.35)

    // Escala é seguro animar mesmo dentro de um Layout: é só uma transformação
    // visual, não mexe no x/y/width/height que o Layout usa pra posicionar.
    scale: hoverArea.containsMouse ? (compact ? 1.04 : 1.015) : 1.0
    transformOrigin: Item.Center

    Behavior on color { ColorAnimation { duration: Theme.animFast } }
    Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Theme.easeOut } }
    Behavior on border.width { NumberAnimation { duration: Theme.animFast } }
    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

    // Barrinha de destaque à esquerda quando selecionado via teclado
    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 3
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: parent.height * 0.5
        radius: 1.5
        color: Theme.accent
        opacity: root.selected ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        z: -1
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: compact ? 10 : 12
        anchors.rightMargin: compact ? 8 : 10
        spacing: compact ? 8 : 12

        // Ícone com anel sutil e fallback (letra) caso o tema não tenha um match
        Item {
            Layout.preferredWidth: compact ? 22 : 32
            Layout.preferredHeight: compact ? 22 : 32
            scale: hoverArea.containsMouse ? 1.08 : 1.0
            Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Theme.easeOut } }

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusSmall
                color: Theme.withAlpha(Theme.backgroundDeep, 0.6)
                border.width: 1
                border.color: Theme.withAlpha(Theme.accent, 0.25)
                visible: !compact
            }

            IconImage {
                id: icon
                anchors.fill: parent
                anchors.margins: compact ? 0 : 3
                source: root.entry && root.entry.icon ? Quickshell.iconPath(root.entry.icon, "") : ""
                visible: status === Image.Ready
            }

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusSmall
                visible: icon.status !== Image.Ready
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.accent }
                    GradientStop { position: 1.0; color: Theme.accentDim }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.entry && root.entry.name ? root.entry.name.charAt(0).toUpperCase() : "?"
                    color: Theme.textPrimary
                    font.bold: true
                    font.pixelSize: compact ? 11 : 14
                }
            }
        }

        // Nome + descrição curta (genericName, só no modo normal)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.entry ? root.entry.name : ""
                color: Theme.textPrimary
                font.pixelSize: compact ? Theme.fontSizeHint + 1 : Theme.fontSizeItem
                font.family: Theme.fontFamily
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: !compact && root.entry && !!root.entry.genericName
                text: root.entry ? root.entry.genericName : ""
                color: Theme.textSecondary
                font.pixelSize: Theme.fontSizeHint
                font.family: Theme.fontFamily
                elide: Text.ElideRight
            }
        }

        // Botão de fixar, com uma pequena "bounce" ao alternar
        Text {
            id: pinIcon
            text: root.entry && PinStore.isPinned(root.entry.id) ? "\u2605" : "\u2606"
            color: root.entry && PinStore.isPinned(root.entry.id) ? Theme.pinnedIndicator : Theme.textSecondary
            font.pixelSize: compact ? 13 : 18

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            SequentialAnimation {
                id: pinBounce
                NumberAnimation { target: pinIcon; property: "scale"; to: 1.4; duration: 90; easing.type: Easing.OutQuad }
                NumberAnimation { target: pinIcon; property: "scale"; to: 1.0; duration: 140; easing.type: Theme.easeBounce }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                onClicked: {
                    if (root.entry) {
                        PinStore.toggle(root.entry.id)
                        pinBounce.restart()
                    }
                }
            }
        }
    }
}
