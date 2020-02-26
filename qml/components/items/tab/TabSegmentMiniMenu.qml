import QtQuick 2.6
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0

Row{
    property var tab
    property bool highlighted: false
    property bool leftHanded: false
    property string target: 'newtab'

    signal newTab()
    signal openNewTab()
    signal closeAllTabs()
    signal changeNightMode()
    signal openSettings()

    function gradseqtarget(){
        if (target == 'newtab')
        {
            return newtabbggradient;
        }
        if (target == 'closeall')
        {
            return closeallbggradient;
        }
        if (target == 'settings')
        {
            return settingsbggradient;
        }
    }
    SequentialAnimation{
        id: gradseq
        NumberAnimation { target: gradseqtarget(); property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
        NumberAnimation { target: gradseqtarget(); property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
    }

    id: tabssegmentbuttons

Rectangle
    {
        id: newtabbutton
        width: Screen.width /4
        height: Theme.itemSizeSmall/(isPortrait ? 1.5 : 1.3)
        color: "transparent"
        LinearGradient
        {
            id: newtabbggradient
            visible:true
            opacity: 0.0
            anchors.fill: parent
            start: Qt.point(parent.width, 0)
            end: Qt.point(parent.width, parent.height)

            gradient: Gradient {
               GradientStop { position: 0.0; color: "transparent" }
               GradientStop { position: 0.7; color: Theme.highlightColor }
            }
        }
        Image {
            id: imgnewtab
            height: parent.height * 0.75
            width: parent.width * 0.75
            source: "qrc:///res/add-tabssegment.png"
            anchors { margins: Theme.itemSizeSmall; horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter  }
            fillMode: Image.PreserveAspectFit
          }
          MouseArea { anchors.fill: parent;
                      onClicked: {
                      newTab();
                      target='newtab';
                      gradseq.start();
                      }
                      onPressAndHold: openNewTab()
          }
    }

Rectangle{
        id: closeallbutton
        width: Screen.width /4
        height: Theme.itemSizeSmall/(isPortrait ? 1.5 : 1.3)
        color: "transparent"
        LinearGradient
        {
            id: closeallbggradient
            visible:true
            opacity: 0.0
            anchors.fill: parent
            start: Qt.point(parent.width, 0)
            end: Qt.point(parent.width, parent.height)

            gradient: Gradient {
               GradientStop { position: 0.0; color: "transparent" }
               GradientStop { position: 0.7; color: Theme.highlightColor }
            }
        }
        Image {
            id: imgcloseall
            height: parent.height * 0.75
            width: parent.width * 0.75
            source: "qrc:///res/close-all.png"
            anchors { margins: Theme.itemSizeSmall; horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter  }
            fillMode: Image.PreserveAspectFit
        }
        MouseArea { anchors.fill: parent; onClicked: {
                target='closeall';
                gradseq.start();
                closeAllTabs();
            }
        }
}

Rectangle
    {
        id: nightmodebutton
        width: Screen.width /4
        height: Theme.itemSizeSmall/(isPortrait ? 1.5 : 1.3)
        color: "transparent"
        LinearGradient
        {
            id: nightmodebggradient
            visible:true
            opacity: settings.nightmode ? 1.0 : 0.0
            anchors.fill: parent
            start: Qt.point(parent.width, 0)
            end: Qt.point(parent.width, parent.height)

            gradient: Gradient {
               GradientStop { position: 0.0; color: "transparent" }
               GradientStop { position: 0.7; color: Theme.highlightColor }
            }
        }
        Image {
            id: imgnightmode
            height: parent.height * 0.75
            width: parent.width * 0.75 / 2
            source:  "qrc:///res/nightmode-tab-on.png"
             anchors { margins: Theme.itemSizeSmall; horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter  }
            fillMode: Image.PreserveAspectFit
        }
        Behavior on opacity {
            PropertyAnimation { duration: 150; easing.type: Easing.Linear }
        }
        MouseArea { anchors.fill: parent; onClicked:
               {
                changeNightMode();
            }
        }
}

Rectangle
    {
        id: settingsbutton
        width: Screen.width /4
        height: Theme.itemSizeSmall/(isPortrait ? 1.5 : 1.3)
        color: "transparent"
        LinearGradient
        {
            id: settingsbggradient
            visible:true
            opacity: 0.0
            anchors.fill: parent
            start: Qt.point(parent.width, 0)
            end: Qt.point(parent.width, parent.height)

            gradient: Gradient {
               GradientStop { position: 0.0; color: "transparent" }
               GradientStop { position: 0.7; color: Theme.highlightColor }
            }
        }
        Image {
            id: imgsettings
            height: parent.height * 0.85
            width: parent.width * 0.85
            source: "image://theme/icon-m-developer-mode"
            anchors { margins: Theme.itemSizeSmall; horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter  }
            fillMode: Image.PreserveAspectFit
        }
        MouseArea { anchors.fill: parent; onClicked: {
                target='settings';
                gradseq.start();
                openSettings();
            }
        }
    }
}
