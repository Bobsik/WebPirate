import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"
import "../menus"

SilicaListView
{
    property string url
    property string title
    property string src

    property string usedmodel

    property int footeritemscount
    property bool imgbool
    property bool imgonly

    property int active

    function usethismodel(){
        if (usedmodel == 'tabmenumodel')
        {
            return tabmenuModel
        }
        if (usedmodel == 'imagemenumodel')
        {
            return imagemenuModel
        }
        if (usedmodel == 'linkmenumodel')
        {
            return linkmenuModel
        }
    }

    function usethisfont(idx){
        if (idx == active)
        {
            return true;
        }
       return false;
    }

    function isimage(){
        if (imgbool == true) {
            if(imgonly == true)
                {
                usedmodel = 'imagemenumodel';
                return contextModel_imageonly
                }
            return contextModel_wimage
            }
        else{
            return contextModel_woimage
        }
    }

    property list<QtObject> contextModel_wimage:
       [
          QtObject {
           property bool font: usethisfont(0)
           readonly property string txt: qsTr("Tab")
           readonly property string usemodel: 'tabmenumodel'
        },
          QtObject {
           property bool font: usethisfont(1)
           readonly property string txt: qsTr("Link")
           readonly property string usemodel: 'linkmenumodel'
        },
          QtObject {
           property bool font: usethisfont(2)
           readonly property string txt: qsTr("Image")
           readonly property string usemodel: 'imagemenumodel'
        }
       ]

    property list<QtObject> contextModel_woimage:
        [
          QtObject {
            property bool font: usethisfont(0)
            readonly property string txt: qsTr("Tab")
            readonly property string usemodel: 'tabmenumodel'
        },
          QtObject {
            property bool font: usethisfont(1)
            readonly property string txt: qsTr("Link")
            readonly property string usemodel: 'linkmenumodel'
        }
        ]

    property list<QtObject> contextModel_imageonly:
        [
        QtObject {
         property bool font: usethisfont(0)
         readonly property string txt: qsTr("Image")
         readonly property string usemodel: 'imagemenumodel'
      }
        ]

    property list<QtObject> tabmenuModel:
        [
        QtObject { readonly property string menuText: qsTr("Open in this Tab")
          function execute() {
          linkmenu.openThisTabRequested(linkmenu.url);
         }
        },
        QtObject { readonly property string menuText: qsTr("Create New Tab")
          function execute() {
          linkmenu.createTabRequested(linkmenu.url);
         }
        },
        QtObject { readonly property string menuText: qsTr("Enter in New Tab")
          function execute() {
          linkmenu.openTabRequested(linkmenu.url);
         }
        }
    ]

    property list  <QtObject> imagemenuModel:
    [
        QtObject { readonly property string menuText: qsTr("Copy Image Link")
          function execute() {
          mainwindow.settings.clipboard.copy(linkmenu.src);
          popupmessage.show(qsTr("Link copied to clipboard"));
         }
        },

        QtObject { readonly property string menuText: qsTr("Open Image")
          function execute() {
            var tab = tabs.get(currentIndex).tab;
            tab.load(linkmenu.src);
         }
        },

        QtObject { readonly property string menuText: qsTr("Save Image")
          function execute() {
          tabviewremorse.execute(qsTr("Downloading image"), function() {
          mainwindow.settings.downloadmanager.createDownloadFromUrl(linkmenu.src);
          });
         }
        },

        QtObject { readonly property string menuText: qsTr("Share")
          function execute() {
          sharemenu.share(linkmenu.title, linkmenu.src);
          }
         }
    ]

    property list  <QtObject> linkmenuModel:
    [
        QtObject { readonly property string menuText: qsTr("Copy Link")
          function execute() {
          mainwindow.settings.clipboard.copy(linkmenu.url);
          popupmessage.show(qsTr("Link copied to clipboard"));
         }
        },

        QtObject { readonly property string menuText: qsTr("Save Link Destination")
          function execute() {
          tabviewremorse.execute(qsTr("Downloading link"), function() {
          mainwindow.settings.downloadmanager.createDownloadFromUrl(linkmenu.url);
          });
         }
        },
        QtObject { readonly property string menuText: qsTr("Share")
          function execute() {
          sharemenu.share(linkmenu.title, linkmenu.url);
          }
         }
    ]

    NumberAnimation { id: gradevop; target: linkmenu; property: "opacity"; to: 0.0; duration: 150 }
    NumberAnimation { id: gradsolid; target: linkmenu; property: "opacity"; to: 1.0; duration: 150 }

    onOpacityChanged: {
        if (opacity == 1.0){gradsolid.start();return;}
        if (opacity == 0.75){gradsolid.start();return;}
        if (opacity == 0.0){gradevop.start();return;}
    }

    signal createTabRequested(string url)
    signal openTabRequested(string url)
    signal openThisTabRequested(string url)

    id: linkmenu
    visible: false
    clip: true
    opacity: 0.0

    model: usethismodel()

    DialogBackground {
        anchors.fill: parent
    }

    delegate: ListItem {
        contentWidth: linkmenu.width
        contentHeight: Theme.itemSizeExtraSmall

        Label {
            anchors { fill: parent; bottomMargin: Theme.paddingSmall }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.fontSizeSmall
            text: usethismodel()[index].menuText
        }

        onClicked: {
            linkmenu.visible = false;
            usethismodel()[index].execute();
        }
    }
    footer:

   SilicaGridView
    {
      id: footergrid
      width: linkmenu.width
      height: Theme.itemSizeExtraSmall
      cellWidth: linkmenu.width /footeritemscount
      cellHeight: Theme.itemSizeExtraSmall
      focus: true
      model: isimage()
      delegate:
          ListItem{
            width: footergrid.cellWidth
            height: footergrid.cellHeight
                Label {
                   anchors { fill: parent; bottomMargin: Theme.paddingSmall }
                   horizontalAlignment: Text.AlignHCenter
                   verticalAlignment: Text.AlignVCenter
                   font.pixelSize: Theme.fontSizeSmall * (isimage()[index].font ? 1.2 : 0.8)
                   color: isimage()[index].font ? Theme.highlightColor : "grey"
                   text: isimage()[index].txt
                     }
                MouseArea {
                    anchors.fill: parent
                    onClicked:
                       {
                        if(active != index){
                        usedmodel = usemodel;
                        active = index;
                        linkmenu.usethismodel();
                        linkmenu.opacity = 0.75;
                        linkmenu.forceLayout();
                        }
                       }
                     }
                }
     }
   }
