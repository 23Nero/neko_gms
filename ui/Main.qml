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
    color: "#21252b"

    property color panelColor: "#282c34"
    property color panelAccentColor: "#353b45"
    property color dividerColor: "#3e4451"
    property color textPrimary: "#abb2bf"
    property color textSecondary: "#5c6370"
    property font iconFont: Qt.font({ family: "Segoe Fluent Icons", pointSize: 16 })
    property bool filterPanelVisible: true
    property string deviceStatusText: qsTr("No device")

    function fetchUsbDevices() {
        console.log("Requesting USB device information")
        deviceStatusText = qsTr("USB: scanning...")
        // TODO: integrate with native backend to query actual USB devices.
        // For now we provide a placeholder message.
        Qt.callLater(() => deviceStatusText = qsTr("USB: no data"))
    }

    header: HeaderToolbar {
        panelAccentColor: root.panelAccentColor
        textPrimary: root.textPrimary
        iconFont: root.iconFont
        onActionTriggered: function(action) {
            if (action === "toggleFilter") {
                root.filterPanelVisible = !root.filterPanelVisible
            } else if (action === "showDevices") {
                root.fetchUsbDevices()
            }
        }
    }

    footer: StatusBar {
        panelColor: root.panelColor
        dividerColor: root.dividerColor
        textSecondary: root.textSecondary
        iconFont: root.iconFont
        fileLabel: qsTr("File: demo.log")
        lineLabel: qsTr("Line: None")
        formatLabel: qsTr("Format: ADB Log")
        deviceCountLabel: qsTr("Devices: 0")
        deviceStatusLabel: root.deviceStatusText
        trackTailChecked: true
        trackTailLabel: qsTr("Track Tail")
        zoomLabel: qsTr("Zoom: %1%").arg(Math.round(logView.zoomFactor * 100))
        rightExtras: Component {
            RowLayout {
                spacing: 8

                ToolButton {
                    implicitWidth: 26
                    implicitHeight: 26
                    background: Rectangle {
                        radius: 4
                        color: pressed ? "#3f4754" : hovered ? "#3a404c" : "transparent"
                        border.color: hovered ? "#4b5261" : "transparent"
                    }
                    contentItem: Label {
                        text: "\uE71F" // zoom out
                        color: root.textPrimary
                        font.family: root.iconFont.family
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: logView.zoomOut()
                }

                ToolButton {
                    implicitWidth: 26
                    implicitHeight: 26
                    background: Rectangle {
                        radius: 4
                        color: pressed ? "#3f4754" : hovered ? "#3a404c" : "transparent"
                        border.color: hovered ? "#4b5261" : "transparent"
                    }
                    contentItem: Label {
                        text: "\uE8A3" // zoom in
                        color: root.textPrimary
                        font.family: root.iconFont.family
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: logView.zoomIn()
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        FilterPanel {
            id: filterPanel
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? implicitHeight : 0
            Layout.minimumHeight: 0
            Layout.maximumHeight: visible ? implicitHeight : 0
            visible: root.filterPanelVisible
            panelColor: root.panelColor
            dividerColor: root.dividerColor
            textPrimary: root.textPrimary
            textSecondary: root.textSecondary
            iconFont: root.iconFont
        }
        LogView {
            id: logView
            Layout.fillWidth: true
            Layout.fillHeight: true
            panelColor: "#1e2127"
            dividerColor: root.dividerColor
            textPrimary: root.textPrimary
            textSecondary: root.textSecondary
            source: "logs/test.log"
        }
    }
}
