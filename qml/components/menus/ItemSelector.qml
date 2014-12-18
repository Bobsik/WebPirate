import QtQuick 2.0
import Sailfish.Silica 1.0

PopupMenu
{
    property QtObject selectorModel
    property bool accepted: false

    id: itemselector

    popupDelegate: ListItem {
        highlighted: model.selected
        enabled: model.enabled

        Label {
            anchors.fill: parent
            anchors.bottomMargin: Theme.paddingSmall
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: model.text
        }

        onClicked: {
            itemselector.accepted = true;
            itemselector.selectorModel.accept(model.index);
            itemselector.hide();
        }
    }

    onVisibleChanged: {
        if(!visible && !accepted)
            selectorModel.reject();
        else if(visible)
            accepted = false;
    }

    onSelectorModelChanged: {
        popupModel = selectorModel.items;
    }
}
