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
    property color buttonHoverColor: "#3e4451"
    property color buttonPrimaryColor: "#4a5162"
    property color buttonIconColor: "#868d99"
    property font textIconFont: Qt.font({ family: "Segoe Fluent Icons", pointSize: 12 })
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
                implicitHeight: Math.min(contentHeight, 240)
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

    ListModel {
        id: pidModel
        ListElement { pidValue: "1234 (Service)"; isChecked: false }
        ListElement { pidValue: "5678 (UI)"; isChecked: false }
        ListElement { pidValue: "9012 (Media)"; isChecked: true }
        ListElement { pidValue: "1111 (Network)"; isChecked: false }
        ListElement { pidValue: "2222 (Input)"; isChecked: false }
        ListElement { pidValue: "3333 (System)"; isChecked: false }
    }

    component CustomDialogButton: Button {
        id: control
        property color defaultColor: buttonPrimaryColor
        property color hoverColor: buttonHoverColor
        property color iconColor: buttonIconColor
        property color textColorOverride: textPrimary
        property string iconText: ""

        implicitHeight: 34
        implicitWidth: contentItem.implicitWidth + 24

        background: Rectangle {
            color: control.hovered ? hoverColor : defaultColor
            border.color: borderColor
            border.width: 1
            radius: 4
        }

        contentItem: RowLayout {
            spacing: 6
            Layout.alignment: Qt.AlignVCenter

            Label {
                text: control.iconText
                font: textIconFont
                color: control.iconColor
                visible: control.iconText.length > 0
                Layout.alignment: Qt.AlignVCenter
            }

            Label {
                text: control.text
                color: control.textColorOverride
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    component FilterDisplayButton: Item {
        id: controlRoot
        implicitHeight: 32
        implicitWidth: Math.max(displayLabel.implicitWidth + 40, 120)
        property alias text: displayLabel.text
        property color defaultBorder: highlightGreen
        property color hoverBorder: "white"
        property bool hovered: hoverArea.containsMouse
        signal clicked()

        Rectangle {
            anchors.fill: parent
            color: inputBgColor
            border.width: 2
            border.color: controlRoot.hovered ? hoverBorder : defaultBorder
            radius: 4
        }

        Label {
            id: displayLabel
            text: qsTr("Select Filter...")
            color: textPrimary
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: arrowLabel.left
            anchors.rightMargin: 4
            elide: Text.ElideRight
        }

        Label {
            id: arrowLabel
            text: "\u25BE"
            color: textSecondary
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: controlRoot.clicked()
        }
    }

    Popup {
        id: pidFilterPopup
        width: 450
        implicitHeight: popupLayout.implicitHeight
        modal: false
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0

        background: Rectangle {
            color: panelColor
            border.color: borderColor
            border.width: 1
            radius: 4
        }

        ColumnLayout {
            id: popupLayout
            width: parent.width
            spacing: 0

            RowLayout {
                id: titleBar
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Layout.margins: 10
                property point dragStartPos: Qt.point(0, 0)

                DragHandler {
                    target: null
                    cursorShape: Qt.PointingHandCursor
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchScreen | PointerDevice.Stylus
                    grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlers
                    onActiveChanged: if (active) titleBar.dragStartPos = Qt.point(pidFilterPopup.x, pidFilterPopup.y)
                    onTranslationChanged: {
                        pidFilterPopup.x = titleBar.dragStartPos.x + translation.x
                        pidFilterPopup.y = titleBar.dragStartPos.y + translation.y
                    }
                }

                Label {
                    text: qsTr("Process Filter")
                    color: textPrimary
                    font.pixelSize: 16
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                Button {
                    id: closeButton
                    text: "\uE8BB"
                    font: iconFont
                    flat: true
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    background: Rectangle { color: "transparent" }
                    contentItem: Label {
                        text: closeButton.text
                        font: closeButton.font
                        color: closeButton.hovered ? "white" : textSecondaryColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: pidFilterPopup.close()
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: borderColor }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 15
                spacing: 12

                Label {
                    text: qsTr("Manual Filter (use | for OR, & for AND):")
                    color: textPrimary
                }

                CustomTextField {
                    id: manualFilterInput
                    placeholderText: qsTr("Example: value1|value2 or value1&value2")
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Quick Select (%1 unique values):").arg(pidModel.count)
                    color: textPrimary
                }

                Rectangle {
                    color: inputBgColor
                    border.color: borderColor
                    radius: 4
                    Layout.fillWidth: true
                    height: 32

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Label {
                            text: "\uE721"
                            font: iconFont
                            color: textSecondaryColor
                            Layout.alignment: Qt.AlignVCenter
                        }

                        TextField {
                            id: searchInput
                            placeholderText: qsTr("Search in list...")
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: textPrimary
                            placeholderTextColor: "#AAAAAA"
                            background: Rectangle { color: "transparent" }
                        }
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    clip: true
                    background: Rectangle {
                        color: inputBgColor
                        border.color: borderColor
                        radius: 4
                    }

                    ListView {
                        id: pidListView
                        model: pidModel
                        spacing: 2

                        delegate: CheckDelegate {
                            id: pidDelegate
                            width: ListView.view.width
                            text: model.pidValue
                            checked: model.isChecked
                            leftPadding: 36
                            onToggled: {
                                pidModel.setProperty(index, "isChecked", checked)
                                var tokens = manualFilterInput.text.split("|").filter(function(entry) {
                                    return entry.length > 0
                                })
                                var existingIndex = tokens.indexOf(model.pidValue)
                                if (checked) {
                                    if (existingIndex === -1)
                                        tokens.push(model.pidValue)
                                } else if (existingIndex !== -1) {
                                    tokens.splice(existingIndex, 1)
                                }
                                manualFilterInput.text = tokens.join("|")
                            }
                            visible: searchInput.text.length === 0
                                     || model.pidValue.toLowerCase().indexOf(searchInput.text.toLowerCase()) !== -1
                            padding: 8
                            indicator: Rectangle {
                                id: indicatorRect
                                width: 18
                                height: 18
                                radius: 3
                                border.color: borderColor
                                border.width: 1
                                color: pidDelegate.checked ? highlightGreen : "transparent"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12

                                Label {
                                    anchors.centerIn: parent
                                    text: pidDelegate.checked ? "\uE8FB" : ""
                                    font: textIconFont
                                    color: pidDelegate.checked ? "#000000" : "transparent"
                                }
                            }

                            contentItem: Label {
                                text: model.pidValue
                                color: textPrimary
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                anchors.left: indicatorRect.right
                                anchors.leftMargin: 12
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

            }

            Rectangle { Layout.fillWidth: true; height: 1; color: borderColor }

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                spacing: 10

                CustomDialogButton {
                    text: qsTr("Clear Filter")
                    iconText: "\uE894"
                    onClicked: {
                        manualFilterInput.text = ""
                        for (var i = 0; i < pidModel.count; ++i) {
                            pidModel.setProperty(i, "isChecked", false)
                        }
                        processFilterButton.text = qsTr("Select Filter...")
                        pidFilterPopup.close()
                    }
                }

                CustomDialogButton {
                    text: qsTr("Apply Selected")
                    iconText: "\uE8FB"
                    defaultColor: highlightGreen
                    iconColor: "#000000"
                    textColorOverride: "#000000"
                    onClicked: {
                        var manual = manualFilterInput.text.trim()
                        var selected = []
                        for (var i = 0; i < pidModel.count; ++i) {
                            var element = pidModel.get(i)
                            if (element.isChecked)
                                selected.push(element.pidValue)
                        }
                        var selectionText = manual.length > 0 ? manual
                                            : (selected.length > 0 ? selected.join("|") : qsTr("Select Filter..."))
                        processFilterButton.text = selectionText
                        pidFilterPopup.close()
                    }
                }

                Item { Layout.fillWidth: true }

                CustomDialogButton {
                    text: qsTr("Close")
                    onClicked: pidFilterPopup.close()
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

            FilterDisplayButton {
                id: processFilterButton
                Layout.preferredWidth: 160
                onClicked: {
                    var mapped = processFilterButton.mapToItem(null, 0, 0)
                    pidFilterPopup.x = Math.min(mapped.x, filterPanel.width - pidFilterPopup.width - 10)
                    pidFilterPopup.y = mapped.y + processFilterButton.height + 4
                    pidFilterPopup.open()
                }
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
            ListElement { hexColor: "#78d0ff"; text: "" } // Info
            ListElement { hexColor: "#b4f0a0"; text: "" } // Debug
            ListElement { hexColor: "#ff79c6"; text: "" } // Verbose
            ListElement { hexColor: "#ff6b6b"; text: "" } // Error
            ListElement { hexColor: "#ffff80"; text: "" } // Warning
            ListElement { hexColor: "#ff9e64"; text: "" } // Secondary
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

                        Rectangle {
                            width: 30
                            height: 24
                            color: model.hexColor
                            border.color: model.hexColor === "#ffffff" ? "#AAAAAA" : "transparent"
                            radius: 4
                            antialiasing: true
                        }

                        CustomTextField {
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
