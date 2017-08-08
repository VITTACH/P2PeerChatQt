import QtQuick 2.7
import QtQuick.Controls 2.0
import"P2PStyle"as P2PStyle

ApplicationWindow {
    width: 500
    height: 700
    visible: true
    title: qsTr("P2P Chat")

    Timer {
        id: backTimer
        interval: 500
        onTriggered: loader.back()
    }

    QtObject {
        id: facade
        function toPx(dp) {
            return dp*(loader.dpi/160)
        }
        function doPx(dp) {
            return dp*(loader.dpi/160)*1.5;
        }
    }

    Loader {
        id: loader;
        focus: true
        objectName: "loader"
        anchors.fill: parent
        property real dpi: 0

        property var avatarPath: "qrc:/ui/profiles/default/Human.png"
        property string urlLink: "";
        property bool avatar
        property bool dialog
        property bool webvew

        property string tel
        property string login;
        property string famil;
        property bool context;

        property var chats:[];

        Keys.onReleased: listenBack(event);

        Component.onCompleted: strartPage()

        QtObject {
            id: privated
            property var visitedPageList:[]
        }

        property variant fields: ["", "", "", "", ""];

        function goTo(page) {
            privated.visitedPageList.push(source=page)
        }
        function back() {
            if (privated.visitedPageList.length > 0) {
                if (source != "qrc:/start.qml") {
                    if (source == "qrc:/loginanDregister.qml") {
                        if (partnerHeader.page == 1) {
                            partnerHeader.page = partnerHeader.page-1;
                        }
                    } else {
                        privated.visitedPageList.pop()
                        source=privated.visitedPageList[privated.visitedPageList.length-1]
                    }
                }
            }
            else
                strartPage();
        }
        function logon(phone, password) {
            var request = new XMLHttpRequest();var response;
            request.open('POST',"http://hoppernet.hol.es/default.php")
            request.onreadystatechange = function() {
                if (request.readyState == XMLHttpRequest.DONE) {
                    if (request.status && request.status==200) {
                        if (request.responseText == "") response = -1;
                        else if (request.responseText != "no") {
                            response = 1;
                            var obj = JSON.parse(request.responseText)
                            loader.famil = obj.family
                            loader.login = obj.login;
                            loader.tel = obj.name
                        }
                        else
                            response = 0;
                        switch(response){
                        case 1:
                        loader.goTo("qrc:/chat.qml");
                        event_handler.sendMsgs(phone)
                        event_handler.saveSet("passw", password)
                        event_handler.saveSet("phone", phone)
                        break;
                        case 0:
                        windsDialogs.show("Вы не зарегистрированы!",0)
                        break;
                        case -1:
                        windsDialogs.show("Нет доступа к интернету",0)
                        break;
                        }
                    } else {
                        windsDialogs.show("Нет доступа к интернету",0)
                        loader.goTo("qrc:/loginanDregister.qml")
                    }
                    busyIndicator.visible =false;
                }
            }
            request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.send("phone=" + phone + "&pass=" + password)
        }
    }

    Loader {
        id: imagePicker
        source: event_handler.currentOSys()==1? "AndImagePicker.qml":(event_handler.currentOSys()==2? "IOsImagesPicker.qml":"")
        onLoaded: {
            item.onChange= function(urlimg) {
                loader.avatarPath = urlimg
                event_handler.sendAvatar(decodeURIComponent(urlimg));
            }
        }
    }

    function strartPage() {
        var phone = event_handler.loadValue("phone");
        var passw = event_handler.loadValue("passw");
        if (passw != "" && phone != "") {loader.logon(phone, passw);}
        else
        privated.visitedPageList.push(loader.source="qrc:/start.qml")
    }

    function listenBack(event) {
        loader.focus = true
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape || event === true) {
            event.accepted= true
            if (loader.dialog==true) {
            loader.dialog = !loader.dialog;
            } else if(loader.avatar) {
            loader.avatar = !loader.avatar;
            } else if(loader.webvew) {
            loader.webvew = !loader.webvew;
            } else backTimer.restart()
        }
    }

    P2PStyle.HeaderSplash {
        visible: loader.source != "qrc:/start.qml" && loader.source != "qrc:/qrscan.qml";
        id: partnerHeader;
    }

    FontLoader {
        source: "qrc:/fonts/TrebuchetMSn.ttf";
        id: trebu4etMsNorm
    }

    P2PStyle.BusyIndicator {id: busyIndicator}

    P2PStyle.Avatardialogs {id: avatardialogs}

    P2PStyle.Settingdrawei {id: settingDrawer}

    P2PStyle.WindsDialogs {id: windsDialogs}

    P2PStyle.ContextMenu {id: contextDialog}

    P2PStyle.Menusdrawer {id: menuDrawer}
}
