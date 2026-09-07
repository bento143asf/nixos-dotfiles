pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: root

    // Lista de IDs (desktop-file id) dos apps fixados
    property var pinned: []

    property FileView _file: FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/launcher/pinned.json"

        onLoaded: {
            try {
                const parsed = JSON.parse(text())
                root.pinned = Array.isArray(parsed) ? parsed : []
            } catch (e) {
                root.pinned = []
            }
        }

        // Arquivo ainda não existe na primeira execução: cria vazio
        onLoadFailed: (error) => {
            root.pinned = []
            setText("[]")
        }
    }

    function isPinned(id) {
        return root.pinned.indexOf(id) !== -1
    }

    function toggle(id) {
        const arr = root.pinned.slice()
        const idx = arr.indexOf(id)
        if (idx === -1) arr.push(id)
        else arr.splice(idx, 1)
        root.pinned = arr
        _file.setText(JSON.stringify(arr, null, 2))
    }
}
