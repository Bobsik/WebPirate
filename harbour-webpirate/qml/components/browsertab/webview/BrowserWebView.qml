import QtQuick 2.1
import QtWebKit 3.0
import Sailfish.Silica 1.0
import "../../../js/UrlHelper.js" as UrlHelper
import "../../../js/settings/Database.js" as Database
import "../../../js/settings/Credentials.js" as Credentials
import "../../../js/settings/History.js" as History
import "../../../js/settings/UserAgents.js" as UserAgents

SilicaWebView
{
    property string lockDownloadAction
    property bool nightModeEnabled: false /* Check if Night Mode is visually active      */
    property bool lockDownload: false     /* Manage Download Requests in a different way */
    property int itemSelectorIndex: -1    /* Keeps the selected index of ItemSelector    */

    function setNightMode(nightmode)
    {
        if(browsertab.state !== "webview")
            return;

        experimental.postMessage(nightmode ? "nightmode_enable" : "nightmode_disable");
    }

    function releaseDownloadLock()
    {
        webView.lockDownload = false;
        webView.lockDownloadAction = "";
    }

    UrlSchemeDelegateHandler { id: urlschemedelegatehandler }
    WebViewListener { id: listener }
    VerticalScrollDecorator { id: vscrolldecorator; flickable: webview }

    PullDownMenu
    {
        id: pulldownmenu
        enabled: webview.visible

        onActiveChanged: {
            if(!active)
                return;

            tabView.navigationBar.solidify();
        }

        MenuItem
        {
            text: qsTr("Duplicate Tab")

            onClicked: {
                if(!selectedTab)
                    return;

                tabView.addTab(webview.url.toString(), false, tabView.currentIndex + 1);
            }
        }

        MenuItem
        {
            text: qsTr("Refresh")
            onClicked: webview.reload()
        }

        MenuItem
        {
            text: qsTr("New tab")
            onClicked: tabView.addTab(mainwindow.settings.homepage)
        }
    }

    Rectangle /* Night Mode Rectangle */
    {
        x: contentX
        y: (mainwindow.settings.nightmode && !webview.nightModeEnabled) ? contentY : (webview.contentHeight - 1)

        width:{
            if(mainwindow.settings.nightmode && !webview.nightModeEnabled)
                return webview.width;

            return Math.max(webview.contentWidth, webview._page.width);
        }

        height:{
            if(mainwindow.settings.nightmode && !webview.nightModeEnabled)
                return webview.height;

            return Math.max(webview.contentHeight, webview._page.height);
        }

        color: "#181818" /* Do not use 100% black */
        visible: mainwindow.settings.nightmode
    }

    id: webview
    implicitWidth: parent.width
    implicitHeight: parent.height
    overridePageStackNavigation: true

    /* Experimental WebView Features */
    experimental.preferences.webAudioEnabled: true
    experimental.preferences.notificationsEnabled: true
    experimental.preferences.webGLEnabled: true
    experimental.preferences.dnsPrefetchEnabled: true
    experimental.preferences.pluginsEnabled: true
    experimental.preferences.javascriptEnabled: true
    experimental.preferences.localStorageEnabled: true
    experimental.preferences.navigatorQtObjectEnabled: true
    experimental.preferences.developerExtrasEnabled: true
    experimental.preferredMinimumContentsWidth: 980 /* "magic" number that proved to work great on the majority of websites */
    experimental.userAgent: UserAgents.get(mainwindow.settings.useragent).value
    experimental.userStyleSheet: mainwindow.settings.adblockmanager.rulesFile

    experimental.userScripts: [ /* Forward 'console' object to Qt's one */
                                Qt.resolvedUrl("../../../js/helpers/Console.js"),

                                /* WebView Utils Functions */
                                Qt.resolvedUrl("../../../js/helpers/Utils.js"),

                                /* Polyfills */
                                Qt.resolvedUrl("../../../js/polyfills/es6-collections.min.js"), /* ES6 Harmony Collections: https://github.com/WebReflection/es6-collections */
                                Qt.resolvedUrl("../../../js/polyfills/canvg.min.js"),           /* SVG Support: https://github.com/gabelerner/canvg */

                                /* Custom WebView Helpers */
                                Qt.resolvedUrl("../../../js/helpers/ForcePixelRatio.js"),
                                Qt.resolvedUrl("../../../js/helpers/WebViewHelper.js"),
                                Qt.resolvedUrl("../../../js/helpers/SystemTextField.js"),
                                Qt.resolvedUrl("../../../js/helpers/NightMode.js"),
                                Qt.resolvedUrl("../../../js/helpers/GrabberBuilder.js"),

                                /* Video Helpers */
                                Qt.resolvedUrl("../../../js/helpers/video/YouTubeHelper.js"),
                                Qt.resolvedUrl("../../../js/helpers/video/DailyMotionHelper.js"),
                                Qt.resolvedUrl("../../../js/helpers/video/VimeoHelper.js"),
                                Qt.resolvedUrl("../../../js/helpers/video/VideoHelper.js"),

                                /* Video Players */
                                Qt.resolvedUrl("../../../js/helpers/video/players/JWPlayerHelper.js"),

                                /* Message Listener */
                                Qt.resolvedUrl("../../../js/helpers/MessageListener.js"),

                                /* Complete Web Notifications Implementation */
                                Qt.resolvedUrl("../../../js/helpers/Notification.js"),

                                /* TOHKBD Support (WebView side) */
                                Qt.resolvedUrl("../../../js/helpers/TOHKBD.js") ]

    experimental.onTextFound: {
        tabView.navigationBar.queryBar.findError = (matchCount <= 0);
    }

    experimental.certificateVerificationDialog: Item {
        Component.onCompleted: {
            tabView.dialogs.showRequest(model, qsTr("Accept Certificate from: %1 ?").arg(webview.url));
        }
    }

    experimental.alertDialog: Item {
        Component.onCompleted: {
            tabView.dialogs.showAlert(model);
        }
    }

    experimental.confirmDialog: Item {
        Component.onCompleted: {
            tabView.dialogs.showRequest(model, message);
        }
    }

    experimental.filePicker: Item { /* FilePicker is particular: A dedicated page suits better */
        Component.onCompleted: {
            if(pageStack.busy)
                pageStack.completeAnimation();

            var page = pageStack.push(Qt.resolvedUrl("../../../pages/selector/SelectorFilesPage.qml"));

            page.actionCompleted.connect(function(action, data) {
                model.accept(data.toString().substring(7)); // Strip "file://"
            });

            page.rejected.connect(function() {
                model.reject();
            });
        }
    }

    experimental.promptDialog: Item { /* PromptDialog is particular: A dedicated page suits better */
        Component.onCompleted: {
            if(pageStack.busy)
                pageStack.completeAnimation();

            pageStack.push(Qt.resolvedUrl("../../../pages/webview/dialogs/PromptDialog.qml"), { "promptModel": model, "title": message, "textField": defaultValue });
        }
    }

    experimental.authenticationDialog: Item { /* AuthenticationDialog is particular: A dedicated page suits better */
        Component.onCompleted: {
            if(pageStack.busy)
                pageStack.completeAnimation();

            pageStack.push(Qt.resolvedUrl("../../../pages/webview/dialogs/AuthenticationDialog.qml"), { "authenticationModel": model })
        }
    }

    experimental.colorChooser: Item {  /* ColorChooser is particular: A dedicated page suits better */
        Component.onCompleted: {
            if(pageStack.busy)
                pageStack.completeAnimation();

            pageStack.push(Qt.resolvedUrl("../../../pages/webview/dialogs/ColorChooserDialog.qml"), { "colorModel": model, "color": model.currentColor });
        }
    }

    experimental.itemSelector: Item {
        Component.onCompleted: {
            tabView.dialogs.showItemSelector(model, browsertab);
        }
    }

    experimental.onMessageReceived: listener.execute(message)
    experimental.onPermissionRequested: tabView.dialogs.showNotification(webview.url.toString(), browsertab)

    experimental.onProcessDidCrash: {
        viewstack.push(Qt.resolvedUrl("../views/LoadFailed.qml"), "loaderror", { "errorString": webview.url, "offline": experimental.offline, "crash": true });
    }

    experimental.onDownloadRequested: {
        var mime = mainwindow.settings.mimedatabase.mimeFromUrl(downloadItem.url);
        var mimeinfo = mime.split("/");

        if((mimeinfo[0] === "video") || (mimeinfo[0] === "audio") || (webview.lockDownload && (webview.lockDownloadAction === "mediaplayer"))) {
            viewstack.push(Qt.resolvedUrl("../views/browserplayer/BrowserPlayer.qml"), "mediaplayer", { "videoTitle": downloadItem.suggestedFilename, "videoSource": downloadItem.url });
            webview.releaseDownloadLock();
            return;
        }

        if(webview.lockDownload) {
            webview.releaseDownloadLock();
            return;
        }

        tabviewremorse.execute(qsTr("Downloading") + " " + downloadItem.suggestedFilename,
                               function() {
                                   mainwindow.settings.downloadmanager.createDownload(downloadItem);
                               });
    }

    onUrlChanged: {
        var stringurl = url.toString();

        if(UrlHelper.isSpecialUrl(stringurl)) {
            manageSpecialUrl(stringurl);
            return;
        }

        browsertab.state = "webview";
    }

    onVerticalVelocityChanged: {
        if(!visible || pulldownmenu.active)
            return;

        if(verticalVelocity < 0)
            tabView.navigationBar.solidify();
        else if(verticalVelocity > 0)
            tabView.navigationBar.evaporate();
    }

    onNavigationRequested: {
        var stringurl = request.url.toString();
        var protocol = UrlHelper.protocol(stringurl);

        if(urlschemedelegatehandler.handleProtocol(protocol, request.url))
        {
            request.action = WebView.IgnoreRequest;
            return;
        }

        if(((protocol !== "http") && (protocol !== "https")) || UrlHelper.isSpecialUrl(stringurl) || (request.navigationType === WebView.FormSubmittedNavigation))
            return;

        if(request.navigationType === WebView.FormResubmittedNavigation)
        {
            request.action = WebView.IgnoreRequest;
            tabView.dialogs.showFormResubmit(stringurl, browsertab);
            return;
        }

        if((request.navigationType === WebView.OtherNavigation) && UrlHelper.domainName(url.toString()) !== UrlHelper.domainName(stringurl))
            return; /* Ignore Other Domain Requests */

        experimental.postMessage("video_get");
    }

    onLoadingChanged: {
        if(loadRequest.status === WebView.LoadStartedStatus)
        {
            if(browsertab.state === "loaderror")
            {
                viewstack.pop(); // Pop out error page
                browsertab.state == "webview";

            }

            if(visible) {
                tabView.dialogs.hideAll();
                tabView.navigationBar.solidify();
                Qt.inputMethod.hide();
            }

            webview.nightModeEnabled = false;
            return;
        }

        if(loadRequest.status === WebView.LoadFailedStatus)
        {
            viewstack.push(Qt.resolvedUrl("../views/LoadFailed.qml"), "loaderror", { "errorString": loadRequest.errorString, "offline": experimental.offline, "crash": false });
            return;
        }

        if(loadRequest.status === WebView.LoadSucceededStatus)
        {
            var stringurl = url.toString();

            if(!UrlHelper.isSpecialUrl(stringurl) && UrlHelper.isUrl(stringurl))
            {
                experimental.postMessage("forcepixelratio");
                experimental.postMessage("polish_view");
                experimental.postMessage("video_get");
                experimental.postMessage("textfield_override");

                webview.setNightMode(mainwindow.settings.nightmode);

                Credentials.compile(Database.instance(), stringurl, webview);
                History.store(stringurl, title);
            }
        }
    }
}
