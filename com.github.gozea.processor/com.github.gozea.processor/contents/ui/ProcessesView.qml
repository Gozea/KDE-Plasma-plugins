import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents

Item {
    id: view

    ColumnLayout {
        anchors.fill: parent

        PlasmaComponents.Label {
            text: "Processes"
        }

        PlasmaComponents.Label {
            text: "Process information will go here."
            opacity: 0.7
        }
    }
}

