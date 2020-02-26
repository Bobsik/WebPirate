import QtQuick 2.6
import Sailfish.Silica 1.0

Rectangle
{
    id: backgroundrectanglee

    gradient: Gradient {
        GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.15) }
        GradientStop { position: 1.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.3) }
    }
}
