import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

import org.kde.kirigami as Kirigami

Item {
    id: view

    property var running: root.running
    property int processChecked: -1

    ColumnLayout {
        anchors.fill: parent
        visible: processChecked === -1

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: listView
                anchors.fill: parent
                keyNavigationEnabled: true

                model: view.running

                delegate: PlasmaComponents.ItemDelegate {
                    width: listView.width

                    onClicked: {
                        view.processChecked = index
                    }

                    contentItem: RowLayout {
                        spacing: Kirigami.Units.smallSpacing

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            PlasmaComponents.Label {
                                Layout.fillWidth: true

                                text: modelData.title

                                textFormat: Text.PlainText
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }

                            PlasmaComponents.Label {
                                Layout.fillWidth: true
                                text: modelData.command

                                textFormat: Text.PlainText
                                elide: Text.ElideRight

                                opacity: 0.7
                            }

                        }

                        PlasmaComponents.ToolButton {
                            icon.name: "media-playback-stop"
                            display: PlasmaComponents.AbstractButton.IconOnly
                            text: "Stop a Process"

                            onClicked: root.executable.stop(modelData.title)

                            PlasmaComponents.ToolTip.text: text
                            PlasmaComponents.ToolTip.visible: hovered
                        }
                    }
                }

            }

        }

        PlasmaExtras.PlaceholderMessage {
            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: view.running.length === 0

            iconName: "edit-find"
            text: "No active command"
        }
    }


    ColumnLayout {
        id: processView

        anchors.fill: parent
        visible: processChecked !== -1

        // runs once
        Connections {
            target: view

            function onProcessCheckedChanged() {
                if (processChecked !== -1) {
                    root.executable.readStd(root.running[processChecked].pid)
                }
            }
        }

        // then repeat
        Timer {
            interval: 3000
            running: processChecked !== -1
            repeat: true

            onTriggered: {
                root.executable.readStd(root.running[processChecked].pid)
            }
        }

        // Clicked view

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5

            PlasmaComponents.ToolButton {
                icon.name: "draw-arrow-back"
                display: PlasmaComponents.AbstractButton.IconOnly
                text: "Go back to active processes list"

                onClicked: processChecked = -1

                PlasmaComponents.ToolTip.text: text
                PlasmaComponents.ToolTip.visible: hovered
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                PlasmaComponents.Label {
                    text: root.running[processChecked].title
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                }

                PlasmaComponents.Label {
                    text: root.running[processChecked].command
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight

                    opacity: 0.7
                }

                PlasmaComponents.Label {
                    text: `Pid : ${ root.running[processChecked].pid}`

                    wrapMode: Text.WordWrap
                    textFormat: Text.PlainText
                    opacity: 0.7
                }
            }
        }

        Kirigami.Separator {
            Layout.fillHeight: true
            visible: root.sidebarVisible
        }

        PlasmaComponents.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            PlasmaComponents.Label {
                id: processContent

                Layout.fillWidth: true

                text: root.readProcess

                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }
        }
    }

}

