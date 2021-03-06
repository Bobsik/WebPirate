import QtQuick 2.6
import Sailfish.Silica 1.0
import harbour.webpirate.Network 1.0

Dialog
{
    property bool proxyEnabled: (proxymanager.host.length > 0) && (proxymanager.port > 0)

    id: dlgproxysettings
    allowedOrientations: defaultAllowedOrientations
    acceptDestinationAction: PageStackAction.Pop
    canAccept: tsproxydisabled.checked || ((tfhost.text.length > 0) && (tfport.text.length > 0))

    onAccepted: {
        if(tsproxydisabled.checked) {
            proxymanager.unset();
            return;
        }

        proxymanager.host = tfhost.text;
        proxymanager.port = parseInt(tfport.text);
        proxymanager.save();
    }

    ProxyManager
    {
        id: proxymanager
        Component.onCompleted: load()
    }

    SilicaFlickable
    {
        anchors.fill: parent

        Column
        {
            id: content
            anchors { left: parent.left; right: parent.right }

            DialogHeader {
                acceptText: qsTr("Save")
            }

            TextSwitch
            {
                id: tsproxydisabled
                text: qsTr("Proxy Disabled")
                description: qsTr("You need to restart WebPirate")
                checked: !dlgproxysettings.proxyEnabled
            }

            SectionHeader {
                text: qsTr("Proxy Settings (Restart needed)")
                visible: !tsproxydisabled.checked
            }

            Row
            {
                width: parent.width
                visible: !tsproxydisabled.checked
                spacing: Theme.paddingSmall

                TextField
                {
                    id: tfhost
                    width: parent.width - tfport.width
                    placeholderText: qsTr("Host or Ip Address")
                    text: proxymanager.host
                }

                Label { text: ":" }

                TextField
                {
                    id: tfport
                    width: parent.width / 3
                    placeholderText: qsTr("Port")
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: ((proxymanager.port > 0) ? proxymanager.port.toString() : "")
                }
            }TextSwitch
            {
                id: socksSwitch
                text: qsTr("Use Socks")
                description: qsTr("Socket Secure (SOCKS) is an Internet protocol that exchanges network packets between a client and server through a proxy server.")
                checked: proxymanager.isSocks5
                onClicked: proxymanager.isSocks5 = !proxymanager.isSocks5
                visible: !tsproxydisabled.checked
            }
            TextSwitch
            {
                id: torSwitch
                text: qsTr("Use Tor")
                description: qsTr("Tor is free software for enabling anonymous communication. This will setup the proxy automatically to use tor. Tor service must be running on the system for this to work.")
                checked: {
                    if (tfhost.text == "127.0.0.1" && tfport.text == "9050" && socksSwitch.checked == true) {
                        tfhost.readOnly = true
                        tfport.readOnly = true
                        socksSwitch.enabled = false
                        return true
                    } else return false
                }
                onClicked: {
                    if (checked) {
                        proxymanager.isSocks5 = true
                        tfhost.text = "127.0.0.1"
                        tfport.text = "9050"
                        tfhost.readOnly = true
                        tfport.readOnly = true
                        socksSwitch.enabled = false
                    }
                    else {
                        proxymanager.isSocks5 = false
                        tfhost.text = ""
                        tfport.text = ""
                        tfhost.readOnly = false
                        tfport.readOnly = false
                        socksSwitch.enabled = true
                    }
                }
                visible: !tsproxydisabled.checked
            }
        }
    }
}

