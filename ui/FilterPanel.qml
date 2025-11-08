// THÊM NHỮNG DÒNG NÀY:
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: filterPanel
    width: 900 // Bạn có thể điều chỉnh chiều rộng
    implicitHeight: mainLayout.implicitHeight + 20
    color: "#3c3c3c" // Màu nền xám tối
    antialiasing: true

    // --- Định nghĩa màu sắc chung ---
    property color textColor: "#FFFFFF"
    property color textSecondaryColor: "#DDDDDD"
    property color borderColor: "#555555"
    property color inputBgColor: "#2a2a2a"
    property color highlightGreen: "#33ff33"
    property color highlightPurple: "#9933ff"
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
        Layout.preferredHeight: 32
        background: Rectangle {
            color: inputBgColor
            border.color: borderColor
            radius: 4
        }
        contentItem: Label {
            text: control.displayText
            color: textColor
            leftPadding: 8
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        indicator: Label {
            text: "\u25BE" // Ký tự mũi tên xuống
            color: textColor
            padding: 8
        }
        popup: Popup {
            y: control.height
            width: control.width
            padding: 4
            background: Rectangle {
                color: inputBgColor
                border.color: borderColor
            }
            contentItem: ListView {
                model: control.popup.model
                delegate: ItemDelegate {
                    width: parent.width
                    text: modelData // 1. Giữ lại text ở đây
                    highlighted: ListView.isCurrentItem
                    
                    // 2. XÓA dòng 'color: textColor' bị lỗi

                    // 3. Giữ lại background đã sửa
                    background: Rectangle {
                        color: highlighted ? "#0078d7" : "transparent"
                    }
                    
                    // 4. THÊM contentItem này vào
                    // Điều này cho phép chúng ta set màu cho Text bên trong
                    contentItem: Text {
                        text: control.text // Lấy text từ ItemDelegate
                        color: textColor  // Set màu chữ ở đây
                        font: control.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        
                        // Lấy padding từ ItemDelegate cha
                        leftPadding: control.padding
                        rightPadding: control.padding
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

            CustomComboBox {
                id: logLevelCombo
                model: ["Debug", "Info", "Warning", "Error", "Fatal"]
                currentIndex: 0
                Layout.preferredWidth: 120
            }

            CheckBox {
                id: ignoreCaseCheck
                text: qsTr("Ignore case for filters")
                checked: false
                indicator: Rectangle {
                    width: 18; height: 18
                    color: control.checked ? "#FFFFFF" : inputBgColor
                    border.color: borderColor
                    radius: 3
                    Label {
                        text: control.checked ? "\u2713" : "" // Dấu check
                        anchors.centerIn: parent
                        color: inputBgColor
                    }
                }
                contentItem: Label {
                    text: control.text
                    color: textSecondaryColor
                    leftPadding: 6
                }
            }

            CustomTextField {
                id: processFilter
                placeholderText: qsTr("Process Filter")
                Layout.preferredWidth: 150
            }

            CustomTextField {
                id: disabledFilter
                text: ":disabled"
                Layout.preferredWidth: 100
                background: Rectangle { // Ghi đè background
                    color: inputBgColor
                    border.color: highlightGreen
                    border.width: 2
                    radius: 4
                }
            }

            CustomComboBox {
                id: logicCombo
                model: ["OR", "AND"]
                currentIndex: 0
                Layout.preferredWidth: 70
                background: Rectangle { // Ghi đè background
                    color: inputBgColor
                    border.color: highlightPurple
                    border.width: 2
                    radius: 4
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

        // --- Hàng 3: Exclusive Filter ---

        // --- Hàng 4: Highlights ---
        Rectangle { Layout.fillWidth: true; height: 1; color: borderColor }
        ListModel {
            id: highlightModel
            ListElement { hexColor: "#b0e0e6"; text: "" }
            ListElement { hexColor: "#98fb98"; text: "" }
            ListElement { hexColor: "#800080"; text: "" }
            ListElement { hexColor: "#ffb6c1"; text: "" }
            ListElement { hexColor: "#ffff00"; text: "" }
            ListElement { hexColor: "#ff0000"; text: "" }
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
                            border.color: model.hexColor === "#ffffff" ? "#AAAAAA" : "transparent" // Border for white swatch
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