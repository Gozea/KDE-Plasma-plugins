import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.components as PlasmaComponents
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.ScrollViewKCM {
    id: configPresets

    property string cfg_presets: "[]"

    property var presets: []

    Component.onCompleted: {
        try {
            presets = JSON.parse(cfg_presets || "[]")

            if (!Array.isArray(presets))
                presets = []

        } catch (e) {
            console.error("JSON error:", e)
            presets = []
        }

        console.log("preset count:", presets.length)
    }

    function deletePreset(row) {
        var newPresets = presets.slice()
        newPresets.splice(row, 1)

        presets = newPresets

        var newJson = JSON.stringify(newPresets)
        cfg_presets = newJson

        console.log("presets:", newPresets.length)
        console.log("cfg_presets:", newJson)
    }

    view: ListView {
        id: presetList

        model: configPresets.presets

        delegate: Kirigami.SwipeListItem {
            width: presetList.width

            contentItem: RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                ColumnLayout {
                    width: parent.width
                    spacing: 0

                    QQC2.Label {
                        Layout.fillWidth: true

                        text: modelData.title

                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    QQC2.Label {
                        Layout.fillWidth: true
                        text: [modelData.command,
                                modelData.options.map((entry) => {return `${entry.key} ${entry.value}`}).join(" ")
                            ].join(" ")

                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap

                        opacity: 0.7
                    }
                }

                PlasmaComponents.ToolButton {
                    icon.name: "cell_edit"
                    display: PlasmaComponents.AbstractButton.IconOnly
                    text: "Edit"

                    onClicked: {
                    }

                    PlasmaComponents.ToolTip.text: text
                    PlasmaComponents.ToolTip.visible: hovered
                }

                PlasmaComponents.ToolButton {
                    icon.name: "edit-delete"
                    display: PlasmaComponents.AbstractButton.IconOnly
                    text: "Delete"

                    onClicked: configPresets.deletePreset(index)

                    PlasmaComponents.ToolTip.text: text
                    PlasmaComponents.ToolTip.visible: hovered
                }
            }
        }

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            width: parent.width - Kirigami.Units.largeSpacing * 4

            visible: presetList.count === 0

            icon.name: "document-new"
            text: "No presets yet"
            explanation: "Add a preset to get started."
        }

    }

    footer: QQC2.Button {
    text: "Add preset"
    icon.name: "list-add"

    onClicked: {
        updatePopup.visible= true
    }

    ListModel{
        id: fieldsModel
    }

    // Dialog to add new preset commands
    Kirigami.Dialog {
        id: "updatePopup"
        title: "Add preset command"
        visible: false

        padding: Kirigami.Units.largeSpacing
        standardButtons: QQC2.Dialog.Ok | QQC2.Dialog.Cancel

        //push new preset in config
        onAccepted:{
            // helper function to extract altKeys and altValues
            function extractListValues(qqmlList) {
                var res = []
                for (var i = 0 ; i < qqmlList.count ; i++) {
                    res.push(qqmlList.get(i)["value"])
                }
                return res
            }

            // create options
            var options = []
            for (var i = 0 ; i < fieldsModel.count; i++) {
                var field = fieldsModel.get(i)
                options.push({
                    "input": field.input, // we'll rotate the array onClick -> current input is position 0
                    "key": field.key,
                    "value": field.value,
                    "altKeys": extractListValues(field.altKeys),
                    "altValues": extractListValues(field.altValues)
                })
            }

            //insert into config
            var newEntry = {
                "title": commandTitle.text,
                "command": command.text,
                "options": options
            }
            presets = presets.concat([newEntry])
            cfg_presets = JSON.stringify(presets) // this should not be saved in config at that point ??
            console.log(cfg_presets)

            //clear values
            fieldsModel.clear()
            commandTitle.clear()
            command.clear()

            root.refreshPresets()
        }

            ColumnLayout {
                Kirigami.FormLayout {
                    QQC2.TextField {
                        id: commandTitle

                        Kirigami.FormData.label: "Title"
                    }

                    QQC2.TextField {
                        id: command

                        Kirigami.FormData.label: "Command"
                        //onTextChanged: serverDialog.updateOkEnabled()
                    }

                }

                Kirigami.Separator {
                    Layout.fillWidth: true
                    Layout.topMargin: Kirigami.Units.largeSpacing
                    Layout.bottomMargin: Kirigami.Units.largeSpacing
                }

                //Add fields dynamically on user input
                Repeater {
                    model: fieldsModel

                    delegate: RowLayout {
                        property int fieldIndex: index
                        property var isKeyPair: false

                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        QQC2.Button {
                            text: input.charAt(0).toUpperCase() + input.slice(1) // Capitalized
                            property var inputTypes: ["fixed", "typable", "choices"]

                            onClicked: {
                                var currentTypeIndex = inputTypes.indexOf(input)
                                var next = (currentTypeIndex + 1) % inputTypes.length

                                fieldsModel.setProperty(index, "input", inputTypes[next])
                            }
                        }

                        ColumnLayout {
                            QQC2.TextField {
                                Layout.fillWidth: true
                                placeholderText: "Parameter"

                                onTextEdited: {
                                    fieldsModel.setProperty(index, "key", text)
                                }
                            }

                            Repeater {
                                model: fieldsModel.get(index).altKeys

                                delegate: ColumnLayout {
                                    QQC2.TextField {
                                        Layout.fillWidth: true
                                        placeholderText: "Alternative Key"

                                        onTextEdited: {
                                            console.log(fieldIndex)
                                            fieldsModel.get(fieldIndex).altKeys.setProperty(index, "value", text)
                                        }
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            QQC2.TextField {
                                Layout.fillWidth: true
                                placeholderText: "Value"
                                visible: isKeyPair

                                onTextEdited: {
                                    fieldsModel.setProperty(index, "value", text)
                                }
                            }

                            Repeater {
                                model: fieldsModel.get(index).altValues

                                delegate: ColumnLayout {
                                    QQC2.TextField {
                                        Layout.fillWidth: true
                                        placeholderText: "Alternative Values"

                                        onTextEdited: {
                                            fieldsModel.get(fieldIndex).altValues.setProperty(index, "value", text)
                                        }
                                    }
                                }
                            }

                        }

                        QQC2.Button {
                            icon.name: "dialog-xml-editor"
                            display: QQC2.AbstractButton.IconOnly
                            onClicked: {
                                isKeyPair = !isKeyPair
                                fieldsModel.get(index).altKeys.clear()
                                fieldsModel.get(index).altValues.clear()
                            }
                        }

                        QQC2.Button {
                            icon.name: "list-add"
                            display: QQC2.AbstractButton.IconOnly

                            visible: input == "choices"
                            onClicked: {
                                var currentField = fieldsModel.get(index)
                                if (!isKeyPair) {
                                    currentField.altKeys.append({value: ""})
                                } else {
                                    currentField.altValues.append({value: ""})
                                }
                            }
                        }

                        QQC2.Button {
                            icon.name: "list-remove"
                            display: QQC2.AbstractButton.IconOnly
                            onClicked: fieldsModel.remove(index)
                        }

                    }
                }

                QQC2.Button {
                    text: "Add field"
                    icon.name: "list-add"

                    // initialize empty flag fields
                    onClicked: {
                        fieldsModel.append({
                            "input": "fixed", // we'll rotate the array onClick -> current input is position 0
                            "key": "",
                            "value": "",
                            "altKeys": [],
                            "altValues": []
                        })
                    }
                }
            }
        }
    }

}

