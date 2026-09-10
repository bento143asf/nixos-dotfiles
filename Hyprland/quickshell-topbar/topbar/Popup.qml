import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    default property alias data: wrapper.data

    property bool anchorLeft: false
    property bool anchorRight: false
    property bool centered: false
    property int topOffset: Colors.barHeight + Colors.barMargin + 9

    visible: false
    color: "transparent"

    implicitWidth: wrapper.implicitWidth
    implicitHeight: wrapper.implicitHeight

    anchors {
        top: !centered
        left: centered ? false : anchorLeft
        right: centered ? false : anchorRight
    }

    margins.top: centered ? 0 : topOffset
    margins.left: (!centered && anchorLeft) ? Colors.barMargin + 4 : 0
    margins.right: (!centered && anchorRight) ? Colors.barMargin + 4 : 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-bar-popup"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    function open() {
        if (root.visible) {
            wrapper.forceActiveFocus()
            return
        }

        root.visible = true
        wrapper.opacity = 0
        wrapper.scale = 0.96
        entrance.restart()
        Qt.callLater(() => wrapper.forceActiveFocus())
    }

    function close() {
        if (!root.visible || exit.running)
            return
        exit.restart()
    }

    Item {
        id: wrapper

        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
        width: implicitWidth
        height: implicitHeight
        opacity: 0
        scale: 0.96
        transformOrigin: Item.Top
        focus: true

        Keys.onEscapePressed: root.close()

        ParallelAnimation {
            id: entrance

            NumberAnimation {
                target: wrapper
                property: "opacity"
                from: 0
                to: 1
                duration: Colors.animMedium
                easing.type: Colors.easeOut
            }
            NumberAnimation {
                target: wrapper
                property: "scale"
                from: 0.96
                to: 1
                duration: Colors.animMedium
                easing.type: Colors.easeOut
            }
        }

        ParallelAnimation {
            id: exit

            NumberAnimation {
                target: wrapper
                property: "opacity"
                from: wrapper.opacity
                to: 0
                duration: Colors.animFast
                easing.type: Colors.easeIn
            }
            NumberAnimation {
                target: wrapper
                property: "scale"
                from: wrapper.scale
                to: 0.96
                duration: Colors.animFast
                easing.type: Colors.easeIn
            }

            onFinished: {
                root.visible = false
                wrapper.opacity = 0
                wrapper.scale = 0.96
            }
        }
    }
}
