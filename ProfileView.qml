import QtQuick 2.7
import QtQuick.Controls 2.0
import "P2PStyle" as P2PStyle

Item {
    Connections {
        target: loader
        onIsOnlineChanged: changeState()
        onWebviewChanged: if (!loader.webview) changeState();
        onAvatarPathChanged: actionBar.phot=loader.avatarPath
    }

    function changeState() {
        actionBar.photo = loader.avatarPath
        actionBar.status = loader.isOnline?"Online":"Offline"
        actionBar.text = (loader.login + " " + loader.famil);
    }

    Component.onCompleted: {
        actionBar.addPage("Новости")
        actionBar.addPage("Музыка")
        actionBar.addPage("Котировки")
        actionBar.addPage("Прочее")
        actionBar.page = 0
        changeState()
    }

    Rectangle {
        anchors.fill: parent
        color: loader.menu16Color

        SwipeView {
            id: view;
            anchors.fill: parent;

            Loader {
                Component.onCompleted: source="FeedsView.qml"
            }

            Loader {
            }

            onCurrentIndexChanged: {
                actionBar.page = currentIndex
            }
        }
    }

    P2PStyle.MainDrawer {id: mainDrawer}

    ChatScreenView {id: chatScreen}
}
