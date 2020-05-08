import QtQuick 2.6
import QtGraphicalEffects 1.0
import QtWebKit 3.0
import Sailfish.Silica 1.0

ListItem
{
    property var tab
    property bool highlighted: false
    property bool leftHanded: false
    property string target: 'duplicate'
    property real faviconMultiplier

    signal closeRequested()
    signal lockRequested()

    function update() {
        if(!visible || !tab || !tab.thumbUpdated)
            return;

        thumb.scheduleUpdate();
        tab.thumbUpdated = false;
    }

    function tablocked(){
        if (tab){
            if(tab.locked){
               return "qrc:///res/locked.png";
            }
            if(!tab.locked){
               return "qrc:///res/unlocked.png";
            }
        }
        return "";
    }

    function tabtitle(){
        if(tab != null){
          if(tab.title !== null)
           {
            if(tab.state === "newtab")
            return qsTr("Quick Grid");

            if(tab.state === "loaderror")
            return qsTr("Load error");

            if(tab.state === "mediagrabber")
            return qsTr("Grabber");

            if(tab.state === "mediaplayer")
            return qsTr("Media Player");
        }

        if(typeof(tab.title) !== "undefined")
         {
          if(tab.title !== "") {return tab.title;}
         }
      }
        return "";
    }

    function fav(){
    if(tab !=  null){
     if(tab.webView.icon != ""){ faviconMultiplier = 1.2; return tab.webView.icon;}
     if(tab.state === "newtab"){ faviconMultiplier = 2; return "qrc:///res/quickgrid.png";}
     if(tab.state === "loaderror"){ faviconMultiplier = 2; return "qrc:///res/loaderror_white.png";}
     if(tab.state === "mediagrabber"){ faviconMultiplier = 2; return "qrc:///res/grabber.png";}
     if(tab.state === "mediaplayer"){ faviconMultiplier = 2; return "image://theme/icon-l-play";}
     return "";
  }
  return "";
}

    function switchConmenu()
    {
         conmenu.visible=true;
         gradseqconmenu.start();
         content.visible=false;
    }

    function switchContent()
    {
         conmenu.visible=false;
         gradseqcontent.start();
         content.visible=true;
    }

    function gradseqtarget(){
        if (target == 'duplicate')
        {
            return con_duplicate;
        }
        if (target == 'copy')
        {
            return con_copylink;
        }
        if (target == 'cancel')
        {
            return con_cancel;
        }
  //      if (target == 'reader')
  //      {
  //          return readermodebggradient;
  //      }
    }

    function readerMode()
    {
        var imagetypes = ['.jpg','jpeg','.png','.gif'];
        var isImage = false;
        for(var i = 0; i < imagetypes.length ; i++)
        {
            if (tab.webUrl.indexOf(imagetypes[i]) === (tab.webUrl.length - 4) )
            {
                if(tab.title.indexOf(imagetypes[i]) !== -1){
                isImage = true;
                }
            }
        }
        var start = tab.webUrl.indexOf("about:");

        if((start === 0) || (isImage === true))
            { return false; }
        else{ return true; }
    }

    id: tablistitem
    _showPress: false
    onPressAndHold: switchConmenu()
    onVisibleChanged: {
        update();
    }
      opacity: 0.0
      Component.onCompleted: {opacity = 1.0;
      }

      Behavior on opacity{
           PropertyAnimation {duration: 50;}
      }

    drag.target: content
    drag.axis: Drag.XAxis
    drag.maximumX: content.width
    drag.minimumX: 0

    onWidthChanged: {
        if(isPortrait == true){
           content.x = 0;
           return;
        }
      //  content.x = content.defaultX; // Reposition Item
    }

    drag.onActiveChanged: {
        if(drag.active)
            return;

        if(content.x > ((content.defaultX + content.width) / 2.0))
            closeRequested();

           content.x = 0;
           return;
        //content.x = content.defaultX;
    }

    SequentialAnimation{
        id: gradseqconmenu
        NumberAnimation { target: conmenu; property: "opacity"; from: 0.0; to: 1.0; duration: 300 }
        NumberAnimation { target: content; property: "opacity"; from: 1.0; to: 0.0; duration: 500 }
    }

    SequentialAnimation{
        id: gradseqcontent
        NumberAnimation { target: content; property: "opacity"; from: 0.0; to: 1.0; duration: 300 }
        NumberAnimation { target: conmenu; property: "opacity"; from: 1.0; to: 0.0; duration: 500 }
    }

    SequentialAnimation{
        id: gradseq
        ColorAnimation { target: gradseqtarget(); property: "color"; to: Theme.highlightColor; duration: 200 }
        ColorAnimation { target: gradseqtarget(); property: "color"; to: "transparent"; duration: 100 }
  //      alwaysRunToEnd: true
        onStopped: {
                    switchContent();}
    }

    Connections { target: tab; onThumbUpdatedChanged: {update();} }

    Item
    {
        readonly property bool webviewVisible: tab && (tab.state === "webview")
        readonly property real defaultX: (parent.width / 2) - (width / 2)

        id: content
        //x: defaultX
        width: isPortrait ? Screen.width : Screen.height/2
        height: isPortrait ? Theme.itemSizeMedium : Theme.itemSizeLarge

        visible: true

        Behavior on x { PropertyAnimation { duration: 250; easing.type: Easing.OutBack } }

        Image
        {
          id: favicon
          anchors { left: parent.left; bottom: parent.bottom; leftMargin: Theme.paddingSmall; bottomMargin: Theme.paddingMedium }
          width: fav() != "" ? Theme.iconSizeSmall * faviconMultiplier : 0
          height: Theme.iconSizeSmall * faviconMultiplier
          fillMode: Image.PreserveAspectFit
          LayoutMirroring.enabled: tablistitem.leftHanded
          z: parent.z +1
          source: fav()
         }

        Item
        {
            id: effectitem
            anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right:parent.right; rightMargin: buttonsrect.width;  }

            Rectangle { id: specialthumb;
                anchors.fill: parent
                visible: !content.webviewVisible;
                color: highlighted ? Theme.secondaryHighlightColor : "gray"
            }

            ShaderEffectSource
            {
                id: thumb
                anchors.fill: parent
                live: false
                sourceItem: tab ? tab.webView : null
                sourceRect: Qt.rect(0, 0, effectitem.width, Theme.itemSizeLarge)
                visible: content.webviewVisible
            }

            Label
            {
                 anchors { left: parent.left; bottom: parent.bottom; leftMargin: (Theme.paddingSmall*2)+favicon.width; bottomMargin: Theme.paddingMedium }
                //x: tablistitem.leftHanded ? Theme.paddingMedium : (parent.width - contentWidth - Theme.paddingMedium)
                width: parent.width - (tablistitem.leftHanded ? (x * 2) : x)
                font { family: Theme.fontFamilyHeading; pixelSize: Theme.fontSizeMedium }
                verticalAlignment: Text.AlignBottom
                horizontalAlignment: Text.AlignLeft
                truncationMode: TruncationMode.Fade
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                z: effectitem.z + 1

                text: tabtitle()
            }

            LinearGradient
            {
                anchors.fill: effectitem
                start: Qt.point(parent.width, 0)
                end: Qt.point(parent.width, parent.height)

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.9; color: "black" }
                }
            }
        }

        Desaturate
        {
            anchors.fill: effectitem
            source: effectitem
            desaturation: highlighted ? 0.0 : 1.0
            visible: content.webviewVisible
        }

        Rectangle{
            id: buttonsrect
            color: "transparent"
            width: Theme.itemSizeExtraSmall
            border.color: Theme.highlightDimmerColor
            anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
          Image {
            id: imgclose
            source: "image://theme/icon-m-close"
            anchors { right: parent.right; top: parent.top; rightMargin: Theme.paddingSmall; topMargin: isPortrait ? 0: Theme.paddingExtraSmall }
            LayoutMirroring.enabled: tablistitem.leftHanded

            MouseArea { anchors.fill: parent; onClicked: closeRequested() }
          }

          Image {
            id: imglock
            width: Theme.itemSizeExtraSmall * 0.6
            height: Theme.itemSizeExtraSmall * 0.6
            source: tablocked() //tab.locked? "qrc:///res/locked.png" : "qrc:///res/unlocked.png"
            anchors { horizontalCenter: imgclose.horizontalCenter; bottom: parent.bottom; bottomMargin: isPortrait ? 0: Theme.paddingExtraSmall  }
            LayoutMirroring.enabled: tablistitem.leftHanded

            MouseArea { anchors.fill: parent; onClicked: lockRequested() }
         }
        }
    }

    Item
    {
        id: conmenu
        visible: false
        width: isPortrait ? Screen.width : Screen.height/2
        height: isPortrait ? Theme.itemSizeMedium : Theme.itemSizeLarge
        Rectangle
        {
            anchors.fill: parent
            color: "transparent"
        }

 //       LinearGradient
 //       {
 //           anchors.fill: parent
 //           start: Qt.point(parent.width, 0)
 //           end: Qt.point(parent.width, parent.height)

 //           gradient: Gradient {
 //               GradientStop { position: 0.2; color: "transparent" }
 //               GradientStop { position: 0.5; color: "black" }
 //               GradientStop { position: 0.8; color: "transparent" }
 //           }
 //           z:parent.z -1
 //       }

        Row
        {
            width: isPortrait ? Screen.width : Screen.height/2
            height: Theme.itemSizeLarge

           Column{
              width: isPortrait ? Screen.width*0.4 : Screen.height*0.4/2
              height: Theme.itemSizeLarge

            Rectangle
            {
                id: con_duplicate
                width: parent.width
                height: Theme.itemSizeLarge /2
                color: "transparent"
                Label
                {   id: con_lblduplicate
                    anchors {verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: Theme.paddingSmall}
                    text:"Duplicate"
                }

                Image {
                    id: con_imgduplicate
                    height: parent.height * 0.75
                    width: parent.width * 0.20
                    source: "image://theme/icon-s-group-chat"
                    anchors {right: parent.right; rightMargin: Theme.paddingSmall; verticalCenter: parent.verticalCenter }
                    fillMode: Image.PreserveAspectFit
                  }
                 MouseArea { anchors.fill: parent;
                              onClicked: {
                                  tabView.addTab(tab.webUrl, false, model.index + 1);
                           //       switchContent();
                                  target = 'duplicate';
                                  gradseq.start();
                               }
                  }
              }

            Rectangle
            {
                id: con_copylink
                width: parent.width
                height: Theme.itemSizeLarge /2
                color: "transparent"
                Label
                {   id: con_lblcopylink
                    anchors {verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: Theme.paddingSmall}
                    text:"Copy link"
                }

                Image {
                    id: con_imgcopylink
                    height: parent.height * 0.75
                    width: parent.width * 0.20
                    source: "image://theme/icon-m-clipboard"
                    anchors {right: parent.right; rightMargin: Theme.paddingSmall; verticalCenter: parent.verticalCenter }
                    fillMode: Image.PreserveAspectFit
                  }
                 MouseArea { anchors.fill: parent;
                              onClicked: {
                                  popupmessage.show(qsTr("Link copied to clipboard"));
                                  settings.clipboard.copy(tab.webUrl);
                           //       switchContent();
                                  target = 'copy';
                                  gradseq.start();
                              }
                  }
              }
            }

           Rectangle
           {
               id: con_cancel
               width: parent.width*0.2
               height: Theme.itemSizeLarge
               color: "transparent"

               Image {
                   id: con_imgcancel
                   height: parent.height * 0.75
                   width: parent.width * 0.75
                   source: "image://theme/icon-m-clear"
                   anchors { margins: Theme.itemSizeSmall; horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter  }
                   fillMode: Image.PreserveAspectFit
                 }
                MouseArea { anchors.fill: parent;
                             onClicked: {
                      //           switchContent();
                                 target = 'cancel';
                                 gradseq.start();
                             }
                 }
             }

           Column{
              width: isPortrait ? Screen.width*0.4 : Screen.height*0.4/2
              height: Theme.itemSizeLarge

            Rectangle
            {
                id: con_savepage
                width: parent.width
                height: Theme.itemSizeLarge /2
                color: "transparent"
                Label
                {   id: con_lblsavepage
                    anchors {verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: Theme.paddingSmall}
                    text:"Save Page"
                }

                Image {
                    id: con_imgsavepage
                    height: parent.height * 0.75
                    width: parent.width * 0.20
                    source: "image://theme/icon-m-device-download"
                    anchors {right: parent.right; rightMargin: Theme.paddingSmall; verticalCenter: parent.verticalCenter }
                    fillMode: Image.PreserveAspectFit
                  }
                 MouseArea { anchors.fill: parent;
                              onClicked: {
                                  tablistitem.remorseAction(qsTr("Downloading web page"), function () {
                                  tab.webView.experimental.evaluateJavaScript("(function() { return document.documentElement.innerHTML; })()",
                                  function(result) { settings.downloadmanager.createDownloadFromPage(result); }) });
                                  switchContent();
                              }
                  }
              }

            Rectangle
            {
                id: con_readermode
                width: parent.width
                height: Theme.itemSizeLarge /2
                color: "transparent"
                enabled: tab ? readerMode() : false
                visible: tab ? readerMode() : false
                Label
                {   id: con_lblreadermode
                    anchors {verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: Theme.paddingSmall}
                    text:"Text only"
                }
  //              LinearGradient
  //              {
  //                  id: readermodebggradient
  //                  visible:true
  //                  opacity: tab ? (tab.webView.readerModeEnabled ? 1.0 : 0.0) : 0.0
  //                  anchors.fill: parent
  //                  start: Qt.point(parent.width, 0)
  //                  end: Qt.point(parent.width, parent.height)

  //                  gradient: Gradient {
  //                     GradientStop { position: 0.0; color: "transparent" }
  //                     GradientStop { position: 0.7; color: Theme.highlightColor }
  //                  }
  //              }
                Image {
                    id: con_imgreadermode
                    height: parent.height * 0.75
                    width: parent.width * 0.20
                    source: "image://theme/icon-m-font-size"
                    anchors {right: parent.right; rightMargin: Theme.paddingSmall; verticalCenter: parent.verticalCenter }
                    fillMode: Image.PreserveAspectFit
                  }
                 Behavior on opacity {
                    PropertyAnimation { duration: 150; easing.type: Easing.Linear }
                 }
                 MouseArea { anchors.fill: parent;
                              onClicked: {
                                  tab.webView.switchReaderMode();
                      //            target = 'reader';
                                  switchContent();
                              }

                  }
              }
            }
        }
    }
}
