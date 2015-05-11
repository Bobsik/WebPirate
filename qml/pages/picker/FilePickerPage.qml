import QtQuick 2.1
import Sailfish.Silica 1.0
import WebPirate.Pickers 1.0
import "../../components/pickers"

Page
{
    property Page rootPage
    property string directory
    property string filter

    signal filePicked(string file)
    signal dismiss()

    function pickFile(file) {
        filepickerpageprivate.isFilePicked = true;
        filePicked(file);
    }

    QtObject {
        property bool isFilePicked: false
        id: filepickerpageprivate
    }

    id: filepickerpage
    allowedOrientations: defaultAllowedOrientations

    Component.onDestruction: {
        if(!filepickerpageprivate.isFilePicked)
            dismiss();
    }

    SilicaFlickable
    {
        anchors.fill: parent

        PageHeader { id: pageheader }

        FilePicker
        {
            id: filepicker
            multiSelect: false
            anchors { left: parent.left; top: pageheader.bottom; right: parent.right; bottom: parent.bottom }

            folderModel: FolderListModel {
                id: foldermodel

                onDirectoryNameChanged: {
                    pageheader.title = ((directory === "/") ? qsTr("Root") : foldermodel.directoryName);
                }
            }

            onFileSelected: {
                pickFile(filepath);
                pageStack.pop(rootPage);
            }

            onFolderSelected: {
                var page = pageStack.push(Qt.resolvedUrl("FilePickerPage.qml"), { "directory": folderpath, "filter" : filter, "rootPage": rootPage })
                page.filePicked.connect(pickFile);
            }
        }
    }

    Component.onCompleted: {
        if(filter.length)
            foldermodel.filter = filter;

        foldermodel.directory = directory.length ? directory : foldermodel.homeFolder;
    }
}
