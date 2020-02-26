import QtQuick 2.6
import Sailfish.Silica 1.0

ColorPickerDialog
{
    property var colorModel

    id: colorchooserdialog
    onAccepted: colorModel.accept(colorchooserdialog.color)
    onRejected: colorModel.reject()
}
