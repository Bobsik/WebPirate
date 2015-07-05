import QtQuick 2.1
import Sailfish.Silica 1.0
import harbour.webpirate.Pickers 1.0
import "../../components/pickers"

Page
{
    property Page rootPage
    property string directory
    property string filter

    signal filePicked(string file)
    signal dismiss()

    function changeDirectory(dir) {
        foldermodel.directory = dir.length ? dir : foldermodel.homeFolder;
    }

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

        PullDownMenu
        {
            MenuItem {
                text: qsTr("SD Card")
                visible: foldermodel.sdcardFolder.length > 0

                onClicked: {
                    var rootfppage = pageStack.nextPage(rootPage);

                    if(rootfppage !== filepickerpage) {
                        rootfppage.changeDirectory(foldermodel.sdcardFolder);
                        pageStack.pop(rootfppage);
                        return;
                    }

                    rootfppage.changeDirectory(foldermodel.sdcardFolder);
                }
            }

            MenuItem {
                text: qsTr("Home");

                onClicked: {
                    var rootfppage = pageStack.nextPage(rootPage);

                    if(rootfppage !== filepickerpage) {
                        rootfppage.changeDirectory(foldermodel.homeFolder);
                        pageStack.pop(rootfppage);
                        return;
                    }

                    rootfppage.changeDirectory(foldermodel.homeFolder);
                }
            }
        }

        FilePicker
        {
            id: filepicker
            multiSelect: false
            showThumbnails: true
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

        changeDirectory(filepickerpage.directory);
    }
}
