import QtQuick 2.7
import QtQuick.Controls 2.0

Rectangle {
    anchors.fill: parent
    Loader {
        source: event_handler.currentOSys() > 0 ? "qrc:/ibrowser.qml": ""
        anchors {
            fill: parent
            topMargin: partnerHeader.height
        }
    }
}
