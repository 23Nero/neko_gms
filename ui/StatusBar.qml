import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    id: statusBar

    // Exposed palette and content properties so the parent can override them.
    property color panelColor: "#282c34"
    property color dividerColor: "#3e4451"
    property color textSecondary: "#5c6370"

    property string fileLabel: qsTr("File: sample.log")
    property string lineLabel: qsTr("Line 1 / 12")
    property string formatLabel: qsTr("Format: ADB Log")
    property string deviceCountLabel: qsTr("Devices: 0")
    property string deviceStatusLabel: qsTr("No device")
    property bool trackTailChecked: true
    property string trackTailLabel: qsTr("Track Tail")
    property string zoomLabel: qsTr("Zoom: 100%")

    implicitHeight: 30
    contentHeight: implicitHeight

    background: Rectangle {
        color: panelColor
    }

    contentItem: Item {
        anchors.fill: parent

        // ----- NHÓM BÊN TRÁI -----
        // Một RowLayout neo (anchor) vào bên trái
        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter // Tự động căn giữa
            spacing: 12

            Label {
                text: statusBar.fileLabel
                color: textSecondary
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: statusBar.contentHeight
            }

            Rectangle {
                implicitWidth: 2
                implicitHeight: 14
                color: dividerColor
                Layout.alignment: Qt.AlignVCenter
            }

            Label {
                text: statusBar.lineLabel
                color: textSecondary
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: statusBar.contentHeight
            }

            Rectangle {
                implicitWidth: 2
                implicitHeight: 14
                color: dividerColor
                Layout.alignment: Qt.AlignVCenter
            }

            Label {
                text: statusBar.formatLabel
                color: textSecondary
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: statusBar.contentHeight
            }

            Rectangle {
                implicitWidth: 2
                implicitHeight: 14
                color: dividerColor
                Layout.alignment: Qt.AlignVCenter
            }

            Label {
                text: statusBar.deviceCountLabel
                color: textSecondary
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: statusBar.contentHeight
            }

            Rectangle {
                implicitWidth: 2
                implicitHeight: 14
                color: dividerColor
                Layout.alignment: Qt.AlignVCenter
            }

            Label {
                text: statusBar.deviceStatusLabel
                color: textSecondary
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: statusBar.contentHeight
            }
        } // Hết RowLayout (nhóm trái)

        // ----- NHÓM BÊN PHẢI -----
        // Một RowLayout khác neo (anchor) vào bên phải
        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter // Tự động căn giữa
            spacing: 12

            // Thêm Label "Track Tail" (như giải pháp trước)
            Label {
                text: statusBar.trackTailLabel
                color: textSecondary
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: statusBar.contentHeight
            }

            // Switch (không có text, không có contentItem)
            Switch {
                id: trackTail
                checked: statusBar.trackTailChecked
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: statusBar.contentHeight

                text: "" // Text rỗng

                // Tùy chỉnh `indicator`
                indicator: Rectangle {
                    implicitWidth: 30
                    implicitHeight: 16
                    radius: height / 2
                    color: trackTail.checked ? "#61afef" : "#3e4451"
                    border.color: trackTail.checked ? "#61afef" : "#4b5261"
                    y: (parent.height - height) / 2
                    layer.enabled: true
                    layer.smooth: true

                    // Hiệu ứng chuyển màu
                    Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                    Behavior on border.color { ColorAnimation { duration: 180; easing.type: Easing.InOutQuad } }

                    // Núm gạt
                    Rectangle {
                        width: 12
                        height: 12
                        radius: height / 2
                        anchors.verticalCenter: parent.verticalCenter
                        x: trackTail.checked ? parent.width - width - 2 : 2
                        color: "#abb2bf"
                        border.color: trackTail.checked ? "#61afef" : "#4b5261"
                        opacity: hoverHandler.hovered ? 0.94 : 1.0

                        Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.InOutQuad } }
                        Behavior on border.color { ColorAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                    }

                    // Khai báo MouseArea SAU CÙNG để nó nằm TRÊN CÙNG
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: trackTail.checked = !trackTail.checked
                        hoverEnabled: true
                    }

                    HoverHandler {
                        id: hoverHandler
                    }
                }
                
                onToggled: statusBar.trackTailChecked = checked
            }

            // Label "Zoom" (Bây giờ là item cuối cùng của nhóm bên phải)
            Label {
                text: statusBar.zoomLabel
                color: textSecondary
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: statusBar.contentHeight
            }
        } // Hết RowLayout (nhóm phải)
    } // Hết contentItem
}