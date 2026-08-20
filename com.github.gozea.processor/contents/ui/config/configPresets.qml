import QtQuick
import org.kde.plasma.configuration

Item{
    id: configPresets

    property alias cfg_presetName: presetName.text

    Text {
        id: presetName
    }
}
