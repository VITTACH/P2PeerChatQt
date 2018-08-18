import QtQuick 2.7
import QtQuick.Controls 2.0

Item {
    Connections {
        target: loader
        onIsOnlineChanged: changeState()
        onWebviewChanged: if (loader.webview==false)changeState()
        onAvatarPathChanged: partnerHeader.phot=loader.avatarPath
    }

    function changeState() {
        partnerHeader.phot = loader.avatarPath
        partnerHeader.stat = loader.isOnline? "Online": "Offline"
        partnerHeader.text = (loader.login + " " + loader.famil);
    }

    Component.onCompleted: changeState()

    Item {
        anchors.fill: parent
        SwipeView {
            id: view;
            anchors.fill: parent

            Loader {
                Component.onCompleted: source = "qrc:/Feeds.qml";
            }
            Loader {
                Component.onCompleted: source = "";
            }
        }
    }
}
