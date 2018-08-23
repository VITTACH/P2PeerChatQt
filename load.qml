import QtQuick 2.7
import StatusBar 0.1
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import "P2PStyle" as P2PStyle
import "js/xHRQuery.js"as XHRQuery
import "js/URLQuery.js"as URLQuery
import QtQuick.Controls.Universal 2.0

ApplicationWindow {
    x: 0
    y: {event_handler.currentOSys() <= 0 ? facade.toPx(100) : 0;}
    visible: true
    title: "Coinroad"

    Universal.theme: {Universal.Light}
    Universal.accent: Universal.Purple

    // flags: Qt.FramelessWindowHint; // turned off system window

    Timer {
        id: back;
        interval: 100
        onTriggered: loader.back()
    }

    StatusBar {color: ("#3E4A56")}

    Timer {
        id: connect
        interval:4000
        onTriggered:loader.logon(loader.tmpPhone,loader.tmpLogin)
    }

    onClosing: event_handler.currentOSys()>0? close.accepted = false:close.accepted = true

    height:event_handler.currentOSys()<1?Screen.height-facade.toPx(100):0
    width: event_handler.currentOSys()<1?Screen.width/1.2: 0

    QtObject {
        id: facade
        function toPx(dp) {
            return dp*(loader.dpi / 160)
        }
        function doPx(dp) {
            return dp*(loader.dpi / 160) * 1.5
        }
    }

    Loader {
        id: imagePicker
        source: {
            if (event_handler.currentOSys() === 1) {"AndImagePicker.qml"}
            else
            if (event_handler.currentOSys() === 2) "IOsImagesPicker.qml";
            else ""
        }
        onLoaded: {
            item.onChange=function(urlimage) {
                loader.avatarPath = (urlimage)
                event_handler.sendAvatar(decodeURIComponent((urlimage)));
            }
        }
    }

    Loader {
        id: loader;
        focus: true
        objectName: "loader"
        anchors.fill: parent

        function restores() {
            privated.visitedPageList =[];
            loader.fields = ["","","","",""]
            loader.tel = ""
            loader.login = ""
            loader.famil = ""
            loader.userId= ""
            loader.aToken= ""
            loader.isLogin = false;
            loader.isOnline= false;
            connect.stop();
        }

        Keys.onReleased: {listenBack(event)}

        Component.onCompleted: strartPage();

        QtObject {
            id: privated
            property var visitedPageList: []
        }

        property real dpi: 0

        // login by social
        property var urlLink
        property string aToken
        property string userId

        // some visible popup window
        property bool avatar;
        property bool dialog;
        property bool webview;
        property bool context;

        // info about user
        property string tel
        property string login;
        property string famil;
        property string avatarPath: "qrc:/ui/profiles/default/Human.png";

        property bool isNews
        property bool isLogin
        property bool isOnline

        // history of chats
        property var chats:[];
        property var frienList

        property var tmpLogin;
        property var tmpPhone;
        property var chatOpen;
        property var drawOpen;

        property string menu1Color: "#939393";
        property string menu2Color: "#E0E0E0";
        property string menu3Color: "#8093A3";
        property string menu4Color: "#777F89";
        property string menu5Color: "#B24A3E";
        property string menu6Color: "#96281B";
        property string menu7Color: "#F1F1F1";
        property string menu8Color: "#D3D3D3";
        property string menu9Color: "#B9C3CC";

        property string menu10Color:"#535353";
        property string menu11Color:"#597FB2";
        property string menu12Color:"#4F7E9E";
        property string menu13Color:"#B1B1B1";
        property string menu14Color:"#80A4B7";
        property string menu15Color:"#8DACBC";
        property string menu16Color:"#BBC6CA";

        property string head1Color: "#6B8499";
        property string head2Color: "#FFFFFF";

        property string sets2Color: "#828D99";
        property string sets3Color: "#6C839A";
        property string sets4Color: "#708EA0";

        property string feed1Color: "#7A93A0";
        property string feed2Color: "#C68585";

        property string chat1Color: "#EAEAEA";
        property string chat2Color: "#A7A7A7";
        property string chat3Color: "#70FFFFFF"

        property string feedColor: "#EDEDED";

        property var fields: ["","","","",""]

        function back() {
            if (privated.visitedPageList.length > 1) {
                if (source == "qrc:/loginanDregister.qml") {
                    if (partnerHeader.page == 1) partnerHeader.page = partnerHeader.page-1
                } else if (loader.source != "profile.qml") {
                    privated.visitedPageList.pop()
                    source = privated.visitedPageList[privated.visitedPageList.length - 1]
                }
            } else {
                strartPage();
            }
        }

        function goTo(s) {
            privated.visitedPageList.push(source=s)
        }

        function loginByVk() {
            function callback(request) {
                if (request.status === 200) {
                    var obj=JSON.parse(request.responseText)
                    loader.avatarPath= obj.response[0].photo_100
                    loader.tel= obj.response[0].mobile_phone
                    loader.login= obj.response[0].first_name
                    loader.famil= obj.response[0].last_name;
                    logon(loader.tel, userId)
                }
            }

            var params = {
                fields: 'photo_100,contacts',
                user_ids: loader.userId,
                name_case: 'Nom'
            }
            var baseUrl="https://api.vk.com/method/users.get?access_token="+loader.aToken;
            XHRQuery.sendXHR('POST', baseUrl, callback, URLQuery.serializeParams(params));
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
                            loader.tel = obj.name;
                        } else response = 0;
                        switch(response) {
                            case 1:
                                loader.isOnline = !false;
                                if (loader.source != "profile.qml") {
                                    loader.goTo("profile.qml")
                                }
                                event_handler.sendMsgs(phone);
                                var uo = {tel: phone, pass: password, login: loader.login,
                                    family:loader.famil, image:loader.avatarPath}
                                event_handler.saveSet("user", JSON.stringify(uo))
                                break;
                            case 0:
                                defaultDialog.show(qsTr("Вы не были зарегистрированы"), 0)
                                if (loader.source != "qrc:/loginanDregister.qml")
                                    goTo("qrc:/loginanDregister.qml");
                                if (loader.aToken != ""){
                                    loader.fields[0] = (loader.login);
                                    loader.fields[1] = (loader.famil);
                                } else {
                                    loader.fields[0] = ""
                                    loader.fields[1] = ""
                                    loader.fields[2] =password
                                }
                                loader.fields[4] = phone;
                                partnerHeader.page = 1;
                                break;
                            case -1:
                                defaultDialog.show("Временно нету доступа до интернету",0)
                                break;
                        }
                    } else {
                        var findResult = false;
                        for (var i = 0; i<privated.visitedPageList.length; i++) {
                            if (privated.visitedPageList[i].search("profile.qml") != -1) {
                                findResult = true
                                break;
                            }
                        }
                        if (!findResult) {
                            if (loader.source !="profile.qml")
                                loader.goTo("profile.qml")
                            tmpLogin = password
                            tmpPhone=phone
                        }
                        loader.isOnline = false
                        connect.restart();
                    }
                }
            }
            request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.send("phone=" + phone + "&pass="+password)
            loader.isLogin=true
        }

        function addFriend(friend, flag) {
            flag = typeof flag !== 'undefined' ? flag : false;
            var request = new XMLHttpRequest()
            request.open('POST',"http://www.hoppernet.hol.es")
            request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.send("name="+ loader.tel + "&friend=" + (friend) + "&remove=" + flag);
        }
    }

    function strartPage() {
        var eh =event_handler.loadValue("user")
        if (eh!="") {
            var objct = JSON.parse(eh);
            loader.avatarPath = objct.image
            loader.logon(objct.tel, objct.pass)
            loader.login = objct.login;
            loader.famil = objct.family
            loader.tel = objct.tel;
        } else {
            loader.goTo("loginanDregister.qml")
        }
    }

    function listenBack(event) {
        loader.forceActiveFocus()
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape || event === true) {
            event.accepted = true
            if (loader.dialog ==true) {
                loader.dialog = !loader.dialog;
            } else if (loader.avatar) {
                loader.avatar = !loader.avatar;
            } else if(loader.context) {
                loader.context=!loader.context;
            } else if(loader.webview) {
                loader.webview=!loader.webview;
            } else back.restart()
        }
    }

    P2PStyle.HeaderSplash {
        visible: loader.source != "qrscan.qml";
        id: partnerHeader;
    }

    FontLoader {
        source:"qrc:/fonts/TrebuchetMSn.ttf"
        id: trebu4etMsNorm
    }

    P2PStyle.DefaultDialog {id: defaultDialog;}

    P2PStyle.ImagesDialog {id: avatarDialog}
}
