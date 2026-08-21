import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

import org.kde.kirigami as Kirigami

Item {
    id: view

    property var presets: root.presets
    
    function deletePreset(index) {
        root.presets.splice(index, 1)
        root.presets = root.presets.slice()
    
        root.savePresets()
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            visible: view.presets.length > 0

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: listView
                    anchors.fill: parent
                    keyNavigationEnabled: true

                    model: view.presets

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
                                    text: [modelData.command,
                                            Object.entries(modelData.flags).map(([key, value]) => {return `--${key} ${value}`})
                                        ].filter(function (s) { return s; }).join(" ")

                                    textFormat: Text.PlainText
                                    elide: Text.ElideRight

                                    opacity: 0.7
                                }
                            }


                            PlasmaComponents.ToolButton {
                                icon.name: "media-playback-start"
                                display: PlasmaComponents.AbstractButton.IconOnly
                                text: "Start a Process"

                                onClicked: root.executable.start(modelData.command, modelData.title)

                                PlasmaComponents.ToolTip.text: text
                                PlasmaComponents.ToolTip.visible: hovered
                            }

                            PlasmaComponents.ToolButton {
                                icon.name: "media-playback-stop"
                                display: PlasmaComponents.AbstractButton.IconOnly
                                text: "Stop a Process"

                                onClicked: root.executable.stop(modelData.title)

                                PlasmaComponents.ToolTip.text: text
                                PlasmaComponents.ToolTip.visible: hovered
                            }

                            PlasmaComponents.ToolButton {
                                icon.name: "edit-delete"
                                display: PlasmaComponents.AbstractButton.IconOnly
                                text: "Delete"

                                onClicked: view.deletePreset(index)

                                PlasmaComponents.ToolTip.text: text
                                PlasmaComponents.ToolTip.visible: hovered
                            }

                        }
                    }
                }
            }
        }

        PlasmaExtras.PlaceholderMessage {
            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: view.presets.length === 0

            iconName: "edit-find"
            text: "No preset yet"

            helpfulAction: Kirigami.Action {
                icon.name: "list-add"
                text: "Create preset"

                onTriggered: {
                    Plasmoid.internalAction("configure").trigger()
                }
            }
        }
    }
}

