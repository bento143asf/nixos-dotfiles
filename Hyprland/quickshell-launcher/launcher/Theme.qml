pragma Singleton
import QtQuick

QtObject {
    // ---- Paleta Nord (base) ----
    readonly property color nord0: "#2E3440"
    readonly property color nord1: "#3B4252"
    readonly property color nord2: "#434C5E"
    readonly property color nord3: "#4C566A"
    readonly property color nord4: "#D8DEE9"
    readonly property color nord6: "#ECEFF4"

    // ---- Azuis (Frost do Nord + tom do logo do NixOS) ----
    readonly property color nixBlueLight: "#88C0D0"   // frost claro
    readonly property color nixBlue: "#7EBAE4"         // azul NixOS
    readonly property color nixBlueDark: "#5277C3"     // azul NixOS mais profundo
    readonly property color nixBluePale: "#81A1C1"     // frost intermediário

    // ---- Acento extra (indicador de fixado) ----
    readonly property color accentYellow: "#EBCB8B"

    // ---- Papéis semânticos ----
    readonly property color background: "#242A36"
    readonly property color backgroundDeep: "#1B202B"
    readonly property color surface: "#323A4A"
    readonly property color surfaceHover: "#3D4759"
    readonly property color border: nixBlueDark
    readonly property color textPrimary: nord6
    readonly property color textSecondary: nord4
    readonly property color accent: nixBlue
    readonly property color accentHover: nixBlueLight
    readonly property color accentDim: nixBlueDark
    readonly property color pinnedIndicator: accentYellow

    // ---- Transparência da janela (95% sólido / 5% transparente) ----
    readonly property real windowOpacity: 0.95

    function withAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }

    // ---- Geometria (bordas arredondadas, meio-termo) ----
    readonly property int radiusWindow: 22
    readonly property int radiusItem: 12
    readonly property int radiusSmall: 8

    // ---- Tipografia ----
    readonly property string fontFamily: "sans-serif"
    readonly property int fontSizeInput: 16
    readonly property int fontSizeItem: 14
    readonly property int fontSizeHint: 11

    // ---- Durações e curvas de animação ----
    readonly property int animFast: 130
    readonly property int animMedium: 220
    readonly property int easeOut: Easing.OutCubic
    readonly property int easeIn: Easing.InCubic
    readonly property int easeBounce: Easing.OutBack
}
