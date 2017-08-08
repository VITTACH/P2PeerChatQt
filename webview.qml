import QtQuick 2.7
import QtQuick.Controls 2.0

Item {
    id: rootFaceBook;

    Loader {
        source: event_handler.currentOSys() > 0? "ibrowser.qml":""
        anchors.topMargin: partnerHeader.height - facade.toPx(10);
        width: parent.width
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
    }
}
