import QtQuick 2.1
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import "mediacomponents"

Item
{
    property alias videoSource: videoplayer.source
    property alias videoThumbnail: imgthumbnail.source
    property alias videoTitle: mptitle.text

    property bool fullScreen: false

    function switchFullScreen()
    {
        if(fullScreen)
            tabheader.solidify();
        else
        {
            tabheader.evaporate();
            navigationbar.evaporate();
        }

        fullScreen = !fullScreen;
    }

    id: browserplayer

    states: [ State { name: "error"
                      PropertyChanges { target: lblmessage; visible: true }
                      PropertyChanges { target: videoplayer; visible: false }
                      PropertyChanges { target: pcbusy; visible: false } },

              State { name: "loading"
                      PropertyChanges { target: lblmessage; visible: false }
                      PropertyChanges { target: videoplayer; visible: true }
                      PropertyChanges { target: pcbusy; visible: true } },

              State { name: "playing"
                      PropertyChanges { target: lblmessage; visible: false }
                      PropertyChanges { target: videoplayer; visible: true }
                      PropertyChanges { target: pcbusy; visible: false } }]

    Rectangle
    {
        id: blackframe
        anchors.fill: parent
        color: "black"

        Label
        {
            id: lblmessage
            anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
            width: parent.width
            text: videoplayer.errorString
            font.pixelSize: Theme.fontSizeLarge
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "white"
        }
    }

    Timer
    {
        id: screenping
        repeat: true
        triggeredOnStart: true
        interval: 60000 /* 60s */
        running: browserplayer.visible && (videoplayer.playbackState === MediaPlayer.PlayingState)

        onTriggered: {
            mainwindow.settings.screenblank.enabled = false;
        }
    }

    Video
    {
        id: videoplayer
        anchors.fill: parent
        autoPlay: true

        onPlaybackStateChanged: {
            var keep = videoplayer.playbackState !== MediaPlayer.PlayingState;

            mptoolbar.keepVisible(keep);
            mptitle.keepVisible(keep);

            if(keep && !fullScreen && (Qt.application.state === Qt.ApplicationActive))
                navigationbar.solidify();
            else
                navigationbar.evaporate();

            if(videoplayer.playbackState === MediaPlayer.PlayingState)
                browserplayer.state = "playing";
        }

        onErrorChanged: {
            if(videoplayer !== MediaPlayer.NoError)
            {
                browserplayer.state = "error";

                /* Avoid MediaPlayer undefined behavior */
                videoplayer.stop();
                navigationbar.solidify();

                if(fullScreen)
                    switchFullScreen();
            }
        }

        onStatusChanged: {
            if((playbackState !== MediaPlayer.PlayingState) && (status === MediaPlayer.Loading || status === MediaPlayer.Buffering || status === MediaPlayer.Stalled))
                browserplayer.state = "loading";
        }

        Image
        {
            id: imgthumbnail
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            visible: !lblmessage.visible && !videoplayer.hasVideo
        }

        BusyIndicator
        {
            id: pcbusy
            anchors.centerIn: parent
            visible: false
            running: visible
        }

        MouseArea
        {
            anchors { left: parent.left; top: parent.top; right: parent.right; bottom: mptoolbar.top }

            onClicked: {
                if(mptoolbar.opacity < 1.0) {
                    mptoolbar.restoreOpacity();
                    mptitle.restoreOpacity();
                    return;
                }

                videoplayer.playbackState === MediaPlayer.PlayingState ? videoplayer.pause() : videoplayer.play();
            }
        }

        MediaPlayerTitle
        {
            id: mptitle
            anchors { left: parent.left; top: parent.top; right: parent.right; leftMargin: Theme.paddingMedium; topMargin: Theme.paddingMedium; rightMargin: Theme.paddingMedium }
        }

        MediaPlayerToolBar
        {
            id: mptoolbar
            enabled: browserplayer.state !== "error"
            height: Theme.itemSizeSmall
            anchors { left: parent.left; bottom: parent.bottom; right: parent.right; }
        }
    }

    CoverActionList /* Media Player Cover Actions */
    {
        enabled: browserplayer.visible && (browserplayer.state !== "error")
        iconBackground: true

        CoverAction
        {
            iconSource: videoplayer.playbackState === MediaPlayer.PlayingState ? "image://theme/icon-cover-pause" : "image://theme/icon-cover-play"
            onTriggered: videoplayer.playbackState === MediaPlayer.PlayingState ? videoplayer.pause() : videoplayer.play();
        }

        CoverAction
        {
            iconSource: "image://theme/icon-cover-cancel"
            onTriggered: viewstack.clear()
        }
    }

    CoverActionList /* Media Player Fallback Cover Actions */
    {
        enabled: browserplayer.visible && (browserplayer.state === "error")
        iconBackground: true

        CoverAction
        {
            iconSource: "image://theme/icon-cover-cancel"
            onTriggered: viewstack.clear()
        }
    }
}
