import QtQuick 2.7
import QtQuick.Controls 2.0

SwipeView {
    anchors.fill: parent
    currentIndex: partnerHeader.page
    Component.onCompleted: partnerHeader.page = 0

    Loader {
        Component.onCompleted: source = "qrc:/login.qml"
    }
    Loader {
        Component.onCompleted: source = ("registration.qml")
    }

    onCurrentIndexChanged: {
        partnerHeader.page = currentIndex
        switch (currentIndex) {
            case 0: partnerHeader.text= qsTr("Вход"); break;
            case 1: partnerHeader.text="Регистрация"; break;
        }
        Qt.inputMethod.hide()
        loader.focus = (true)
    }
}
