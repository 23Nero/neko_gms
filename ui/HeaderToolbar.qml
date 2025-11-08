import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    id: toolbar

    // Exposed palette values with sensible defaults, can be overridden by parent.
    property color panelAccentColor: "#1a2946"
    property color textPrimary: "#e9f2ff"
    property font iconFont: Qt.font({ family: "Segoe Fluent Icons", pointSize: 16 })
    // Heights used for the resize interaction.
    property real minHeight: 30
    property real maxHeight: 120
    property real normalHeight: 30
    property real adjustableHeight: normalHeight
    // Icon buttons scale together with the toolbar height but never shrink below 24px.
    property real iconButtonSize: Math.max(24, contentHeight * 0.8)

    contentHeight: adjustableHeight
    Behavior on contentHeight {
        NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
    }
    background: Rectangle {
        color: panelAccentColor
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: Math.max(0, (toolbar.contentHeight - toolbar.iconButtonSize) / 2)
        anchors.bottomMargin: Math.max(0, (toolbar.contentHeight - toolbar.iconButtonSize) / 2)
        // Keep consistent horizontal spacing while still adapting to taller toolbars.
        spacing: Math.max(12, toolbar.contentHeight * 0.3)

        Repeater {
            model: [
                "\uE74D", // folder open
                "\uE8B7", // save
                "\uE8AA", // refresh
                "\uE721", // play
                "\uE769", // pause
                "\uE73E", // stop
                "\uE8B2", // view
                "\uE8B5", // filter
                "\uE8B6", // search
                "\uE8A2", // zoom in
                "\uE71E", // zoom out
                "\uEE72"  // usb/device
            ]
            // Each icon button respects the computed size and reuses the shared palette.
            delegate: ToolButton {
                Layout.preferredWidth: toolbar.iconButtonSize
                Layout.preferredHeight: toolbar.iconButtonSize
                background: Rectangle {
                    radius: 6
                    color: pressed ? "#28426a" : hovered ? "#22365a" : "transparent"
                    border.color: hovered ? "#33517d" : "transparent"
                }
                contentItem: Label {
                    text: modelData
                    color: textPrimary
                    font.family: iconFont.family
                    font.pixelSize: toolbar.iconButtonSize * 0.6
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        ToolButton {
            Layout.preferredWidth: toolbar.iconButtonSize
            Layout.preferredHeight: toolbar.iconButtonSize
            background: Rectangle {
                // Circular avatar uses the provided app icon as background.
                radius: toolbar.iconButtonSize / 2
                border.color: "#2f4a7a"
                clip: true

                Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                }
            }
            contentItem: Item { }
        }

        Item {
            Layout.fillWidth: true
        }
    }

    // Rectangle {
    //     id: resizeHandle
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     anchors.bottom: parent.bottom
    //     anchors.bottomMargin: -3
    //     width: 100
    //     height: 6
    //     radius: 3
    //     color: "#2f4a7a"
    //     opacity: handleHover.hovered || resizeDrag.active ? 0.9 : 0.45

    //     HoverHandler {
    //         id: handleHover
    //     }

    //     DragHandler {
    //         id: resizeDrag
    //         target: null
    //         yAxis.enabled: true
    //         xAxis.enabled: false

    //         property real startHeight: toolbar.adjustableHeight

    //         onActiveChanged: {
    //             if (active) {
    //                 startHeight = toolbar.adjustableHeight
    //             }
    //         }

    //         onActiveTranslationChanged: {
    //             const candidate = startHeight + activeTranslation.y
    //             toolbar.adjustableHeight = Math.max(toolbar.minHeight, Math.min(toolbar.maxHeight, candidate))
    //         }
    //     }

    //     MouseArea {
    //         anchors.fill: parent
    //         hoverEnabled: true
    //         cursorShape: Qt.SizeVerCursor
    //         acceptedButtons: Qt.NoButton
    //     }
    // }
}

