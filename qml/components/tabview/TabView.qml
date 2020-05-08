import QtQuick 2.6
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import ".."
import "navigationbar"
import "../../models"

Item
{
    property alias dialogs: tabviewdialogs
    property alias navigationBar: navigationbar
    property alias tabBar: tabbar
    property alias miniMenu: minimenu

    property ListModel tabs: ListModel { }
    property ClosedTabsModel closedtabs: ClosedTabsModel { }
    property Component tabComponent: null
 //   property Component Thumb
    property int currentIndex: -1
    property string pageState
    property bool pageLoading
    property bool favorite
    property int guiFactorPotrait: settings.guifactorportrait
    property int guiFactorLandscape: settings.guifactorlandscape
    signal stopLoad()
    signal refresh()

    signal favorites()

    RemorsePopup { id: tabviewremorse }

    id: tabview
    Component.onCompleted: renderTab()
    onCurrentIndexChanged: renderTab()

    onGuiFactorPotraitChanged: {guiUpdate()}
    onGuiFactorLandscapeChanged: {guiUpdate()}

    onPageStateChanged: {
        mainwindow.settings.screenblank.enabled = (pageState !== "mediaplayer");

        if(pageState === "newtab") {
            tabstack.showQuickGrid();
            navigationbar.solidify();
            minimenu.evaporate();
            tabbar.solidify();
        }
        else
           { tabstack.hideQuickGrid();
            minimenu.solidify();
        }

        if(pageState === "mediaplayer")
            navigationbar.evaporate();
        else if(pageState === "mediagrabber")
            navigationbar.solidify();
    }

    function guiUpdate() {
        tabnavbartimer.start();
    }

    function renderTab()
    {
        if(currentIndex === -1)
            return;

        for(var i = 0; i < tabs.count; i++)
        {
            var tab = tabs.get(i).tab;
            if(i === currentIndex)
            {
                tab.webView.setNightMode(mainwindow.settings.nightmode);
                tab.visible = true;
                continue;
            }

            tab.visible = false;
        }
    }

    function addTab(url, foreground, insertpos)
    {
        if(typeof(foreground) === "undefined")
            foreground = true;

        if(!tabComponent) {
            tabComponent = Qt.createComponent(Qt.resolvedUrl("../browsertab/BrowserTab.qml"));

            if(tabComponent.status === Component.Error) {
                console.log(tabComponent.errorString());
                return;
            }
        }

        var tab = tabComponent.createObject(tabstack.stack, { "settings": mainwindow.settings,
                                                              "tabView": tabview,
                                                              "anchors.fill": tabstack.stack,
                                                             // "visible": foreground,
                                                              "hidelater": !foreground,
                                                              "visible": true,
                                                              "title": "",
                                                            //  "thumb": null, //thumb
                                                              "locked": false});

        if(url)
            tab.load(url);

        if(insertpos)
            tabs.insert(insertpos, { "tab": tab });
        else
            tabs.append({ "tab": tab });

        if(foreground)
            currentIndex = insertpos ? insertpos : (tabs.count - 1);

        return tab;
    }

    function removeTab(idx, skipnewtab)
    {
       var tab = tabs.get(idx).tab;
       if(!tab.locked){
        tabs.remove(idx);
        closedtabs.push(tab.title, tab.webUrl);

        tab.parent = null /* Remove Parent Ownership */
        tab.destroy();    /* Destroy the tab immediately */

        if(currentIndex > 0)
            currentIndex--;
        else
           renderTab();

        if(skipnewtab)
            return;

        if(!tabs.count) {
            tabbar.tabsthumb = false;
            currentIndex = -1;
            addTab(mainwindow.settings.homepage);
        }
       }
    }

    function removeAllTabs()
    {
     var idxalltabs = 0;
       while(idxalltabs < tabs.count){
         var tab = tabs.get(idxalltabs).tab;
         if (!tab.locked){removeTab(idxalltabs, true);}
         else{idxalltabs=idxalltabs+1;}
        }
       if(!tabs.count) {
         currentIndex = -1;
         addTab(mainwindow.settings.homepage);
       }
    }

    function tabAt(index)
    {
        if((index < 0) || (index > tabs.count))
            return null;

        var item = tabs.get(index);

        if(!item)
            return null;

        if(item.tab.state === "newtab") {minimenu.evaporate();}
        return item.tab;
    }

    function currentTab()
    {
        return tabAt(currentIndex);
    }

    function lockTab(idx)
    {
        var tab = tabs.get(idx).tab;
        tab.locked=!tab.locked;
    }


    Timer
    {
        id: tabnavbartimer
        interval: 250

        onTriggered: {
            tabbar.evaporate(); tabbar.solidify();
            navigationbar.evaporate(); navigationbar.solidify();
        }
    }

    PopupMessage
    {
        id: popupmessage
        anchors { left: parent.left; top: parent.top; right: parent.right }
    }

    Item
    {
        readonly property real contentHeight: Theme.itemSizeSmall * 4.5

        id: tabcontainer
        anchors.fill: parent

        TabStack
        {
            id: tabstack
            anchors { left: parent.left; right: parent.right; top: parent.top; bottom: tabviewdialogs.top }
            dialogsVisible: tabviewdialogs.dialogVisible
            onHideAll: tabviewdialogs.hideAll()
        }

        TabViewDialogs
        {
            id: tabviewdialogs
            anchors { left: parent.left; bottom: navigationbar.top; right: parent.right  }
        }

        MiniMenu
        {
            id: minimenu
            visible: settings.browsemenu == 2 ? (!(settings.gui === "tablet") ? (isPortrait ? 1 : 0) : 0) : 0
            anchors { left: parent.left; bottom: navigationbar.top; right: parent.right;  }
        }

        NavigationBar
        {
            id: navigationbar
            anchors { left: parent.left; bottom: tabbar.visible ? tabbar.top : parent.bottom; right: parent.right }
        }
        TabBar
        {
            id: tabbar
            visible: {
                if(settings.gui === "tablet"){return true;}
                else if(settings.gui === "tabletlandscape"){
                    if(isLandscape){return true;}
                }
                return false;
            }
            anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
        }
    }
}
