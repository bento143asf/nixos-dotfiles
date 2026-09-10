pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: root

    // Base palette. Matugen replaces only the accent pair.
    property color accent: "#8FB7D9"
    property color accentText: "#15202B"

    readonly property color barBackground: "#161A22"
    readonly property color pillBackground: "#202631"
    readonly property color pillBackgroundHover: "#293140"
    readonly property color pillBackgroundPressed: "#303A4B"
    readonly property color popupBackground: "#1B202A"
    readonly property color popupSurface: "#232A36"
    readonly property color popupHover: "#2B3442"
    readonly property color trackBackground: "#343D4D"

    readonly property color textPrimary: "#F2F5F9"
    readonly property color textSecondary: "#B8C1CF"
    readonly property color textDim: "#778192"
    readonly property color textDisabled: "#566071"

    readonly property color success: "#A7C98B"
    readonly property color warning: "#E7C47A"
    readonly property color danger: "#D47782"

    readonly property int barHeight: 40
    readonly property int barMargin: 5
    readonly property int pillSpacing: 7
    readonly property int cornerRadius: 11
    readonly property int popupRadius: 15

    readonly property int animFast: 120
    readonly property int animMedium: 220
    readonly property int animSlow: 360
    readonly property int easeOut: Easing.OutCubic
    readonly property int easeIn: Easing.InCubic
    readonly property int easeSmooth: Easing.InOutCubic

    function withAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, Math.max(0, Math.min(1, alpha)))
    }

    function clamp(value, minValue, maxValue) {
        return Math.max(minValue, Math.min(maxValue, value))
    }

    property var matugenFile: FileView {
        id: matugenFile
        path: Quickshell.env("HOME") + "/.cache/quickshell/colors.json"
        watchChanges: true
        printErrors: false

        onLoaded: root.applyMatugen(text())
    }

    function applyMatugen(raw) {
        try {
            const data = JSON.parse(raw)
            if (data.accent)
                root.accent = data.accent
            if (data.accentText)
                root.accentText = data.accentText
        } catch (e) {
            // Keep the built-in fallback palette if matugen has not generated the file yet.
        }
    }
}
