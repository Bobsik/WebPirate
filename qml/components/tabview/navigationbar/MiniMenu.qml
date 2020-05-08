import QtQuick 2.6
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0
import "../../browsertab/webview"
import "../../../components"
import "../../../js/settings/Favorites.js" as Favorites

Rectangle{
    readonly property real rectheight: Theme.itemSizeSmall/1.6
    property string target: 'newtab'
    property var tab: getTab()

    function getTab(){
        if(typeof(tabs.get(currentIndex)) != 'undefined'){
            return tabs.get(currentIndex).tab;
        }
            return null;
    }

    function solidify(){
        if(settings.browsemenu == 2){height = rectheight;}
    }

    function evaporate(){
        if(pageLoading) { // Disallow evaporation
            solidify();
            return;
        }
          height = 0;
    }

    function isloading()
    {
        //při přepnutí panelu se změní index a při změně zpět se to srovná
        if(tab){
           reloadiconreload.stop();
           if(tab.webView.loading){return "image://theme/icon-m-cancel";}
           else if(!tab.webView.loading){return "image://theme/icon-m-reload";}
          }
        else{
            reloadiconreload.start();
            return "image://theme/icon-m-question";
        }
    }

    function newTab(){
        tabview.addTab(settings.homepage,false);
    }

    function openNewTab(){
        tabview.addTab(settings.homepage,false);
        if(settings.homepage == "about:newtab"){
            tabstack.showQuickGrid();
            minimenu.visible = false;
            pageStack.pop();
        }
    }

    function gradseqtarget(){
        if (target == 'newtab')
        {
            return newtabbggradient;
        }
        if (target == 'stoprefresh')
        {
            return refreshstopbggradient;
        }
        if (target == 'favorite')
        {
            return favoritebggradient;
        }
        if (target == 'settings')
        {
            return settingsbggradient;
        }
    }

    Behavior on height {
        PropertyAnimation { duration: 250; easing.type: Easing.Linear }
    }

    height: settings.browsemenu == 2 ? rectheight : 0
    visible: height > 0
    color: "transparent"

    Timer{
        id:reloadiconreload
        interval: 1
        onTriggered: tab=getTab();
    }

    LinearGradient
    {
        anchors.fill: parent
        start: Qt.point(0, 0)
        end: Qt.point(0, parent.height)

        gradient: Gradient {
           GradientStop { position: 0.0; color: "transparent" }
           GradientStop { position: 0.6; color: Theme.highlightDimmerColor }
        }
    }

    SequentialAnimation{
        id: gradseq
        NumberAnimation { target: gradseqtarget(); property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
        NumberAnimation { target: gradseqtarget(); property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
    }

Row
{
  visible: true

Rectangle
    {
        id: newtabbutton
        width: isPortrait? (Screen.width /4) : (Screen.height / 4)
        height: Theme.itemSizeSmall/1.6
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
            source: "image://theme/icon-m-new"
            anchors { margins: Theme.itemSizeSmall; horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter  }
            fillMode: Image.PreserveAspectFit
          }
          MouseArea { anchors.fill: parent;  onClicked:{
                  newTab();
                  target='newtab';
                  gradseq.start();
              }
          }//onPressAndHold: openNewTab()  }

    }

Rectangle{
        id: refreshstopbutton
        width: isPortrait? (Screen.width /4) : (Screen.height / 4)
        height: Theme.itemSizeSmall/1.6
        color: "transparent"
        LinearGradient
        {
            id: refreshstopbggradient
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
            id: imgrefreshstop
            height: parent.height * 0.75
            width: parent.width * 0.75
            source: isloading()
            anchors { margins: Theme.itemSizeSmall; horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter  }
            fillMode: Image.PreserveAspectFit
        }
        MouseArea { anchors.fill: parent; onClicked: {
                getTab();
                if(tab.webView.loading){
                    stopLoad();}
                else {
                    refresh();}
                target='stoprefresh';
                gradseq.start();
           }
        }
}

Rectangle
    {
        id: favoritebutton
        width: isPortrait? (Screen.width /4) : (Screen.height / 4)
        height: Theme.itemSizeSmall/1.6
        color: "transparent"
        LinearGradient
        {
            id: favoritebggradient
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
            id: imgfavorite
            height: parent.height * 0.75
            width: parent.width * 0.75
            source:  tabview.currentTab().favorite ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
            anchors { margins: Theme.itemSizeSmall; horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter  }
            fillMode: Image.PreserveAspectFit
        }
          MouseArea { anchors.fill: parent; onClicked: {
                  favorites();
                  tabview.favorite=!tabview.favorite;
                  target='favorite';
                  gradseq.start();
              //    forceLayout();
               }
          }
}

Rectangle
    {
        id: settingsbutton
        width: isPortrait? (Screen.width /4) : (Screen.height / 4)
        height: Theme.itemSizeSmall/1.6
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
            height: parent.height * 0.75
            width: parent.width * 0.75
            source: "image://theme/icon-m-developer-mode"
            anchors { margins: Theme.itemSizeSmall; horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter  }
            fillMode: Image.PreserveAspectFit
        }
        MouseArea { anchors.fill: parent; onClicked: {
                target='settings';
                gradseq.start();
                pageStack.push(Qt.resolvedUrl("../../../pages/settings/SettingsPage.qml"), { "settings": settings })
               }
            }
    }
}
}
