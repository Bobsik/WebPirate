import QtQuick 2.1
import Sailfish.Silica 1.0
import "../../../../components"
import "../../../../js/YouTubeGrabber.js" as YouTubeGrabber

Item
{
    property string videoId
    property ListModel videoTypes: ListModel { }

    property bool grabFailed: false
    property alias videoResponse: lblresponse.text
    property alias videoTitle: lbltitle.text
    property alias videoAuthor: lblauthor.text
    property alias videoDuration: lblduration.text
    property alias videoThumbnail: imgthumbnail.source

    function playVideo(videotitle, videourl, videothumbnail) {
        viewstack.push(Qt.resolvedUrl("../browserplayer/BrowserPlayer.qml"), "mediaplayer", { "videoTitle": videotitle, "videoSource": videourl, "videoThumbnail": videothumbnail });
    }

    id: dlgytvideosettings
    onVideoIdChanged: YouTubeGrabber.grabVideo(videoId, dlgytvideosettings);

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: content.height

        Column
        {
            id: content
            width: parent.width
            spacing: Theme.paddingMedium

            Column
            {
                id: column
                width: parent.width

                PageHeader { id: dlgheader; title: qsTr("YouTube Grabber") }

                Row
                {
                    id: videoinfo
                    width: parent.width
                    height: Math.max(imgthumbnail.height, colinfo.height)
                    spacing: Theme.paddingSmall
                    visible: !grabFailed

                    Image
                    {
                        id: imgthumbnail
                        width: 240
                        height: 130
                        fillMode: Image.PreserveAspectCrop
                    }

                    Column
                    {
                        id: colinfo
                        width: parent.width - imgthumbnail.width
                        spacing: Theme.paddingMedium

                        InfoLabel {
                            id: lblauthor
                            width: parent.width
                            title: qsTr("Author")
                        }

                        InfoLabel {
                            id: lblduration
                            width: parent.width
                            title: qsTr("Duration")
                        }
                    }
                }

                Column
                {
                    id: colvideo
                    width: parent.width
                    spacing: Theme.paddingMedium

                    InfoLabel
                    {
                        id: lblresponse
                        anchors.topMargin: Theme.paddingMedium
                        width: parent.width
                        contentColor: grabFailed ? "red" : "lime"
                        title: qsTr("Response")
                        text: "OK"
                        labelWrap: Text.WordWrap
                    }

                    InfoLabel
                    {
                        id: lbltitle
                        visible: !grabFailed
                        anchors.topMargin: Theme.paddingMedium
                        width: parent.width
                        title: qsTr("Title")
                        labelWrap: Text.WordWrap
                    }
                }
            }

            Label
            {
                id: lblgrabs
                visible: !grabFailed
                anchors { left: parent.left; right: parent.right }
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
                text: qsTr("Grabbed URLs") + ":"
                wrapMode: Text.WordWrap
            }

            Column
            {
                id: colvideotypes
                visible: !grabFailed
                anchors { left: parent.left; right: parent.right }

                Repeater
                {
                    model: videoTypes


                    delegate: ListItem {
                        id: lvitem
                        contentWidth: colvideotypes.width
                        contentHeight: Theme.itemSizeSmall
                        onClicked: playVideo(videoTitle, url, videoThumbnail)

                        menu: ContextMenu {
                            MenuItem {
                                text: qsTr("Play")
                                onClicked: playVideo(videoTitle, url, videoThumbnail)
                            }

                            MenuItem {
                                text: qsTr("Download")

                                onClicked: {
                                    lvitem.remorseAction(qsTr("Grabbing video"), function() {
                                        mainwindow.settings.downloadmanager.createDownload(url);
                                    });
                                }
                            }
                        }

                        InfoLabel
                        {
                            anchors.fill: parent
                            labelElide: Text.ElideRight
                            displayColon: false
                            title: qsTr("Quality") + ": " + (quality + " (" + mime + (hascodec ? (", " + codec) : "") + ")")
                            text: url
                        }
                    }
                }
            }
        }
    }
}