import QtQuick 2.6
import Sailfish.Silica 1.0

Rectangle
{
    id: backgroundrectanglee

    property string color1
    property string color2

    gradient: Gradient {
        GradientStop { position: 0.0; color: color1 ? color1 : Theme.rgba(Theme.highlightBackgroundColor, 0.15) }
        GradientStop { position: 1.0; color: color2 ? color2 :  Theme.rgba(Theme.highlightBackgroundColor, 0.3) }
    }
}
