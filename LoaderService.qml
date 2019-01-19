import QtQuick 2.7
import StatusBar 0.1
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls.Universal 2.0

import "P2PStyle" as P2PStyle
import "js/xHRQuery.js"as XHRQuery
import "js/URLQuery.js"as URLQuery

ApplicationWindow {
    id: mainAppWindow
    x: 0
    y: {event_handler.currentOSys() <= 0 ? facade.toPx(100) : (0);}
    visible: true
    title: qsTr("CoinFriend")

    StatusBar {color: ("#992820")}

    onClosing: event_handler.currentOSys() > 0? close.accepted = false: close.accepted = true

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
        objectName: "loader";
        anchors.fill: parent;

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
        }

        Keys.onReleased: {listenBack(event)}

        Component.onCompleted: strartPage();

        QtObject {
            id: privated
            property var visitedPageList: []
        }

        property string listChoseBackground: "#4C4C4C"
        property string menu2Color: "#A0A8AF";
        property string mainMenuHeaderColor: "#CD322E"
        property string menu4Color: "#CCCCCC";
        property string listForegroundColor: "#212121"
        property string menu6Color: "#30000000"
        property string menu7Color: "#F1F1F1";
        property string listBackgroundColor: "#424242"
        property string menu9Color: "#DDDDDD";

        property string menu10Color: "#535353";
        property string menu11Color: "#7C9AAA";
        property string switcherOnColor: "#666666"
        property string switcherOffColor: "#999999"
        property string menuCurElementColor: "#2C2C2C"
        property string menu15Color: "#8DACBC";
        property string menu16Color: "#EAEAEA";
        property string menu17Color: "#697886";

        property string headBackgroundColor: "#CD322E"
        property string head2Color: "#FFFFFF";

        property string mainMenuBorderColor: "#BC211D"
        property string helpBackgroundColor: "#666666"
        property string helpListItemColor: "#424242";

        property string feed1Color: "#EFEFEF";
        property string feed2Color: "#C68585";
        property string mainBackgroundColor: "#222222"
        property string feed4Color: "#F6F4F7";

        property string toastColor: "#ECECEC";

        property string chat2Color: "#A7A7A7";
        property string chat3Color: "#70FFFFFF"

        property string chatBackgroundColor: "#2C2C2C"

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
            loader.isLogin = true
            if (loader.source != "ProfileView.qml") {
                loader.goTo("ProfileView.qml")
            }
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
        var user = event_handler.loadValue("user")
        if (user != "") {
            var objct = JSON.parse(user)
            loader.avatarPath = objct.image
            loader.logon(objct.tel, objct.pass)
            loader.login = objct.login;
            loader.famil = objct.family
            loader.tel = objct.tel;
        } else {
            loader.goTo("qrc:/MainScreenView.qml")
        }
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
                if (!loader.isLogin) {
                    loader.back()
                }
            } else loader.back()
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
