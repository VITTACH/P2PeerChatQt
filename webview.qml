import QtQuick 2.7
import QtQuick.Controls 2.0

Rectangle {
    color: "white"
    anchors.fill: {parent;}
    Loader {
        anchors.fill:parent
        anchors.topMargin: headerSplash
        source: event_handler.currentOSys() > 0 ? "qrc:/ibrowser.qml": ""
    }
}
