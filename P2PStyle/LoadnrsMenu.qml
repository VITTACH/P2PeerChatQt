import QtQuick 2.7
import QtQuick.Controls 2.0

Rectangle {
    visible: false;
    color: "#CC404040"
    anchors.fill: parent
    MouseArea {anchors.fill:parent}
    BusyIndicator {
        width: parent.width /2
        height:parent.height/2
        x: (parent.width - width)/2
        y: (parent.height-height)/2
    }
}
