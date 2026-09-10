import QtQuick
import QtQuick.Layouts

Item {
    id: root

    width: pill.width
    height: Colors.barHeight

    readonly property var monthNames: [
        "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
        "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
    ]
    readonly property var dayHeaders: ["D", "S", "T", "Q", "Q", "S", "S"]

    property date now: new Date()
    property int viewYear: now.getFullYear()
    property int viewMonth: now.getMonth()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    readonly property string timeText: {
        const h = root.now.getHours().toString().padStart(2, "0")
        const m = root.now.getMinutes().toString().padStart(2, "0")
        return h + ":" + m
    }

    readonly property string dateText: {
        const d = root.now.getDate().toString().padStart(2, "0")
        const m = (root.now.getMonth() + 1).toString().padStart(2, "0")
        return d + "/" + m
    }

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    function firstWeekday(year, month) {
        return new Date(year, month, 1).getDay()
    }

    readonly property var gridDays: {
        const days = []
        const offset = firstWeekday(viewYear, viewMonth)
        const count = daysInMonth(viewYear, viewMonth)

        for (let i = 0; i < offset; i++)
            days.push(0)
        for (let d = 1; d <= count; d++)
            days.push(d)
        while (days.length < 42)
            days.push(0)
        return days
    }

    function isToday(day) {
        const today = new Date()
        return day > 0 && viewYear === today.getFullYear() && viewMonth === today.getMonth() && day === today.getDate()
    }

    function previousMonth() {
        if (viewMonth === 0) {
            viewMonth = 11
            viewYear--
        } else {
            viewMonth--
        }
    }

    function nextMonth() {
        if (viewMonth === 11) {
            viewMonth = 0
            viewYear++
        } else {
            viewMonth++
        }
    }

    Rectangle {
        id: pill
        width: clockText.implicitWidth + dateTextLabel.implicitWidth + 42
        height: Colors.barHeight
        radius: Colors.cornerRadius
        color: hover.containsMouse ? Colors.pillBackgroundHover : Colors.pillBackground
        border.width: 1
        border.color: calendarPopup.visible
            ? Colors.withAlpha(Colors.accent, 0.45)
            : Colors.withAlpha(Colors.textPrimary, 0.055)

        Behavior on color { ColorAnimation { duration: Colors.animFast } }
        Behavior on border.color { ColorAnimation { duration: Colors.animFast } }

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                id: clockText
                text: root.timeText
                color: Colors.textPrimary
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }

            Rectangle {
                width: 1
                height: 14
                radius: 0.5
                color: Colors.withAlpha(Colors.textSecondary, 0.20)
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: dateTextLabel
                text: root.dateText
                color: Colors.textSecondary
                font.pixelSize: 10
                font.weight: Font.Medium
            }
        }

        scale: hover.containsMouse ? 1.015 : 1
        Behavior on scale { NumberAnimation { duration: Colors.animFast; easing.type: Colors.easeOut } }

        MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.viewYear = root.now.getFullYear()
                root.viewMonth = root.now.getMonth()
                calendarPopup.open()
            }
        }
    }

    Popup {
        id: calendarPopup
        centered: true
        topOffset: Colors.barHeight + Colors.barMargin + 11

        Rectangle {
            width: 390
            implicitHeight: calendarContent.implicitHeight + 36
            radius: Colors.popupRadius + 1
            color: Colors.popupBackground
            border.width: 1
            border.color: Colors.withAlpha(Colors.textPrimary, 0.075)

            ColumnLayout {
                id: calendarContent
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: root.monthNames[root.viewMonth]
                            color: Colors.textPrimary
                            font.pixelSize: 17
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: root.viewYear
                            color: Colors.textDim
                            font.pixelSize: 10
                        }
                    }

                    Row {
                        spacing: 4

                        Rectangle {
                            width: 34
                            height: 34
                            radius: 9
                            color: previousHover.containsMouse ? Colors.popupHover : Colors.popupSurface
                            Behavior on color { ColorAnimation { duration: Colors.animFast } }
                            Text {
                                anchors.centerIn: parent
                                text: "‹"
                                color: previousHover.containsMouse ? Colors.accent : Colors.textSecondary
                                font.pixelSize: 24
                            }
                            MouseArea {
                                id: previousHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.previousMonth()
                            }
                        }

                        Rectangle {
                            width: 34
                            height: 34
                            radius: 9
                            color: nextHover.containsMouse ? Colors.popupHover : Colors.popupSurface
                            Behavior on color { ColorAnimation { duration: Colors.animFast } }
                            Text {
                                anchors.centerIn: parent
                                text: "›"
                                color: nextHover.containsMouse ? Colors.accent : Colors.textSecondary
                                font.pixelSize: 24
                            }
                            MouseArea {
                                id: nextHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.nextMonth()
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Colors.withAlpha(Colors.textPrimary, 0.055)
                }

                GridLayout {
                    columns: 7
                    Layout.fillWidth: true
                    rowSpacing: 5
                    columnSpacing: 5

                    Repeater {
                        model: root.dayHeaders
                        delegate: Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 22
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: Colors.textDim
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                            }
                        }
                    }

                    Repeater {
                        model: root.gridDays
                        delegate: Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38

                            Rectangle {
                                anchors.centerIn: parent
                                width: 34
                                height: 34
                                radius: 10
                                color: root.isToday(modelData)
                                    ? Colors.accent
                                    : (dayHover.containsMouse && modelData > 0 ? Colors.popupHover : "transparent")
                                Behavior on color { ColorAnimation { duration: Colors.animFast } }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData > 0 ? modelData : ""
                                color: root.isToday(modelData)
                                    ? Colors.accentText
                                    : Colors.textPrimary
                                font.pixelSize: 11
                                font.weight: root.isToday(modelData) ? Font.DemiBold : Font.Normal
                            }

                            MouseArea {
                                id: dayHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: modelData > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 34
                    radius: 9
                    color: todayHover.containsMouse ? Colors.popupHover : Colors.popupSurface
                    Behavior on color { ColorAnimation { duration: Colors.animFast } }

                    Text {
                        anchors.centerIn: parent
                        text: "Voltar para hoje"
                        color: Colors.textSecondary
                        font.pixelSize: 10
                    }

                    MouseArea {
                        id: todayHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.viewYear = root.now.getFullYear()
                            root.viewMonth = root.now.getMonth()
                        }
                    }
                }
            }
        }
    }
}
