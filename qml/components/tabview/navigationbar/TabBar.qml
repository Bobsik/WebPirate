import QtQuick 2.6
import QtWebKit 3.0
import Sailfish.Silica 1.0
import "../../"
import "../../items/tab"
import "../../navigationbar"
import "../../../models"
import "../../../models/navigationbar"

Rectangle
{
    /* readonly */property real contentHeight: Math.round(Theme.itemSizeExtraSmall  * (isPortrait ? settings.guifactorportrait : settings.guifactorlandscape))
    property bool tabsthumb
    property string gradColor: Qt.darker(Theme.highlightBackgroundColor, 5)

    readonly property WebView webView: {
        var currenttab = tabview.currentTab();

        if(!currenttab)
            return null;

        return currenttab.webView;
    }

    function solidify() {
        tabsthumb = false;
        height = contentHeight;
    }

    function evaporate() {
        if(pageLoading) { // Disallow evaporation
            solidify();
            return;
        }
        tabsthumb = false;
        height = 0;
    }

    Behavior on height {
        PropertyAnimation { duration: 250; easing.type: Easing.Linear }
    }

    id: tabbar
    width: Screen.width
    height: contentHeight
    color: Theme.highlightDimmerColor
    visible: height > 0
    clip: true
    z: 50

    onTabsthumbChanged: {
        if(tabsthumb == true){
            height = height * 2.5;
            gradColor = "transparent"
        }
        else{
            height = height / 2.5;
            gradColor = Qt.darker(Theme.highlightBackgroundColor, 5)
        }
        content.visible = !content.visible;
    }


    Timer{
        id: tmrunvisible
        interval: 50
        onTriggered:{
            var tabs = tabview.tabs
            for(var i = 0; i < tabs.count; i++)
            {
                var tab = tabs.get(i).tab;
                if(i !== currentIndex){tab.visible = false;}
                console.log(tab.title);
            }
        }
    }
    BackgroundRectangle {
        visible: content.visible
        anchors{right: parent.right; top: parent.top; bottom: parent.bottom}
        width: content.width
        color1: Qt.darker(Theme.highlightBackgroundColor, 2)
        color2: Qt.darker(Theme.highlightBackgroundColor, 3)
        z: content.z
    }

    BackgroundRectangle {
        anchors.fill: parent
        color1: Qt.darker(Theme.highlightBackgroundColor, 2)
        color2: Qt.darker(Theme.highlightBackgroundColor, 3)
        z: content.z-3
    }

    Row{

        id: contenttabs
        anchors{left: parent.left; top: parent.top; bottom: parent.bottom}
        width: tabbar.width - content.width
        z: content.z-2
        ImageButton
        {
            id: niback
            visible: false
            height: parent.height
            width: visible ? parent.height : 0
            highlighted: content.selectedItem === niback
            source: "qrc:///res/back.png"
        }

        SilicaListView
        {
            id: tabslistview
            orientation: ListView.Horizontal
            boundsBehavior: Flickable.StopAtBounds
            height: parent.height
            model: tabview.tabs
            width: tabbar.width-niback.width-niforward.width-content.width
            z: parent.z -1
            delegate: TabListItemSmall{
                height: tabbar.height
                width: Math.round(Theme.itemSizeExtraLarge * 1.3 * (isPortrait ? settings.guifactorportrait : settings.guifactorlandscape))
                highlighted: model.index === tabview.currentIndex
                tab: {tabview.tabAt(model.index)}
                onCloseRequested: {
                    tabview.removeTab(model.index);
                }
                onLockRequested: {
                    tabview.lockTab(model.index);}
                onClicked: {
                    tabsthumb = false;
                    gradColor = Qt.darker(Theme.highlightBackgroundColor, 5)
                    tabview.currentIndex = model.index;
                }
            }

        }

        ImageButton
        {
            id: niforward
            visible: false
            height: parent.height
            width: visible ? parent.height : 0
            highlighted: content.selectedItem === niforward
            source: "qrc:///res/forward.png"
        }
    }

    Row{
        property Item selectedItem: null

        id: content
        anchors{right: parent.right; top: parent.top; bottom: parent.bottom}
        width: visible ? btnaddtab.width + btnhome.width + btntabs.width : 0
        z: 50

        ImageButton
        {
            id: btnaddtab
            height: parent.height
            sourceheight: Theme.iconSizeMedium * 0.8
            sourcewidth: sourceheight
            width: visible ? parent.height : 0
            highlighted: content.selectedItem === btnaddtab
            source: "image://theme/icon-m-new"
            z: tabslistview.z +1
            onClicked: {tabview.addTab(settings.homepage); tabslistview.update();}
        }

        ImageButton
        {
            id: btnhome
            height: parent.height
            width: visible ? parent.height : 0
            highlighted: content.selectedItem === btnhome
            source:{ if(pressed){return "image://theme/icon-m-developer-mode";}
                     return "image://theme/icon-m-home";
                   }
            z: tabslistview.z +1
            onClicked: {
                var currenttab = tabview.currentTab();

                if(!currenttab)
                    return;

                currenttab.load(settings.homepage);
            }
            onPressAndHold: {
                pageStack.push(Qt.resolvedUrl("../../../pages/settings/SettingsPage.qml"), { "settings": settings });}
        }

        ImageButton
        {
        id: btntabs
        width: tabbar.contentHeight
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        z: tabslistview.z +1

        visible: {
            var tab = currentTab();

            if(!tab || !tab.viewStack.empty)
                return false;

            return true;
        }

        source: {
            var tab = currentTab();

            if(!navigationbar.normalMode || (tab && !tab.viewStack.empty))
                return "image://theme/icon-close-app";

            return "image://theme/icon-m-tabs";
        }

        onClicked: {
            if(navigationbar.searchMode) {
                navigationbar.searchMode = false;
                webView.experimental.findText("", 0);
                return;
            }

            var tab = currentTab();

            if(navigationbar.clipboardMode) {
                tab.cancelSelection();
                navigationbar.clipboardMode = false;
                return;
            }

            pageStack.push(Qt.resolvedUrl("../../../pages/segment/SegmentsPage.qml"), { "settings": settings, "tabView": tabview });
        }

        onPressAndHold: {
            var tab = currentTab();

            if(!navigationbar.normalMode || (tab.state !== "webview"))
                return;

            navigationbar.searchMode = true;
        }

        NumberAnimation on rotation {
            from: 0
            to: 90
            loops: Animation.Infinite
            duration: 500
            alwaysRunToEnd: true

            running: {
                if(navigationBar.searchMode || navigationBar.clipboardMode || !navigationBar.webView)
                    return false;

                var tab = currentTab();

                if(!tab || !tab.viewStack.empty || (tab.state !== "webview"))
                    return false;

                return navigationBar.webView.loading;
            }
        }

        Label
        {
            anchors.centerIn: parent
            font.pixelSize: Math.round(Theme.fontSizeSmall * (isPortrait ? settings.guifactorportrait : settings.guifactorlandscape))
            font.bold: true
            text: tabview.tabs.count
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            visible: navigationbar.normalMode && currentTab() && currentTab().viewStack.empty
            rotation: -btntabs.rotation
            z: -1
        }
    }
  }
}

