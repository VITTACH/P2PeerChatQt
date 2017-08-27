import QtQuick 2.7

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
}
