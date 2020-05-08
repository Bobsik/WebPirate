import QtQuick 2.6
import Sailfish.Silica 1.0
import "../../models"
import "../../models/navigationbar"
import "../../components/tabview"
import "../../js/UrlHelper.js" as UrlHelper
import "../../js/settings/Database.js" as Database
import "../../js/settings/BrowseMenus.js" as BrowseMenus
import "../../js/settings/UserAgents.js" as UserAgents

Dialog
{
    property Settings settings

    id: dlggeneralsettings
    allowedOrientations: defaultAllowedOrientations
    acceptDestinationAction: PageStackAction.Pop
    canAccept: true
    Component.onCompleted: settings.defaultbrowser.checkDefaultBrowser()

    onAccepted: {
        if(UrlHelper.isUrl(tfhomepage.text) || UrlHelper.isSpecialUrl(tfhomepage.text))
        settings.homepage = UrlHelper.adjustUrl(tfhomepage.text);

        settings.searchengine = cbsearchengines.currentIndex;
        settings.browsemenu = cbbrowsemenu.currentIndex;
        settings.useragent = cbuseragent.currentIndex;
        settings.presscustomaction = cbcustomactionpress.currentIndex;
        settings.longpresscustomaction = cbcustomactionlongpress.currentIndex;
        settings.lefthanded = swlefthandedmode.checked;

        Database.transaction(function(tx) {
            Database.transactionSet(tx, "gui", settings.gui);
            Database.transactionSet(tx, "guifactorportrait", settings.guifactorportrait);
            Database.transactionSet(tx, "guifactorlandscape", settings.guifactorlandscape);
            Database.transactionSet(tx, "homepage", settings.homepage);
            Database.transactionSet(tx, "searchengine", settings.searchengine);
            Database.transactionSet(tx, "browsemenu", settings.browsemenu);
            Database.transactionSet(tx, "useragent", settings.useragent);
            Database.transactionSet(tx, "presscustomaction", settings.presscustomaction);
            Database.transactionSet(tx, "longpresscustomaction", settings.longpresscustomaction);
            Database.transactionSet(tx, "lefthanded", settings.lefthanded);
        });
    }

    CustomActionsModel { id: customactions }

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

            SectionHeader { text: qsTr("Main UI") }

            Column{
              anchors { left: parent.left; right: parent.right; leftMargin: Theme.paddingLarge;}
              Row{
                  width: parent.width
              TextSwitch
              {
                id: swphoneui
                text: qsTr("Phone UI")
                width: parent.width /2
                checked: settings.gui === "phone"
                onClicked:{settings.gui = "phone";
                           swtabletui.checked = false;
                           swtabletuilandscape.checked = false;
                }
              }
              TextSwitch
              {
                id: swtabletui
                text: qsTr("Tablet UI")
                width: parent.width /2
                checked: settings.gui === "tablet"
                onClicked:{settings.gui = "tablet";
                           swphoneui.checked = false;
                           swtabletuilandscape.checked = false;
                }
              }
            }

              TextSwitch
              {
                id: swtabletuilandscape
                text: qsTr("Tablet UI Landscape only")
                width: parent.width
                checked: settings.gui === "tabletlandscape"
                onClicked:{settings.gui = "tabletlandscape";
                           swphoneui.checked = false;
                           swtabletui.checked = false;
                }
              }

              ExpandingSection{
                anchors { left: parent.left; right: parent.right;}
                title: qsTr('<font size="1"> Main Browser GUI Size Factor in % (80 - 200)</font>')
               content.sourceComponent:
                   Column{
                    anchors.leftMargin: Theme.paddingLarge;
                    width: parent.width
                TextField{
                  id:tfguifactorlandscape
                  width: parent.width
                  labelVisible: enabled
                  label: qsTr("Landscape")
                  text: settings.guifactorlandscape * 100
                  validator: IntValidator {bottom: 80; top: 200}
                  onAcceptableInputChanged: settings.guifactorlandscape = Math.round(text / 100);
                }
                TextField{
                  id:tfguifactorportrait
                  width: parent.width
                  labelVisible: enabled
                  label: qsTr("Portrait")
                  text: settings.guifactorportrait * 100
                  validator: IntValidator {bottom: 80; top: 200}
                  onAcceptableInputChanged: settings.guifactorportrait = Math.round(text / 100);
                }
               }
              }
            }

            SectionHeader { text: qsTr("General settings") }

            TextField
            {
                id: tfhomepage
                label: qsTr("Home Page")
                width: parent.width
                inputMethodHints: Qt.ImhUrlCharactersOnly
                text: settings.homepage
            }

            ComboBox
            {
                id: cbsearchengines
                label: qsTr("Search Engines")
                description: qsTr("Long press to edit")
                currentIndex: settings.searchengine
                width: parent.width

                menu: ContextMenu {
                    Repeater {
                        model: settings.searchengines

                        MenuItem {
                            text: name
                        }
                    }
                }

                onPressAndHold: {
                    var page = pageStack.push(Qt.resolvedUrl("searchengine/SearchEnginesPage.qml"), {"settings": settings });
                    page.defaultEngineChanged.connect(function(newindex) {
                        cbsearchengines.currentIndex = newindex;
                    });
                }
            }

            ComboBox
            {
                id: cbbrowsemenu
                label: qsTr("Browsing menu")
                description: qsTr("Browsing Menu appearance on webpage")
                currentIndex: settings.browsemenu
                width: parent.width

                menu: ContextMenu {

                    Repeater {
                        model: BrowseMenus.browsemenus

                        MenuItem {
                            text: BrowseMenus.get(index).type
                        }
                    }
                }
            }

            ComboBox
            {
                id: cbuseragent
                label: qsTr("User Agent")
                width: parent.width
                currentIndex: settings.useragent

                menu: ContextMenu {

                    Repeater {
                        model: UserAgents.defaultuseragents

                        MenuItem {
                            text: UserAgents.get(index).type
                        }
                    }
                }
            }

            TextSwitch
            {
                id: swlefthandedmode
                text: qsTr("Left handed mode")
                width: parent.width
                checked: settings.lefthanded
            }

            TextSwitch
            {
                id: swdefaultbrowser
                text: qsTr("Integrate to MIME")
                width: parent.width
                busy: settings.defaultbrowser.busy
                checked: settings.defaultbrowser.enabled

                onCheckedChanged: {
                    settings.defaultbrowser.enabled = checked;
                }
            }

            SectionHeader { text: qsTr("Custom actions") }

            ComboBox
            {
                id: cbcustomactionpress
                label: qsTr("Pressed")
                width: parent.width
                currentIndex: settings.presscustomaction

                menu: ContextMenu {
                    Repeater {
                        model: customactions.actionmodel

                        MenuItem {
                            text: customactions.actionmodel[index].name
                        }
                    }
                }
            }

            ComboBox
            {
                id: cbcustomactionlongpress
                label: qsTr("Long Pressed")
                width: parent.width
                enabled: cbcustomactionpress.currentIndex !== 0
                currentIndex: settings.longpresscustomaction

                menu: ContextMenu {
                    Repeater {
                        model: customactions.actionmodel

                        MenuItem {
                            text: customactions.actionmodel[index].name
                        }
                    }
                }
            }
        }
    }
}
