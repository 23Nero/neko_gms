import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

ApplicationWindow {
    id: root
    width: 1280
    height: 720
    visible: true
    title: qsTr("Neko Viewer")
    color: "#0a1120"

    property color panelColor: "#101c33"
    property color panelAccentColor: "#1a2946"
    property color dividerColor: "#1f3354"
    property color textPrimary: "#e9f2ff"
    property color textSecondary: "#8fa8c9"
    property font iconFont: Qt.font({ family: "Segoe Fluent Icons", pointSize: 16 })

    ListModel {
        id: logModel
        ListElement { time: "12-15 14:23:45.103"; pid: "1234"; tid: "5678"; level: "I"; tag: "MainActivity"; message: "Application started" }
        ListElement { time: "12-15 14:23:45.236"; pid: "1234"; tid: "5678"; level: "D"; tag: "NetworkManager"; message: "Connecting to server" }
        ListElement { time: "12-15 14:23:46.179"; pid: "1234"; tid: "5678"; level: "E"; tag: "NetworkManager"; message: "Failed to connect: Network unreachable" }
        ListElement { time: "12-15 14:23:47.065"; pid: "1234"; tid: "5678"; level: "I"; tag: "MainActivity"; message: "User logged in successfully" }
        ListElement { time: "12-15 14:23:48.095"; pid: "1234"; tid: "5678"; level: "D"; tag: "DatabaseHelper"; message: "Query executed in 45ms" }
        ListElement { time: "12-15 14:23:49.093"; pid: "1234"; tid: "5678"; level: "V"; tag: "CacheManager"; message: "Cache hit for key: user_profile" }
        ListElement { time: "12-15 14:23:51.567"; pid: "1234"; tid: "5678"; level: "W"; tag: "MemoryManager"; message: "Memory usage at 85%" }
        ListElement { time: "12-15 14:23:52.134"; pid: "1234"; tid: "5678"; level: "E"; tag: "FileManager"; message: "Failed to read file: /data/config.json" }
        ListElement { time: "12-15 14:23:53.221"; pid: "1234"; tid: "5678"; level: "I"; tag: "NotificationService"; message: "Notification sent to user" }
        ListElement { time: "12-15 14:23:53.822"; pid: "1234"; tid: "5678"; level: "D"; tag: "LocationService"; message: "GPS location updated" }
        ListElement { time: "12-15 14:23:54.456"; pid: "1234"; tid: "5678"; level: "F"; tag: "CrashHandler"; message: "Fatal error: NullPointerException" }
    }

    header: HeaderToolbar {
        panelAccentColor: root.panelAccentColor
        textPrimary: root.textPrimary
        iconFont: root.iconFont
    }

    footer: StatusBar {
        panelColor: root.panelColor
        dividerColor: root.dividerColor
        textSecondary: root.textSecondary
        fileLabel: qsTr("File: sample.log")
        lineLabel: qsTr("Line 1 / 12")
        formatLabel: qsTr("Format: ADB Log")
        deviceCountLabel: qsTr("Devices: 0")
        deviceStatusLabel: qsTr("No device")
        trackTailChecked: true
        trackTailLabel: qsTr("Track Tail")
        zoomLabel: qsTr("Zoom: 100%")

    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: header.height
        anchors.margins: 24
        spacing: 16

        Rectangle {
            Layout.fillWidth: true
            color: panelColor
            radius: 12
            border.color: dividerColor

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: qsTr("sample.log")
                        color: textPrimary
                        font.pointSize: 18
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Label {
                        text: qsTr("Modified at 11/08/2025, 2:39:21 PM")
                        color: textSecondary
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    TextField {
                        Layout.fillWidth: true
                        placeholderText: qsTr("Search logs...")
                        color: textPrimary
                        placeholderTextColor: "#4d6a92"
                        background: Rectangle {
                            radius: 10
                            color: "#0f1a30"
                            border.color: "#183052"
                        }
                        leftPadding: 12
                        rightPadding: 12
                    }

                    RowLayout {
                        spacing: 8
                        Repeater {
                            model: ["\uE70B", "\uE70A", "\uE74A", "\uE74B"]
                            delegate: ToolButton {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                background: Rectangle {
                                    radius: 10
                                    color: pressed ? "#28426a" : hovered ? "#22365a" : "#0f1a30"
                                    border.color: "#1f3658"
                                }
                                contentItem: Label {
                                    text: modelData
                                    font: iconFont
                                    color: textPrimary
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Label {
                        text: qsTr("Logs")
                        color: textPrimary
                        font.bold: true
                    }

                    CheckBox {
                        text: qsTr("Alternate colors")
                        checked: true
                        indicator: Rectangle {
                            implicitWidth: 18
                            implicitHeight: 18
                            radius: 4
                            color: control.checked ? "#4477ff" : "transparent"
                            border.color: "#4477ff"
                        }
                        contentItem: Label {
                            text: control.text
                            color: textSecondary
                        }
                    }

                    RowLayout {
                        spacing: 8
                        Repeater {
                            model: ["Time", "UID", "PID", "TID", "Level", "Tag"]
                            delegate: Button {
                                text: modelData
                                Layout.preferredHeight: 32
                                Layout.preferredWidth: 64
                                font.capitalization: Font.MixedCase
                                background: Rectangle {
                                    radius: 8
                                    color: checked ? "#2f4f87" : "#0f1a30"
                                    border.color: "#1f3658"
                                }
                                checkable: true
                                checked: index <= 3
                                contentItem: Label {
                                    text: control.text
                                    color: textSecondary
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: 10
                        Rectangle {
                            radius: 10
                            color: "#0f1a30"
                            border.color: "#183052"
                            height: 40
                            width: 260
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                Label {
                                    text: qsTr("January 14th, 2025 18:38:16")
                                    color: textSecondary
                                }
                                Label {
                                    text: qsTr(" - ")
                                    color: textSecondary
                                }
                                Label {
                                    text: qsTr("October 14th, 2025 21:32:49")
                                    color: textSecondary
                                }
                            }
                        }
                        Button {
                            text: qsTr("Apply")
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 90
                            background: Rectangle {
                                radius: 10
                                color: "#3762ff"
                            }
                            contentItem: Label {
                                text: control.text
                                color: textPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        ToolButton {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            background: Rectangle {
                                radius: 10
                                color: "#0f1a30"
                                border.color: "#1f3658"
                            }
                            contentItem: Label {
                                text: "\uE713"
                                font: iconFont
                                color: textPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: "#0d192d"
            border.color: dividerColor

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    height: 34
                    radius: 8
                    color: "#101c33"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 24

                        Label { text: qsTr("Time"); color: textSecondary; Layout.preferredWidth: 170 }
                        Label { text: qsTr("PID"); color: textSecondary; Layout.preferredWidth: 60 }
                        Label { text: qsTr("TID"); color: textSecondary; Layout.preferredWidth: 60 }
                        Label { text: qsTr("Level"); color: textSecondary; Layout.preferredWidth: 60 }
                        Label { text: qsTr("Tag"); color: textSecondary; Layout.preferredWidth: 160 }
                        Label { text: qsTr("Message"); color: textSecondary; Layout.fillWidth: true }
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 0
                    model: logModel

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 32
                        color: index % 2 ? "#0f1c32" : "#101f36"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 24

                            Label { text: time; color: textPrimary; Layout.preferredWidth: 170 }
                            Label { text: pid; color: textPrimary; Layout.preferredWidth: 60 }
                            Label { text: tid; color: textPrimary; Layout.preferredWidth: 60 }
                            Label {
                                text: level
                                color: level === "E" || level === "F" ? "#ff6b6b" : "#74d0ff"
                                Layout.preferredWidth: 60
                                font.bold: true
                            }
                            Label { text: tag; color: textPrimary; Layout.preferredWidth: 160; elide: Text.ElideRight }
                            Label { text: message; color: textSecondary; Layout.fillWidth: true; elide: Text.ElideRight }
                        }
                    }
                }
            }
        }

    }
}