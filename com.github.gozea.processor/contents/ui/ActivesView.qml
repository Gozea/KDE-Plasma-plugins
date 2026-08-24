import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

import org.kde.kirigami as Kirigami

Item {
    id: view

    property var running: root.running

    ColumnLayout {
        anchors.fill: parent

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
}

