import QtQuick 2.6
import QtWebKit 3.0
import Sailfish.Silica 1.0
import "../components/tabview"
import "../components/items/cover"
import "../models"
import "../js/settings/Sessions.js" as Sessions



Page
{
    property bool rectvis : true
    Rectangle{
        anchors.fill: mainpage
        z: mainpage.z +1
        color: Theme.highlightDimmerColor
        visible: rectvis
        opacity: 1.0
        SequentialAnimation{
            id: hide
            PropertyAnimation {property: "opacity"; to: 0.0; duration: 250; easing.type: Easing.Linear }
            onStopped: {rectvis=false;}

        }

        Image {
            id: webpirateicon
            width: Theme.itemSizeLarge
            height: Theme.itemSizeLarge
            source: "qrc:///res/harbour-webpirate.png"
            anchors {horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter}
            NumberAnimation on rotation {
                from: 0
                to: 360
                loops: Animation.Infinite
                duration: 1500
                alwaysRunToEnd: true

                running: {
                    mainwindow.busy
                }
                onStopped: {hide.start();}
            }
        }
        Label{
            anchors {bottom:parent.bottom; bottomMargin: Theme.itemSizeSmall; horizontalCenter: parent.horizontalCenter}
            text: qsTr("Loading..")
        }
    }

    id: mainpage
    allowedOrientations: defaultAllowedOrientations
    showNavigationIndicator: false
    property string firstLoad
    property var externallink : []

    function loadLink()
    {
       for(var i = 0; i < externallink.length; i++)
        {
           tabview.addTab(externallink[i]);
        }
    }

    Connections
    {
        target: settings
        onNightmodeChanged: tabview.currentTab().webView.setNightMode(settings.nightmode)
    }

    Connections
    {
        target: settings.webpirateinterface

        onUrlRequested: {
           for(var i = 0; i < args.length; i++)
              {
                 externallink = [];
                 externallink.push(args[i]);
                 console.log("opened link: " + externallink[i]);
              }

           if (firstLoad == "true"){
               tabview.removeTab(0, true);
               }
           loadLink();
           mainwindow.activate();
        }
    }

    TabView
    {
        id: tabview
        anchors.fill: parent

        Component.onCompleted: {
            if(Qt.application.arguments.length > 1)  { /* Load requested page */
                console.log("opened link: " + Qt.application.arguments[1]);
                tabview.addTab(Qt.application.arguments[1]);
                return;
            }

            var sessionid = Sessions.startupId();

            if(sessionid === -1){
                if (mainwindow.settings.homepage == "about:newtab"){
                   firstLoad = "true";
                }
                tabview.addTab(mainwindow.settings.homepage);
            }
            else
                Sessions.load(sessionid, tabview);
        }

        Component.onDestruction: {
            if(settings.restoretabs)
                Sessions.save("__temp__session__", tabview.tabs, tabview.currentIndex, true, true, true);
        }
    }

        PageCoverActions
    {
        id: pagecoveractions
        enabled: (mainpage.status === PageStatus.Active) && (((tabview.currentIndex > -1) && tabview.currentTab()) && tabview.currentTab().viewStack.empty)
    }

    CoverActionList
    {
        enabled: mainpage.status !== PageStatus.Active

        CoverAction
        {
            iconSource: "image://theme/icon-cover-cancel"
            onTriggered: pageStack.pop(mainpage, PageStackAction.Immediate)
        }
    }
}
