import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

Item {
    id: view

    ColumnLayout {
        anchors.fill: parent

        PlasmaExtras.PlaceholderMessage {
            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: view.presets.length === 0

            iconName: "edit-find"
            text: "No active command"

        }

    }
}

