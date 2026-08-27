import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

import org.kde.kirigami as Kirigami

ListView {
    id: view

    property var presets: root.presets
    property var running: root.running
    
    function deletePreset(index) {
        root.presets.splice(index, 1)
        root.presets = root.presets.slice()
    
        root.savePresets()
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            // we see either this or the placeholder message
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            visible: view.presets.length > 0

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    // actual list of items
                    id: listView
                    anchors.fill: parent
                    keyNavigationEnabled: true

                    model: view.presets

                    delegate: PlasmaComponents.ItemDelegate {
                        id: itemroot

                        width: listView.width
                        height: Kirigami.Units.gridUnit*3 + (expanded ? details.height : 0)

                        property bool expanded: false

                        Behavior on height {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                        
                        contentItem: ColumnLayout {

                            RowLayout {
                                spacing: Kirigami.Units.smallSpacing

                                PlasmaComponents.ToolButton {
                                    icon.name: (!expanded ? "expand" : "collapse")
                                    display: PlasmaComponents.AbstractButton.IconOnly

                                    onClicked: itemroot.expanded = !itemroot.expanded
                                }

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
                                                modelData.options.map((entry) => {return `${entry.key} ${entry.value}`}).join(" ")
                                            ].join(" ")

                                        textFormat: Text.PlainText
                                        elide: Text.ElideRight

                                        opacity: 0.7
                                    }
                                }

                                PlasmaComponents.ToolButton {
                                    icon.name: "media-playback-start"
                                    display: PlasmaComponents.AbstractButton.IconOnly
                                    text: "Start a Process"

                                    onClicked: {
                                        root.executable.start(
                                            [modelData.command,
                                                modelData.options.map((entry) => {return `${entry.key} ${entry.value}`}).join(" ")
                                            ].join(" "),
                                        modelData.title)
                                    }

                                    PlasmaComponents.ToolTip.text: text
                                    PlasmaComponents.ToolTip.visible: hovered
                                }

                                PlasmaComponents.Label {
                                    text: view.running.filter(entry => entry["title"] === modelData.title).length
                                }

                                PlasmaComponents.ToolButton {
                                    icon.name: "media-playback-stop"
                                    display: PlasmaComponents.AbstractButton.IconOnly
                                    text: "Stop all Processes"
                                    enabled: view.running.filter(entry => entry["title"] === modelData.title).length !== 0

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

                            // expanded elements
                            ColumnLayout {
                                id: details

                                visible: expanded

                                ListModel {
                                    id: customCommand

                                    //initizalize the custom command
                                    Component.onCompleted: {
                                        for (const item of modelData.options) {
                                            append({"enabled": true, "key": item.key, "value": item.value})
                                        }
                                    }
                                }

                                PlasmaComponents.Label {
                                    Layout.fillWidth: true

                                    text: modelData.command

                                    textFormat: Text.PlainText
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }

                                // list parameters
                                Repeater {
                                    id: paramList
                                    property var optionsModel: modelData.options

                                    model: customCommand
                                    delegate: RowLayout {
                                        property bool disabled: false

                                        PlasmaComponents.CheckBox {
                                            checked: true
                                            onClicked: {
                                                disabled = !disabled
                                                customCommand.setProperty(index, "enabled", !disabled)
                                            }
                                        }

                                        Loader {
                                            Layout.fillWidth: true
                                            sourceComponent: {
                                                switch(paramList.optionsModel[index].input) {
                                                    case "fixed":
                                                        return fixedComponent
                                                    case "typable":
                                                        return typableComponent
                                                    case "choices":
                                                        return choicesComponent
                                                }
                                            }

                                            Component {
                                                id: fixedComponent

                                                RowLayout {
                                                    PlasmaComponents.Label {
                                                        Layout.fillWidth: true
                                                        text: paramList.optionsModel[index].key

                                                        font.strikeout: disabled

                                                        textFormat: Text.PlainText
                                                        wrapMode: Text.WordWrap
                                                        elide: Text.ElideRight
                                                        opacity: (disabled ? 0.7: 1)
                                                    }

                                                     PlasmaComponents.Label {
                                                         Layout.fillWidth: true
                                                         text: paramList.optionsModel[index].value
                                                    
                                                         visible: paramList.optionsModel[index].value.length > 0
                                                         font.strikeout: disabled
                                                    
                                                         textFormat: Text.PlainText
                                                         wrapMode: Text.WordWrap
                                                         elide: Text.ElideRight
                                                         opacity: (disabled ? 0.7: 1)
                                                     }
                                                 }
                                            }


                                            Component {
                                                id: typableComponent
                                                
                                                RowLayout {
                                                    PlasmaComponents.TextArea {
                                                        placeholderText: paramList.optionsModel[index].key
                                                        font.strikeout: disabled
                                                    
                                                        textFormat: Text.PlainText
                                                        wrapMode: Text.WordWrap
                                                        enabled: !disabled

                                                        onTextEdited: customCommand.setProperty(index, "key", text)
                                                    }

                                                    PlasmaComponents.TextArea {
                                                        placeholderText: paramList.optionsModel[index].value
                                                        visible: paramList.optionsModel[index].value.length > 0
                                                        font.strikeout: disabled
                                                    
                                                        textFormat: Text.PlainText
                                                        wrapMode: Text.WordWrap
                                                        enabled: !disabled

                                                        onTextEdited: customCommand.setProperty(index, "value", text)
                                                    }

                                                }
                                            }

                                            Component {
                                                id: choicesComponent

                                                RowLayout {
                                                    PlasmaComponents.ComboBox {
                                                        enabled: !disabled
                                                        model: [
                                                            paramList.optionsModel[index].key,
                                                            ...paramList.optionsModel[index].altKeys
                                                        ]

                                                        onCurrentTextChanged: {
                                                            customCommand.setProperty(index, "key", currentText)
                                                        }
                                                    }

                                                    PlasmaComponents.ComboBox {
                                                        visible: paramList.optionsModel[index].value.length > 0
                                                    
                                                        enabled: !disabled
                                                        model: [
                                                            paramList.optionsModel[index].value,
                                                            ...paramList.optionsModel[index].altValues
                                                        ]
                                                        onCurrentTextChanged: {
                                                            customCommand.setProperty(index, "value", currentText)
                                                        }
                                                    }

                                                }
                                            }

                                        }

                                    }
                                }

                                PlasmaComponents.Button {
                                    icon.name: "media-playback-start"
                                    text: "Launch with parameters"

                                    function extractListValues(qqmlList) {
                                        var res = []
                                        for (var i = 0 ; i < qqmlList.count ; i++) {
                                            if (qqmlList.get(i)["enabled"]) {
                                                res.push(qqmlList.get(i)["key"])
                                                res.push(qqmlList.get(i)["value"])
                                            }
                                        }
                                        return res
                                    }

                                    onClicked: {
                                        root.executable.start(
                                            [modelData.command,
                                                extractListValues(customCommand).join(" ")
                                            ].join(" "),
                                        modelData.title)
                                    }
                                }

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

