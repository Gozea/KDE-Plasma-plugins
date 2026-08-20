import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property var presets: []

    function savePresets() {
        plasmoid.configuration.presets = JSON.stringify(presets)
    }
    

    preferredRepresentation: compactRepresentation

    Component.onCompleted: {
        try {
            presets = JSON.parse(plasmoid.configuration.presets)
            console.log("Loaded presets:", JSON.stringify(presets))
        } catch (e) {
            console.error("Failed to load presets:", e)
            presets = []
        }
    }

    fullRepresentation: PlasmaExtras.Representation {
        Text {
            id: label
            text: "Processor"
        }

        Layout.minimumWidth: label.implicitWidth
        Layout.minimumHeight: label.implicitHeight

        header: PlasmaExtras.PlasmoidHeading {
            RowLayout {
                anchors.fill: parent
                spacing: Kirigami.Units.smallSpacing

                PlasmaExtras.Heading {
                    Layout.fillWidth: true
                    level: 4
                    text: "Processor"
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                }

                PlasmaComponents.ToolButton {
                    icon.name: "configure"
                    display: PlasmaComponents.AbstractButton.IconOnly
                    text: "Configure"

                    onClicked: {
                        Plasmoid.internalAction("configure").trigger()
                    }

                    PlasmaComponents.ToolTip.text: text
                    PlasmaComponents.ToolTip.visible: hovered
                }
            }
        }

        contentItem: Item {
            ColumnLayout {
                anchors.fill: parent
                spacing: Kirigami.Units.smallSpacing

                TabBar {
                    id: tabBar
                    Layout.fillWidth: true

                    TabButton {
                        text: "Processes"
                        Layout.fillWidth: true
                    }

                    TabButton {
                        text: "Presets"
                        Layout.fillWidth: true
                    }
                }

                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    currentIndex: tabBar.currentIndex

                    ProcessesView {}

                    PresetsView {}

                }
            }
        }
    }
}

