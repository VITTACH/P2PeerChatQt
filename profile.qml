import QtQuick 2.7
import QtQuick.Controls 2.0

Item {
    Connections {
        target: loader
        onIsOnlineChanged: changeState()
        onAvatarPathChanged: partnerHeader.phot=loader.avatarPath
    }

    function changeState() {
        partnerHeader.stat = loader.isOnline? "Online": "Offline"
    }

    Component.onCompleted: {
        changeState()
        partnerHeader.phot = loader.avatarPath
        partnerHeader.text = (loader.login + " " + loader.famil);
    }

    Item {
        anchors.fill: parent
        SwipeView {
            id: view;

            anchors {
                fill: parent
                topMargin: partnerHeader.height - facade.toPx(10)
            }

            Loader {
                id: feedPage
                Component.onCompleted: source = "qrc:/feeds.qml";
            }
        }
    }
}
