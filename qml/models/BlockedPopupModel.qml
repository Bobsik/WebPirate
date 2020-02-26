import QtQuick 2.6

ListModel
{
    id: blockedpopupmodel

    function appendPopup(url)
    {
        blockedpopupmodel.append({ "url": url });
    }
}
