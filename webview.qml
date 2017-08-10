import QtQuick 2.7
import QtQuick.Controls 2.0

Rectangle {
    color: "white"
    anchors.fill: parent
    Loader {
        width: parent.width
        anchors {
            top: parent.top
            bottom: parent.bottom
            topMargin: partnerHeader.height
        }
        source: {
            event_handler.currentOSys()> 0?
                    "qrc:/ibrowser.qml": ""
        }
    }
}
