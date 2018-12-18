import QtQuick 2.7
import StatusBar 0.1
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle
import "js/xHRQuery.js"as XHRQuery
import "js/URLQuery.js"as URLQuery
import QtQuick.Controls.Universal 2.0

ApplicationWindow {
    id: mainAppWindow
    x: 0
    y: {event_handler.currentOSys() <= 0 ? facade.toPx(100) : 0;}
    visible: true
    title: qsTr("CoinFriend")

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
        property string menu2Color: "#A0A8AF";
        property string menu3Color: "#6A8399";
        property string menu4Color: "#CCCCCC";
        property string menu5Color: "#AFB5BC";
        property string menu6Color: "#30000000"
        property string menu7Color: "#F1F1F1";
        property string menu8Color: "#BBC6CA";
        property string menu9Color: "#DDDDDD";

        property string menu10Color: "#535353"
        property string menu11Color: "#7C9AAA"
        property string menu12Color: "#677784"
        property string menu13Color: "#999999"
        property string menu14Color: "#95A1AD"
        property string menu15Color: "#8DACBC"
        property string menu16Color: "#EAEAEA"
        property string menu17Color: "#697886"

        property string head1Color: "#637A8E";
        property string head2Color: "#FFFFFF";

        property string sets1Color: "#647785";
        property string sets2Color: "#AEBCC5";
        property string sets3Color: "#6A8399";
        property string sets4Color: "#6F8EA0";

        property string feed1Color: "#FDFDFD";
        property string feed2Color: "#C68585";
        property string feed3Color: "#7E95A0";
        property string feed4Color: "#F6F4F7";

        property string toastColor: "#ECECEC";

        property string chat2Color: "#A7A7A7";
        property string chat3Color: "#70FFFFFF"

        property var fields: ["","","","",""];

        function back() {
            if (privated.visitedPageList.length > 1) {
                if (source == "qrc:/MainScreenView.qml") {
                    if (partnerHeader.page == 1) {partnerHeader.page = 0}
                } else if (loader.source != "ProfileView.qml") {
                    privated.visitedPageList.pop()
                    source = privated.visitedPageList[privated.visitedPageList.length - 1]
                }
            } else strartPage()
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
                    if (request.status && request.status == 200) {
                        if (request.responseText == "") response = -1;
                        else if (request.responseText != "no") {
                            response = (1)
                            var obj = JSON.parse(request.responseText)
                            loader.famil = obj.family
                            loader.login = obj.login;
                            loader.tel = obj.name;
                        } else response =0

                        switch(response) {
                            case 1:
                                var userModel = {
                                    tel: phone,
                                    pass: password,
                                    login: loader.login,
                                    family:loader.famil,
                                    image: loader.avatarPath
                                }

                                loader.isOnline = true
                                event_handler.sendMsgs(phone)
                                event_handler.saveSettings("user", JSON.stringify(userModel))
                                break;

                            case 0:
                                defaultDialog.show("Ошибка входа", "Вы не зарегистрированы");
                                if (loader.aToken != ""){
                                    loader.fields[0] = (loader.login);
                                    loader.fields[1] = (loader.famil);
                                } else {
                                    loader.fields[0] = ""
                                    loader.fields[1] = ""
                                    loader.fields[2] =password
                                }
                                if (loader.source != "qrc:/MainScreenView.qml") {
                                    goTo("qrc:/MainScreenView.qml");
                                }
                                loader.fields[4] = phone;
                                partnerHeader.page = (1);
                                break;

                            case -1:
                                defaultDialog.show("Ошибка входа", "Нет доступа в интернет");
                                break;
                        }
                    } else {
                        connect.restart();
                    }
                }
            }
            request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.send("phone=" + phone + "&pass="+password)
            tmpPhone = phone
            tmpLogin = password
            loader.isLogin = true
            if (loader.source != "ProfileView.qml")
                loader.goTo("ProfileView.qml")
        }

        function addFriend(friend, flag) {
            flag = typeof flag !== 'undefined' ? flag : false;
            var request = new XMLHttpRequest();
            request.open('POST',"http://www.hoppernet.hol.es")
            request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.send("name="+ loader.tel + "&friend=" + (friend) + "&remove=" + flag);
        }
    }

    function strartPage() {
        var eh =event_handler.loadValue("user")
        if (eh != "") {
            var objct = JSON.parse(eh);
            loader.avatarPath = objct.image
            loader.logon(objct.tel, objct.pass)
            loader.login = objct.login;
            loader.famil = objct.family
            loader.tel = objct.tel;
        } else loader.goTo("qrc:/MainScreenView.qml")
    }

    function listenBack(event) {
        loader.forceActiveFocus()
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape || event === true) {
            event.accepted = true
            if (loader.dialog == true) {
                loader.dialog = !loader.dialog;
            } else if (loader.avatar) {
                loader.avatar = !loader.avatar;
            } else if (loader.context) {
                loader.context= !loader.context
            } else if (loader.webview) {
                loader.webview= !loader.webview
                if (!loader.isLogin) {loader.back();}
            } else back.restart()
        }
    }

    P2PStyle.HeaderSplash {
        visible: loader.source != "qrc:/QrScaner.qml"
        id: partnerHeader;
    }

    FontLoader {
        source: "qrc:/fonts/TrebuchetMSn.ttf"
        id: trebu4etMsNorm
    }

    P2PStyle.DefaultDialog {id: defaultDialog;}

    P2PStyle.ImagesDialog {id: avatarDialog;}
}
