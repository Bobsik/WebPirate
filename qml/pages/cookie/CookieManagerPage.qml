import QtQuick 2.1
import Sailfish.Silica 1.0
import "../../models"
import "../../components/items/cookie"

Page
{
    property Settings settings

    id: pagecookiemanager
    allowedOrientations: Orientation.All
    Component.onCompleted: settings.cookiejar.load()
    Component.onDestruction: settings.cookiejar.unload()

    SilicaFlickable
    {
        id: flickable
        anchors.fill: parent

        RemorsePopup { id: remorsepopup }

        PullDownMenu
        {
            MenuItem
            {
                text: qsTr("Remove All Cookies")

                onClicked: {
                    remorsepopup.execute(qsTr("Removing Cookies"), function() {
                        settings.cookiejar.deleteAllCookies();
                    });
                }
            }

            MenuItem
            {
                text: qsTr("Add Cookie")
                onClicked: pageStack.push(Qt.resolvedUrl("CookiePage.qml"), { "settings": pagecookiemanager.settings })
            }
        }

        Column
        {
            id: content
            width: parent.width

            PageHeader
            {
                id: pagehdr
                title: qsTr("Cookie Manager")
            }

            SearchField
            {
                id: sffilter
                width: parent.width
                placeholderText: qsTr("Filter")
                inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoAutoUppercase
                onTextChanged: settings.cookiejar.filter(sffilter.text)
            }
        }

        SilicaListView
        {
            id: listview
            anchors { left: parent.left; top: content.bottom; right: parent.right; bottom: parent.bottom }
            model: settings.cookiejar.domains
            clip: true

            delegate: DomainListItem {
                id: domainlistitem
                contentWidth: parent.width
                contentHeight: Theme.itemSizeSmall
                domain: model.modelData
                count: settings.cookiejar.cookieCount(model.modelData)
                icon: settings.icondatabase.provideIcon(model.modelData)

                onClicked: {
                    var cookiepage = pageStack.push(Qt.resolvedUrl("CookieListPage.qml"), { "settings": settings, "domain": model.modelData })

                    cookiepage.done.connect(function() {
                        domainlistitem.count = settings.cookiejar.cookieCount(model.modelData); // Update Count for this item
                    });
                }
            }
        }
    }
}
