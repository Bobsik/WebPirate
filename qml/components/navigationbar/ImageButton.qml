import QtQuick 2.6
import Sailfish.Silica 1.0

BackgroundItem
{
    property string source
    property real sourcewidth
    property real sourceheight


    id: imagebutton

    Image
    {
        anchors.centerIn: parent
        width: Math.round((isPortrait ? settings.guifactorportrait : settings.guifactorlandscape) * (sourcewidth ? sourcewidth : Theme.iconSizeMedium))
        height: Math.round((isPortrait ? settings.guifactorportrait : settings.guifactorlandscape) * (sourceheight ? sourceheight : Theme.iconSizeMedium))
        opacity: imagebutton.enabled ? 1.0 : 0.4

        source: {
            if(imagebutton.pressed)
                return imagebutton.source + "?" + Theme.highlightColor;

            return imagebutton.source;
        }
    }
}
