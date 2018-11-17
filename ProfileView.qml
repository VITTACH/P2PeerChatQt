import QtQuick 2.7
import QtQuick.Controls 2.0
import "P2PStyle" as P2PStyle

Item {
    Connections {
        target: loader
        onIsOnlineChanged: changeState()
        onWebviewChanged: if (!loader.webview) changeState()
        onAvatarPathChanged: partnerHeader.phot=loader.avatarPath
    }

    function changeState() {
        partnerHeader.phot = loader.avatarPath
        partnerHeader.stat = loader.isOnline? "Online": "Offline"
        partnerHeader.text = (loader.login + " " + loader.famil);
    }

    Component.onCompleted: changeState()

    Rectangle {
        anchors.fill: parent
        color: loader.menu16Color
        SwipeView {
            id: view;
            anchors.fill: parent;

            Loader {
                Component.onCompleted: source = "qrc:/FeedsView.qml";
            }
        }
    }

    P2PStyle.MainDrawer {id: mainDrawer}

    ChatScreenView {id: chatScreen}
}
