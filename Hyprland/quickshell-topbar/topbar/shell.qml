import Quickshell
import QtQuick

ShellRoot {
    Bar {}

    // Keeps brightness monitoring alive even though the brightness control
    // is no longer a permanent bar module. External brightnessctl changes
    // are therefore reflected in the Windows-like OSD.
    Brightness {
        visible: false
    }
}
