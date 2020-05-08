import QtQuick 2.6
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import "../quickgrid"

Item
{
    property alias stack: tabstackitems
    property bool quickvisible: false
    property bool dialogsVisible

    signal hideAll()

    function hideQuickGrid() {
        quickvisible = false;
    }

    function showQuickGrid() {
        if(gridloader.sourceComponent == grid_quickgrid){gridloader.item.disableEditMode();}
        quickvisible = true;
    }

    id: tabstack

    Loader{
        id: gridloader
        anchors.fill: parent
        sourceComponent:grid_favorites// grid_quickgrid
        visible: quickvisible
        onItemChanged: {
            if(!gridloader.item)
                return;

            gridloader.item.load();
        }

    }

    Component{
      id: grid_quickgrid
      QuickGrid
      {
        id: quickgrid
        anchors.fill: parent

        onNewTabRequested: tabview.addTab(mainwindow.settings.homepage)
        onLoadRequested:   tabview.currentTab().load(request)

      }
    }

    Component{
      id: grid_favorites
      QuickGridFavorites
      {
        id: favorites
        anchors.fill: parent

        onNewTabRequested: tabview.addTab(mainwindow.settings.homepage)
        onLoadRequested:   tabview.currentTab().load(request)

      }
    }

    Item
    {
        id: tabstackitems
        anchors.fill: parent
    }

    MouseArea
    {
        id: hidearea
        anchors.fill: tabstackitems
        visible: dialogsVisible

        onClicked: {
            hideAll();
        }
    }
}
