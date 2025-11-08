import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: filterPanel
    width: 900 // Bạn có thể điều chỉnh chiều rộng
    implicitHeight: mainLayout.implicitHeight + 20
    color: "#282c34" // One Dark base panel
    antialiasing: true

    // --- Định nghĩa màu sắc chung ---
    property color textColor: "#abb2bf"
    property color textSecondaryColor: "#5c6370"
    property color borderColor: "#3e4451"
    property color inputBgColor: "#21252b"
    property color highlightGreen: "#98c379"
    property color highlightPurple: "#c678dd"
    property font iconFont: Qt.font({ family: "Segoe Fluent Icons", pointSize: 16 })
    property alias panelColor: filterPanel.color
    property alias dividerColor: filterPanel.borderColor
    property alias textPrimary: filterPanel.textColor
    property alias textSecondary: filterPanel.textSecondaryColor

    // --- Component TextField tùy chỉnh ---
    component CustomTextField: TextField {
        background: Rectangle {
            color: inputBgColor
            border.color: parent.activeFocus ? "white" : borderColor
            radius: 4
        }
        color: textColor
        placeholderTextColor: "#AAAAAA"
        Layout.preferredHeight: 32
        leftPadding: 8
        rightPadding: 8
    }

    // --- Component ComboBox tùy chỉnh ---
    component CustomComboBox: ComboBox {
        id: comboControl
        Layout.preferredHeight: 32
        property color borderColorOverride: borderColor
        property bool highlightOnOpen: false
        property color highlightBorderColor: highlightGreen
        property int borderWidthOverride: 1
        background: Rectangle {
            color: inputBgColor
            border.width: comboControl.highlightOnOpen && comboControl.popup.visible
                          ? 2
                          : comboControl.borderWidthOverride
            border.color: comboControl.highlightOnOpen && comboControl.popup.visible
                          ? comboControl.highlightBorderColor
                          : comboControl.borderColorOverride
            radius: 4
        }
        contentItem: Label {
            text: comboControl.displayText
            color: textColor
            leftPadding: 8
            rightPadding: 28
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        indicator: Item {
            width: 28
            height: comboControl.height
            anchors.right: parent.right
            Label {
                anchors.centerIn: parent
                text: "\u25BE" // Ký tự mũi tên xuống
                color: textColor
            }
            TapHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchScreen | PointerDevice.Stylus
                enabled: comboControl.enabled
                onTapped: comboControl.popup.open()
                cursorShape: Qt.PointingHandCursor
            }
        }
        popup: Popup {
            y: comboControl.height
            width: comboControl.width
            padding: 4
            background: Rectangle {
                color: inputBgColor
                border.color: borderColor
            }
            contentItem: ListView {
                model: comboControl.delegateModel
                delegate: ItemDelegate {
                    width: parent.width
                    text: modelData
                    highlighted: ListView.isCurrentItem
                    background: Rectangle {
                        color: highlighted ? "#0078d7" : "transparent"
                    }
                    contentItem: Text {
                        text: modelData
                        color: textColor
                        font: comboControl.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                        rightPadding: 8
                    }
                    
                    // Sửa lỗi dropdown không hoạt động
                    onClicked: {
                        comboControl.currentIndex = index
                        comboControl.displayText = modelData
                        comboControl.popup.close()
                    }
                }
            }
        }
    }

    // --- Bố cục chính ---
    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 10
        spacing: 12

        // --- Hàng 1: Các điều khiển chính ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Nút "Verbose" (đã là listdown / ComboBox)
            CustomComboBox {
                id: logLevelCombo
                model: ["Verbose", "Debug", "Info", "Warning", "Error", "Fatal"]
                currentIndex: 0
                Layout.preferredWidth: 120
            }

            // "Process Filter" (văn bản)
            Label {
                text: qsTr("Process Filter:")
                color: textSecondaryColor
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }

            // THAY ĐỔI: Chuyển ':disabled' thành ComboBox (listdown)
            CustomComboBox {
                id: disabledFilterCombo
                // Bạn có thể thay đổi model này cho phù hợp
                model: [":disabled", ":enabled", "item 3", "item 4"] 
                currentIndex: 0 // Hiển thị ":disabled" làm mặc định
                Layout.preferredWidth: 120 // Điều chỉnh độ rộng
                borderColorOverride: highlightGreen
                borderWidthOverride: 2
                highlightOnOpen: true
            }
            
            // Nút chuyển "OR" / "AND"
            Button {
                id: logicSwitch
                property bool isOr: true 
                text: isOr ? "OR" : "AND"
                Layout.preferredWidth: 70
                Layout.preferredHeight: 32
                onClicked: isOr = !isOr 

                background: Rectangle { // Viền tím
                    color: inputBgColor
                    border.color: highlightPurple
                    border.width: 2
                    radius: 4
                }
                contentItem: Label {
                    text: logicSwitch.text
                    color: textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            CustomTextField {
                id: tagFilter
                placeholderText: qsTr("Tag Filter")
                Layout.fillWidth: true // Lấp đầy không gian còn lại
            }
        }

        // --- Hàng 2: Inclusive Filter ---
        Rectangle { Layout.fillWidth: true; height: 1; color: borderColor }
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Label {
                    text: qsTr("Inclusive Filter:")
                    color: textSecondaryColor
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }

                CustomTextField {
                    id: inclusiveFilter
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Label {
                    text: qsTr("Exclusive Filter:")
                    color: textSecondaryColor
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }

                CustomTextField {
                    id: exclusiveFilter
                    Layout.fillWidth: true
                }
            }
        }
        
        // --- Hàng 4: Highlights ---
        Rectangle { Layout.fillWidth: true; height: 1; color: borderColor }
        ListModel {
            id: highlightModel
            ListElement { hexColor: "#61afef"; text: "" } // Info
            ListElement { hexColor: "#98c379"; text: "" } // Debug
            ListElement { hexColor: "#c678dd"; text: "" } // Verbose
            ListElement { hexColor: "#e06c75"; text: "" } // Error
            ListElement { hexColor: "#e5c07b"; text: "" } // Warning
            ListElement { hexColor: "#d19a66"; text: "" } // Secondary
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: qsTr("Highlights:")
                color: textSecondaryColor
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }

            RowLayout {
                id: highlightRow
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: highlightModel
                    delegate: RowLayout {
                        spacing: 6
                        Layout.fillWidth: true

                        Rectangle {
                            width: 30
                            height: 24
                            color: model.hexColor
                            border.color: model.hexColor === "#ffffff" ? "#AAAAAA" : "transparent"
                            radius: 4
                            antialiasing: true
                        }

                        CustomTextField {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 120
                            placeholderText: qsTr("Text")
                            text: model.text
                            onTextChanged: highlightModel.setProperty(index, "text", text)
                        }
                    }
                }
            }
        }
    }
}