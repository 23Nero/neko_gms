import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "log_patterns/index.js" as LogPatterns

Rectangle {
    id: logView
    property string source: ""
    property color panelColor: "#1e2127"
    property color dividerColor: "#1e2127"
    property color textPrimary: "#abb2bf"
    property color textSecondary: "#5c6370"
    property var logPatterns: LogPatterns.all()

    signal errorOccurred(string message)

    radius: 6
    color: panelColor
    border.color: dividerColor
    border.width: 0

    ListModel {
        id: logModel
    }

    function parseLine(line) {
        var trimmed = line.trim();
        if (!trimmed) {
            return null;
        }

        for (var i = 0; i < logPatterns.length; ++i) {
            var pattern = logPatterns[i];
            var matches = trimmed.match(pattern.regex);
            if (matches) {
                var transformed = pattern.transform(matches);
                transformed.raw = trimmed;
                return transformed;
            }
        }

        return {
            raw: trimmed,
            level: ""
        };
    }

    function levelColor(level) {
        switch (level) {
        case "F":
        case "E":
            return "#ff6b6b";
        case "W":
            return "#ffff80";
        case "I":
            return "#b4f0a0";
        case "D":
            return "#78d0ff";
        case "V":
            return "#ff79c6";
        default:
            return textPrimary;
        }
    }

    function buildBody(entry) {
        if (!entry) {
            return "";
        }
        if (!entry.time && entry.raw) {
            return entry.raw;
        }

        var parts = [];
        if (entry.pid) {
            parts.push(entry.pid);
        }
        if (entry.tid) {
            parts.push(entry.tid);
        }
        if (entry.level) {
            parts.push(entry.level);
        }
        if (entry.tag) {
            parts.push(entry.tag + ":");
        }
        if (entry.message) {
            parts.push(entry.message);
        } else if (entry.raw) {
            parts.push(entry.raw);
        }

        return parts.join(" ");
    }

    function loadLogFile() {
        if (!source) {
            logModel.clear();
            return;
        }

        var primaryUrl = Qt.resolvedUrl(source);
        var fallbackUrl = source;
        var triedFallback = false;

        function issueRequest(url) {
            var request = new XMLHttpRequest();
            request.open("GET", url);
            request.onreadystatechange = function() {
                if (request.readyState === XMLHttpRequest.DONE) {
                    if (request.status === 0 || request.status === 200) {
                        console.log("Loaded log file:", url);
                        logModel.clear();
                    if (messageList) {
                        messageList.resetMaxWidth();
                    }
                        var lines = request.responseText.split(/\r?\n/);
                        for (var i = 0; i < lines.length; ++i) {
                            var entry = parseLine(lines[i]);
                            if (!entry) {
                                continue;
                            }
                            entry.lineNumber = i + 1;
                            logModel.append(entry);
                        }
                    } else if (!triedFallback && url !== fallbackUrl) {
                        triedFallback = true;
                        issueRequest(fallbackUrl);
                    } else {
                        console.warn("Failed to load log file:", request.status, request.statusText, url);
                        logModel.clear();
                        errorOccurred(qsTr("Failed to load log file"));
                    }
                }
            };
            request.onerror = function() {
                if (!triedFallback && url !== fallbackUrl) {
                    triedFallback = true;
                    issueRequest(fallbackUrl);
                } else {
                    console.warn("Error loading log file:", url);
                    logModel.clear();
                    errorOccurred(qsTr("Failed to load log file"));
                }
            };
            request.send();
        }

        issueRequest(primaryUrl);
    }

    onSourceChanged: loadLogFile()
    Component.onCompleted: loadLogFile()

    property bool _syncingScroll: false

    function syncScroll(source, target) {
        if (_syncingScroll) {
            return;
        }
        _syncingScroll = true;
        target.contentY = source.contentY;
        _syncingScroll = false;
    }

    function syncScrollPosition(value) {
        if (_syncingScroll) {
            return;
        }
        _syncingScroll = true;
        messageList.contentY = value;
        lineList.contentY = value;
        _syncingScroll = false;
    }

    property int lineColumnWidth: 52

    RowLayout {
        anchors.fill: parent
        anchors.margins: 2
        spacing: 0

        Rectangle {
            id: lineColumn
            Layout.preferredWidth: lineColumnWidth
            Layout.minimumWidth: lineColumnWidth
            Layout.maximumWidth: lineColumnWidth
            Layout.fillHeight: true
            color: "#1f232b"

            ListView {
                id: lineList
                anchors.fill: parent
                anchors.margins: 4
                clip: true
                spacing: 4
                model: logModel
                reuseItems: true
                interactive: false
                onContentYChanged: syncScrollPosition(lineList.contentY)
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 6
                }

                delegate: Text {
                    width: lineColumn.width - 8
                    color: textSecondary
                    text: lineNumber
                    font.family: "Courier New"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignLeft
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.minimumWidth: 1
            Layout.maximumWidth: 1
            Layout.fillHeight: true
            color: "#3e4451"
        }

        Rectangle {
            id: messageColumn
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: panelColor

            Flickable {
                id: messageList
                anchors.fill: parent
                anchors.margins: 4
                clip: true
                contentWidth: messageContent.width
                contentHeight: messageContent.height
                flickableDirection: Flickable.HorizontalAndVerticalFlick
                onContentYChanged: syncScrollPosition(messageList.contentY)
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 6
                }
                ScrollBar.horizontal: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    height: 8
                }

                Column {
                    id: messageContent
                    width: Math.max(messageColumn.width - 8, messageList.maxLineWidth)
                    spacing: 4

                    Repeater {
                        id: messageRepeater
                        model: logModel

                        Item {
                            width: messageContent.width
                            height: logRow.implicitHeight

                            Row {
                                id: logRow
                                spacing: model.time ? 12 : 0
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    id: timeText
                                    visible: model.time !== undefined
                                    color: "#ffffff"
                                    text: model.time || ""
                                    font.family: "Courier New"
                                    font.pixelSize: 14
                                    wrapMode: Text.NoWrap
                                }

                                Text {
                                    id: logText
                                    color: levelColor(model.level)
                                    text: buildBody(model)
                                    font.family: "Courier New"
                                    font.pixelSize: 14
                                    wrapMode: Text.NoWrap
                                }

                                onImplicitWidthChanged: messageList.updateMaxLineWidth(implicitWidth)
                                Component.onCompleted: messageList.updateMaxLineWidth(implicitWidth)
                            }
                        }
                    }
                }

                property real maxLineWidth: messageColumn.width - 8

                function updateMaxLineWidth(w) {
                    if (w > maxLineWidth) {
                        maxLineWidth = w;
                        contentWidth = messageContent.width;
                    }
                }

                function resetMaxWidth() {
                    maxLineWidth = messageColumn.width - 8;
                    contentWidth = messageContent.width;
                }
            }
        }
    }
}

