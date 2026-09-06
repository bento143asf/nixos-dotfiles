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

    // ---- Frost (azuis Nord, também usados como "azul NixOS") ----
    readonly property color nixBlueLight: "#88C0D0"
    readonly property color nixBlue: "#81A1C1"
    readonly property color nixBlueDark: "#5E81AC"

    // ---- Acento extra (indicador de fixado) ----
    readonly property color accentYellow: "#EBCB8B"

    // ---- Papéis semânticos usados nos componentes ----
    readonly property color background: nord0
    readonly property color surface: nord1
    readonly property color surfaceHover: nord2
    readonly property color border: nord3
    readonly property color textPrimary: nord6
    readonly property color textSecondary: nord4
    readonly property color accent: nixBlueDark
    readonly property color accentHover: nixBlue
    readonly property color accentBright: nixBlueLight
    readonly property color pinnedIndicator: accentYellow

    // ---- Geometria (bordas arredondadas, meio-termo) ----
    readonly property int radiusWindow: 18
    readonly property int radiusItem: 10
    readonly property int radiusSmall: 6

    // ---- Tipografia ----
    readonly property string fontFamily: "sans-serif"
    readonly property int fontSizeInput: 16
    readonly property int fontSizeItem: 14
    readonly property int fontSizeHint: 11

    // ---- Durações de animação ----
    readonly property int animFast: 120
    readonly property int animMedium: 200
}
