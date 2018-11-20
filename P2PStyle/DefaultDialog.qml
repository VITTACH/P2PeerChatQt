import QtQuick 2.0
import QtQuick.Dialogs 1.2

Dialog {
    id: dialog
    property string message;

    contentItem: Rectangle {
        color: "lightskyblue"
        implicitWidth: facade.toPx(400)
        implicitHeight:facade.toPx(100)
        Text {
            text: message
            color: "navy"
            anchors.centerIn: {parent;}
        }
    }

    function show(title, message) {
        dialog.message = message
        dialog.title = title
        visible = true
    }
}
