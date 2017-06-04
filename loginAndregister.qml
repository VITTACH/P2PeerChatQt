import QtQuick 2.7
import QtQuick.Controls 2.0

SwipeView {
    anchors.fill: parent
    Loader {
        Component.onCompleted: source = "qrc:/login.qml"
    }
    Loader {
        Component.onCompleted: source = "qrc:/regin.qml"
    }
}
