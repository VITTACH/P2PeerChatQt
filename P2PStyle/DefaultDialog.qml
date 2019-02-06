import QtQuick 2.7
import QtQuick.Controls 2.3;

Dialog {
    id: dialog
    property var message: ""
    x: (parent.width - width)/2
    y: parent.height-height-parent.height/6

    width: Math.min(0.73 * parent.width, facade.toPx(666))
    height: 2 * width/3;

    standardButtons: Dialog.Ok;

    contentItem: Rectangle {
        Text {
            text: message
            width: parent.width
            wrapMode: Text.Wrap
            anchors.centerIn: parent
            font {
                family: trebu4etMsNorm.name
                pixelSize: facade.doPx(20);
            }
        }
    }

    function show(title, message) {
        dialog.message = message
        dialog.title = title
        dialog.open()
    }
}
