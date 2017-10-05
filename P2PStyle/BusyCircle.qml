import QtQuick 2.7
import QtQuick.Controls 2.0

Rectangle {
    opacity: 0.8
    visible: false;
    color:"#404040"
    anchors.fill: parent
    BusyIndicator {
        width: parent.width/2
        height: parent.height/2
        x: (parent.width - width)/2
        y: (parent.height-height)/2
    }
}
