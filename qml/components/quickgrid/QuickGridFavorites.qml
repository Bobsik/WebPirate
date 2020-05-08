import QtQuick 2.6
import Sailfish.Silica 1.0
import harbour.webpirate.LocalStorage 1.0
import "../items"
import "../../models"
import "../../js/settings/Favorites.js" as Favorites


SilicaGridView
{
    property int folderId: 0 // Root folder by default

    signal newTabRequested()
    signal loadRequested(string request)

    function load() {
        favoritesmodel.jumpTo(folderId);
    }

   // id: quickgrid

    RemorsePopup { id: remorsepopup }

    property real spacing: mainpage.isPortrait ? Theme.paddingMedium : Theme.paddingLarge

    PullDownMenu
    {
        id: pulldownmenu
        //enabled: !editMode && quickgridview.visible

        MenuItem
        {
            text: qsTr("Settings")
            onClicked: pageStack.push(Qt.resolvedUrl("../../pages/settings/SettingsPage.qml"), { "settings": settings })
        }

        MenuItem
        {
            text: qsTr("New tab")
            onClicked: newTabRequested()
        }
    }

    id: quickgridview
    anchors.fill: parent
    cellWidth: mainpage.isPortrait ? (width / 3) : (width / 4)
    cellHeight: cellWidth
    model: FavoritesModel { id: favoritesmodel }
    quickScroll: true
    clip: true

//    header: Item {
  //      width: quickgridview.width
    //    height: Theme.paddingLarge
  //  }

    delegate: FavoriteItemQuick {
        contentWidth: mainpage.isPortrait ? (width / 3) : (width / 4)
        contentHeight: parent.cellWidth
        title: model.title

        icon: {
            if(model.isfolder)
                return "image://theme/icon-m-folder";

            return mainwindow.settings.icondatabase.provideIcon(model.url);
        }

        onClicked: {
                if(model.isfolder) {
                favoritesmodel.jumpTo(model.favoriteid);
                //favoritessegment.scrollToTop();
                quickgridview.scrollToTop();
                return;
            }

            tabView.addTab(model.url);
            pageStack.pop();
        }
    }

    //    VerticalScrollDecorator { flickable: quickgridview }

     //   ViewPlaceholder
     //   {
     //       id: placeholder
     //       z: -1
     //       enabled: !editMode && !mainwindow.settings.quickgridmodel.count
     //       text: qsTr("The Quick Grid is empty") + "\n" + qsTr("Long Press to edit")
     //   }
}
