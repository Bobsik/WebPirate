import QtQuick 2.6
import Sailfish.Silica 1.0
import "../../models"
import "../../js/settings/Database.js" as Database
import "../../js/settings/TabViewMinimenu.js" as TabViewMenu

Dialog
{
    property Settings settings

    id: dlgtabssettings
    allowedOrientations: defaultAllowedOrientations
    acceptDestinationAction: PageStackAction.Pop
    canAccept: true

    onAccepted: {
        Database.transaction(function(tx) {
            Database.transactionSet(tx, "restoretabs", settings.restoretabs);
            Database.transactionSet(tx, "closelasttab", settings.closelasttab);
            Database.transactionSet(tx, "tabminen", settings.tabminen);
        });
    }

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: content.height

        Column
        {
            id: content
            width: parent.width

            DialogHeader
            {
                acceptText: qsTr("Save")
            }

            TextSwitch
            {
                id: swrestoretabs
                text: qsTr("Restore tabs at Startup")
                width: parent.width
                checked: settings.restoretabs

                onCheckedChanged: {
                    settings.restoretabs = checked;
                }

            }

            TextSwitch
            {
                id: swcloselasttab
                text: qsTr("Close last tab")
                width: parent.width
                checked: settings.closelasttab

                onCheckedChanged: {
                    settings.closelasttab = checked;
                }
            }

            TextSwitch
            {
                id: swtabsegmen
                text: qsTr("Enable TabSegment Minimenu")
                width: parent.width
                checked: settings.tabminen
                description: qsTr("Switch between Minimenu or Pull Down Menu in Tabs Segment")
                onCheckedChanged: {
                    settings.tabminen = checked;
                }
            }

        }
    }
}
