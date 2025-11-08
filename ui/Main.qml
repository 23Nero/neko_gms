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
        anchors.margins: 12
        spacing: 12
        FilterPanel {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            panelColor: root.panelColor
            dividerColor: root.dividerColor
            textPrimary: root.textPrimary
            textSecondary: root.textSecondary
            iconFont: root.iconFont
        }
        LogView {
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