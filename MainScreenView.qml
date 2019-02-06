import QtQuick 2.7
import QtQuick.Controls 2.0

SwipeView {
    anchors.fill:parent
    currentIndex: actionBar.payload;
    Component.onCompleted: actionBar.payload = 0

    Loader {
        id: loginScreen
        Component.onCompleted: source = "LoginView.qml";
    }

    Loader {
        id: reginScreen
        Component.onCompleted: source = "RegistrationView.qml";
    }

    onCurrentIndexChanged: {
        actionBar.payload = currentIndex
        switch(currentIndex) {
            case 0:
                actionBar.text = ""
                loginScreen.focus = false
                reginScreen.focus = true;
                break;
            case 1:
                actionBar.text = qsTr("Новый профиль")
                reginScreen.focus = false
                loginScreen.focus = true;
                break;
        }
    }
}
