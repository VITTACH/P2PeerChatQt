import QtQuick 2.7
import QtQuick.Controls 2.0

SwipeView {
    anchors.fill:parent
    currentIndex: partnerHeader.page;
    Component.onCompleted: partnerHeader.page = 0

    Loader {
        id: loginScreen
        Component.onCompleted: source = "LoginView.qml";
    }

    Loader {
        id: reginScreen
        Component.onCompleted: source = "RegistrationView.qml";
    }

    onCurrentIndexChanged: {
        partnerHeader.page = currentIndex
        switch(currentIndex) {
            case 0:
                partnerHeader.text = ""
                loginScreen.focus = false
                reginScreen.focus = true;
                break;
            case 1:
                partnerHeader.text = qsTr("Зарегистрироваться")
                reginScreen.focus = false
                loginScreen.focus = true;
                break;
        }
    }
}
