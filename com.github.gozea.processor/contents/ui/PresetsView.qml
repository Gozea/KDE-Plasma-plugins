import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

import org.kde.kirigami as Kirigami

Item {
    id: view

    property var presets: root.presets

    // signal presetDeleted(int index)

    // function deletePreset(index) {
    //     presetDeleted(index)
    // }
    //
    // onPresetDeleted: function(index) {
    //     root.presets.splice(index, 1)
    //     root.presets = root.presets.slice()
    //
    //     root.savePresets()
    // }
    
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

                    model: view.presets

                    keyNavigationEnabled: true

                    delegate: PlasmaComponents.ItemDelegate {
                        width: listView.width

                        contentItem: RowLayout {
                            spacing: Kirigami.Units.smallSpacing

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                PlasmaComponents.Label {
                                    Layout.fillWidth: true

                                    text: modelData.name

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
                                icon.name: modelData.starred
                                    ? "starred-symbolic"
                                    : "non-starred-symbolic"

                                display: PlasmaComponents.AbstractButton.IconOnly

                                text: "Details"

                                onClicked: {
                                    console.log(
                                        "Selected preset:",
                                        modelData.name
                                    )
                                }

                                PlasmaComponents.ToolTip.text: text
                                PlasmaComponents.ToolTip.visible: hovered
                                PlasmaComponents.ToolTip.delay:
                                    Kirigami.Units.toolTipDelay
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

                //onTriggered: {
                //    view.presetAdded()
                //}
            }
        }
    }
}

