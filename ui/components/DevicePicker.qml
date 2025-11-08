import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: popup

    property var manager: null
    property color backgroundColor: "#2c313c"
    property color borderColor: "#3e4451"
    property color textPrimary: "#abb2bf"
    property color textSecondary: "#5c6370"
    property color accentColor: "#61afef"
    property color highlightColor: "#353b45"

    readonly property int deviceCount: manager ? manager.deviceCount : 0
    readonly property bool busy: manager ? manager.busy : false

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside | Popup.CloseOnPressOutsideParent
    anchors.centerIn: Overlay.overlay
    padding: 0

    background: Rectangle {
        color: backgroundColor
        radius: 14
        border.color: borderColor
        border.width: 1
    }

    property bool reopenOnUpdates: false

    function openAndRefresh() {
        reopenOnUpdates = true
        if (!opened)
        {
            open()
        }
        if (manager)
        {
            manager.requestDevices()
        }
    }

    onClosed: reopenOnUpdates = false

    contentItem: Item {
        implicitWidth: 360
        implicitHeight: column.implicitHeight + 32

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            ColumnLayout {
                spacing: 6

                Label {
                    text: qsTr("Select Device")
                    color: popup.textPrimary
                    font.pixelSize: 20
                    font.bold: true
                }

                Label {
                    text: deviceCount > 0
                          ? qsTr("%1 devices connected").arg(deviceCount)
                          : qsTr("No devices detected yet")
                    color: popup.textSecondary
                    font.pixelSize: 13
                }
            }

            Rectangle {
                visible: busy
                Layout.fillWidth: true
                radius: 8
                color: highlightColor
                border.color: borderColor
                implicitHeight: 72

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    BusyIndicator {
                        running: true
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: 28
                    }

                    Label {
                        text: manager ? manager.statusMessage : qsTr("Scanning devices…")
                        color: popup.textPrimary
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                }
            }

            ScrollView {
                visible: !busy && deviceCount > 0
                Layout.fillWidth: true
                Layout.preferredHeight: {
                    const rows = Math.min(deviceCount, 5)
                    return rows * 64
                }
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ListView {
                    id: deviceList
                    width: parent.width
                    model: manager ? manager.devices : []
                    spacing: 6

                    delegate: ItemDelegate {
                        id: delegateControl
                        required property var modelData
                        width: ListView.view.width
                        implicitHeight: 60
                        padding: 12
                        hoverEnabled: true

                        background: Rectangle {
                            radius: 10
                            color: delegateControl.pressed
                                   ? "#3f4754"
                                   : delegateControl.hovered
                                         ? "#3a404c"
                                         : (manager && manager.selectedDeviceId === delegateControl.modelData.id
                                                ? highlightColor
                                                : "transparent")
                            border.color: manager && manager.selectedDeviceId === delegateControl.modelData.id
                                          ? accentColor
                                          : "transparent"
                        }

                        contentItem: ColumnLayout {
                            anchors.fill: parent
                            spacing: 4

                            Label {
                                text: modelData.name || modelData.id
                                color: popup.textPrimary
                                font.bold: manager && manager.selectedDeviceId === modelData.id
                                elide: Text.ElideRight
                            }

                            Label {
                                text: qsTr("%1 • %2")
                                          .arg(modelData.type || qsTr("unknown"))
                                          .arg(modelData.status || qsTr("unknown"))
                                color: popup.textSecondary
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }
                        }

                        onClicked: {
                            if (manager) {
                                manager.setSelectedDevice(modelData.id)
                            }
                            popup.close()
                        }
                    }
                }
            }

            Label {
                visible: !busy && deviceCount === 0
                text: manager ? manager.statusMessage : qsTr("Waiting for devices…")
                color: popup.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Refresh")
                    enabled: !busy
                    onClicked: {
                        if (manager) {
                            manager.requestDevices()
                        }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Close")
                    onClicked: popup.close()
                }
            }
        }
    }

    Connections {
        target: manager
        function onDeviceListUpdated() {
            if (reopenOnUpdates && !popup.opened) {
                popup.open()
            }
            reopenOnUpdates = false
        }

        function onDeviceQueryFailed(message) {
            reopenOnUpdates = false
            if (!popup.opened) {
                popup.open()
            }
        }
    }
}
