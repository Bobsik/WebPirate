import QtQuick 2.6
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import "../items/tab"
import "../../components"
//import "../../pages/segment/SegmentsPage.qml"

SilicaFlickable
{
    function load() { }
    function unload() { }

    Loader{
        sourceComponent: !settings.tabminen ? pulldownmenu : null
    }
    Component{
        id: pulldownmenu
        PullDownMenu
         {
             MenuItem
             {
              text: qsTr("Settings")
              onClicked: pageStack.push(Qt.resolvedUrl("../../pages/settings/SettingsPage.qml"), { "settings": settings })
             }

             MenuItem
             {
              text: settings.nightmode ? qsTr("Disable Night Mode") : qsTr("Enable Night Mode")
              onClicked: { settings.nightmode = !settings.nightmode; }
             }

             MenuItem
             {
              text: qsTr("Close all tabs")
              onClicked: { tabView.removeAllTabs() }
             }

             MenuItem
             {
              text: qsTr("New Tab")
              onClicked: { tabView.addTab(settings.homepage); }
             }
         }
      }
//    PageHeader
//    {
//        id: pageheader
//        anchors { left: parent.left; top: parent.top; right: parent.right }
//        title: qsTr("Tabs")
//    }


    SilicaGridView
    {
        id: tabssegment    
        anchors { left: parent.left; top: parent.top ; right: parent.right; bottom: parent.bottom }
        verticalLayoutDirection: GridView.BottomToTop
        layoutDirection: Qt.LeftToRight
        model: tabView.tabs
         cellWidth: isPortrait ? parent.width : Screen.height / 2
         cellHeight: isPortrait ? Theme.itemSizeMedium : Theme.itemSizeLarge
    //    quickScroll: false

        clip: false

        add: Transition {
                 NumberAnimation { property: "x"; duration: 500; from: -(tabssegment.width); easing.type: Easing.InBack }
        }
        remove: Transition {
                 NumberAnimation { property: "x"; duration: 500; to: tabssegment.width; easing.type: Easing.InBack }
        }

        removeDisplaced: Transition {
            NumberAnimation { property: "y"; duration: 500; easing.type: Easing.InBack }
        }

        delegate: TabListItem {
            height: isPortrait ? Theme.itemSizeMedium : Theme.itemSizeLarge
            contentHeight: isPortrait ? Theme.itemSizeMedium : Theme.itemSizeLarge

            highlighted: model.index === tabView.currentIndex
            leftHanded: settings.lefthanded
            tab: {tabView.tabAt(model.index)}
            onCloseRequested: {
                tabView.removeTab(model.index)}
            onLockRequested: {
                tabView.lockTab(model.index);}
            onClicked: {
                tabView.currentIndex = index;
                pageStack.pop();
            }
        }

        Rectangle{
            id: tabssegmentbuttons
            anchors { left: parent.left; top: parent.bottom; right: parent.right }
            height: settings.tabminen ? (Theme.itemSizeSmall / (isPortrait ? 1.4 : 1.2)) : 0
            visible: height > 0

            color: "transparent"
            LinearGradient
            {
                anchors.fill: parent
                start: Qt.point(parent.width, 0)
                end: Qt.point(parent.width, parent.height)

                gradient: Gradient {
                   GradientStop { position: 0.0; color:  Theme.highlightDimmerColor }
                   GradientStop { position: 1.0; color:  "transparent" }
                }
            }

          TabSegmentMiniMenu {

            anchors.centerIn: parent
                    leftHanded: settings.lefthanded
                    onNewTab:{
                            tabView.addTab(mainwindow.settings.homepage, false);
                        }
                    onOpenNewTab: {
                        tabView.addTab(mainwindow.settings.homepage);
                        tabView.currentIndex = tabView.tabs.count-1;
                        pageStack.pop();
                        }
                    onCloseAllTabs: {
                        tabView.removeAllTabs();
                        }
                    onChangeNightMode: {settings.nightmode = !settings.nightmode;}
                    onOpenSettings:{pageStack.push(Qt.resolvedUrl("../../pages/settings/SettingsPage.qml"), { "settings": settings })}
          }
       }
    }
}
