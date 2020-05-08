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
        if(!tab)
            return;
        thumb.scheduleUpdate();
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
     if(tab.webView.icon != ""){ faviconMultiplier = 0.7; return tab.webView.icon;}
     if(tab.state === "newtab"){ faviconMultiplier = 0.9; return "qrc:///res/quickgrid.png";}
     if(tab.state === "loaderror"){ faviconMultiplier = 0.9; return "qrc:///res/loaderror_white.png";}
     if(tab.state === "mediagrabber"){ faviconMultiplier = 0.9; return "qrc:///res/grabber.png";}
     if(tab.state === "mediaplayer"){ faviconMultiplier = 0.9; return "image://theme/icon-l-play";}
     return "";
     }
     return "";
    }


    id: tablistitemsmall
    _showPress: false
    onPressAndHold: {
       tabsthumb = !tabsthumb;
    }

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
    drag.axis: Drag.YAxis
  //  drag.maximumX: content.width
  //  drag.minimumX: 0

  //  onWidthChanged: {
    //    if(isPortrait == true){
      //     content.x = 0;
        //   return;
       // }
      //  content.x = content.defaultX; // Reposition Item
   // }

    drag.onActiveChanged: {
        if(drag.active)
            return;
        if(Math.abs(content.y) > content.height / 3)
            closeRequested();

           content.y = 0;
           return;
        //content.x = content.defaultX;
    }

    Connections { target: tab; onThumbUpdatedChanged: {update();} }

    Item
    {
        readonly property bool webviewVisible: tab && (tab.state === "webview")
        readonly property real defaultX: (parent.width / 2) - (width / 2)

        id: content
        //x: defaultX
        width: Math.round(Theme.itemSizeExtraLarge * 1.3 * (isPortrait ? settings.guifactorportrait : settings.guifactorlandscape))
        height: tabbar.height// parent.height
       // width: isPortrait ? Screen.width : Screen.height/2
       // height: isPortrait ? Theme.itemSizeMedium : Theme.itemSizeLarge

        visible: true

        Behavior on x { PropertyAnimation { duration: 250; easing.type: Easing.OutBack } }

        BusyIndicator{
            id: tabbusy
            size: BusyIndicatorSize.Medium * (isPortrait ? settings.guifactorportrait : settings.guifactorlandscape)
            anchors.centerIn: parent
            running: tab.webView.loading
            z: parent.z +1
        }

        Image
        {
          id: favicon
          anchors { left: parent.left; bottom: parent.bottom; leftMargin: Theme.paddingSmall;bottomMargin: Theme.paddingMedium;}
          width: fav() != "" ? Math.round(Theme.iconSizeSmall * faviconMultiplier * (isPortrait ? settings.guifactorportrait : settings.guifactorlandscape)) : 0
          height: width
          fillMode: Image.PreserveAspectFit
          LayoutMirroring.enabled: tablistitemsmall.leftHanded
          z: parent.z +1
          source: fav()
         }

        Item
        {
            id: effectitem
            anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right:parent.right;  }

            Rectangle { id: specialthumb;
                anchors.fill: parent
                visible: !content.webviewVisible;
                color: highlighted ? Theme.secondaryHighlightColor : "gray"
            }

            ShaderEffectSource
            {
                id: thumb
                anchors.fill: parent
                live: true
                sourceItem: tab ? tab.webView : null
                sourceRect: Qt.rect(0, 0, effectitem.width, effectitem.height)
                visible: true //content.webviewVisible
            }

            Label
            {
                anchors { left: parent.left; bottom: parent.bottom; leftMargin: (Theme.paddingSmall*2)+favicon.width; bottomMargin: Theme.paddingMedium; right: parent.right }
                //x: tablistitem.leftHanded ? Theme.paddingMedium : (parent.width - contentWidth - Theme.paddingMedium)
                width: Math.round((parent.width - imglock.width - (Theme.paddingSmall*2) -favicon.width) * (isPortrait ? settings.guifactorportrait : settings.guifactorlandscape))
                font { family: Theme.fontFamilyHeading; pixelSize: Math.round(Theme.fontSizeSmall * (isPortrait ? settings.guifactorportrait : settings.guifactorlandscape)) }
                verticalAlignment: Text.AlignBottom
                horizontalAlignment: Text.AlignLeft
                truncationMode: TruncationMode.Fade
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                z: effectitem.z + 1

                text: tabtitle()
            }

            Image {
              id: imglock
              width: Math.round(Theme.itemSizeExtraSmall * 0.4 * (isPortrait ? settings.guifactorportrait : settings.guifactorlandscape))
              height: Math.round(Theme.itemSizeExtraSmall * 0.4 * (isPortrait ? settings.guifactorportrait : settings.guifactorlandscape))
              source: tablocked() //tab.locked? "qrc:///res/locked.png" : "qrc:///res/unlocked.png"
              anchors { top: parent.top; right: parent.right }
              LayoutMirroring.enabled: tablistitemsmall.leftHanded
              z: parent.z + 1

              MouseArea { anchors.fill: parent; onClicked: lockRequested() }
            }

            LinearGradient
            {
                anchors.fill: effectitem
                start: Qt.point(parent.width, 0)
                end: Qt.point(0, parent.height)

                gradient: Gradient {
                    GradientStop { position: 0.0; color: gradColor}
                    GradientStop { position: 0.9; color: Qt.darker(Theme.highlightBackgroundColor, 2) }
                }
            }
        }

        Desaturate
        {
            anchors.fill: effectitem
            source: effectitem
            desaturation: highlighted ? 0.0 : 1.0
            visible: true//content.webviewVisible
        }
    }
}
