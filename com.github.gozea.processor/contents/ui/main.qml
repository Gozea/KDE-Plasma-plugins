import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

import org.kde.plasma.plasma5support as P5Support

import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property var presets: []
    property var running: []
    property var readProcess: ""

    //useful to pass the executable to presetView and processesView
    property alias executable: executable

    function savePresets() {
        plasmoid.configuration.presets = JSON.stringify(presets)
    }

    function refreshPresets() {
        try {
            presets = JSON.parse(plasmoid.configuration.presets)
            console.log("Loaded presets:", JSON.stringify(presets))
        } catch (e) {
            console.error("Failed to load presets:", e)
            presets = []
        }
    }

    Connections {
        target: plasmoid.configuration

        function onPresetsChanged() {
            console.log("Configuration presets changed")
            refreshPresets()
        }
    }
    
    preferredRepresentation: compactRepresentation

    Component.onCompleted: {
        refreshPresets()
    }


    P5Support.DataSource {
        id: executable

        engine: "executable"
        interval: 0
        onNewData: function(sourceName, data) {
            console.log(data["stdout"])
            console.log(
                "stderr:",
                data["stderr"]
            )
            console.log(
                "exit code:",
                data["exit code"]
            )

            //add running process if persists
            if (data["exit code"] === 10) {
                var stdout = data["stdout"].split(";")
                var newProcess = {
                    "pid": stdout[0],
                    "title": stdout[1],
                    "command": stdout[2]
                }
                sendNotification(stdout[1], stdout[2], "dialog-ok.svg")
                root.running = root.running.concat([newProcess])
            }

            // error
            if (data["exit code"] === 1) {
                sendNotification("Process didn't persist or failed", data["stderr"], "dialog-warning.svg")
            }

            // if readStd successful
            if (data["exit code"] === 20) {
                root.readProcess = data["stdout"]
            }
            //TODO remove running that ended by themselves (exit code 0 or 1)
            
            disconnectSource(sourceName);
        }

        function start(command, title) {
            // lauches process in background and write its stdout and stderr in /tmp -> write the pid in stdout in the meanwhile (& is important ; $! means most recent pid)
            connectSource(
                `${command} > /tmp/$(($$+1)) 2>&1 & sleep 0.1 && kill -0 $! && echo "$!;${title};${command}" && exit 10`
            )
        }

        function stop(title) {
            var titlePids = root.running.filter(entry => entry["title"] === title).map(entry => entry["pid"])
            executable.connectSource(
                `kill ${titlePids.join(" ")}`
            )
            //update running processes list
            root.running = root.running.filter(entry => entry["title"] !== title)
        }

        function killPid(pid) {
            executable.connectSource(`kill ${pid}`)
            //update running processes list
            root.running = root.running.filter(entry => entry["pid"] !== pid)
        }

        function readStd(pid) {
            executable.connectSource(`cat /tmp/${pid} && exit 20`)
        }

        function sendNotification(title, subtitle, icon) {
            executable.connectSource(`notify-send --icon ${icon} "${title}" "${subtitle}"`)
        }

    }

    fullRepresentation: PlasmaExtras.Representation {
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
                        text: "Launcher"
                        width: tabBar.width/2
                    }

                    TabButton {
                        text: "Actives"
                        width: tabBar.width/2
                    }
                }

                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    currentIndex: tabBar.currentIndex

                    LauncherView {}

                    ActivesView {}

                }
            }
        }
    }
}

