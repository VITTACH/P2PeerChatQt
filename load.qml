import QtQuick 2.7
import StatusBar 0.1
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import "P2PStyle" as P2PStyle
import "js/xHRQuery.js"as XHRQuery
import "js/URLQuery.js"as URLQuery

ApplicationWindow {
    x: 0
    y: 0
    visible:true
    title: "PeerMe"

    StatusBar {color: ("#5D5A58")}

    Timer {
        id: back
        interval: 100
        onTriggered: loader.back()
    }

    Timer {
        id: connect
        interval:4000
        onTriggered:loader.logon(loader.tmpPhone,loader.tmpLogin)
    }

    onClosing: {
        if (event_handler.currentOSys()>0) close.accepted =false; else close.accepted=true
    }

    width: {event_handler.currentOSys() < 1? facade.toPx(820): 0}
    height:event_handler.currentOSys()<1?Screen.height-facade.toPx(100):0

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

        Keys.onReleased: {listenBack(event)}

        Component.onCompleted: strartPage();

        QtObject {
            id: privated
            property var visitedPageList: []
        }

        property var fields:["","","","",""]

        function restores() {
            privated.visitedPageList=[];
            loader.fields = ["","","","",""]
            loader.tel = ""
            loader.login = ""
            loader.famil = ""
            loader.userId= ""
            loader.aToken= ""
            connect.stop()
            loader.isLogin = false
            loader.isOnline= false
        }

        function goTo(page) {
            privated.visitedPageList.push(source=page)
        }

        function back() {
            if (privated.visitedPageList.length > 1) {
                if (source == "qrc:/loginanDregister.qml") {
                    if (partnerHeader.page == 1) {
                        partnerHeader.page = partnerHeader.page-1
                    }
                } else if (loader.source != "qrc:/profile.qml") {
                    privated.visitedPageList.pop()
                    source = privated.visitedPageList[privated.visitedPageList.length - 1]
                }
            } else {
                strartPage();
            }
        }

        function loginByVk() {
            function callback(request) {
                if (request.status === 200) {
                    var obj= JSON.parse(request.responseText)
                    loader.tel = obj.response[0].mobile_phone
                    loader.login = obj.response[0].first_name
                    loader.famil = obj.response[0].last_name;
                    loader.avatarPath = obj.response[0].photo_100
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
            blankeDrawer.open()
            request.onreadystatechange = function() {
                if (request.readyState == XMLHttpRequest.DONE) {
                    if (request.status && request.status==200) {
                        if (request.responseText == "") response = -1;
                        else if (request.responseText != "no") {
                            response = 1;
                            var obj = JSON.parse(request.responseText)
                            loader.famil = obj.family
                            loader.login = obj.login;
                            loader.tel=obj.name;
                        } else {
                            response = 0;
                        }
                        switch(response){
                            case 1:
                                loader.isOnline = !false;
                                if (loader.source!="qrc:/profile.qml") goTo("profile.qml")
                                event_handler.sendMsgs(phone)
                                var u
                                u = {tel:phone,pass:password,login:loader.login,family:loader.famil,image:loader.avatarPath}
                                event_handler.saveSet("user", JSON.stringify(u));
                                break;
                            case 0:
                                blankeDrawer.close()
                                informDialog.show("Вы не зарегистрированы!", 0)
                                if (loader.source != "qrc:/loginanDregister.qml") {loader.goTo("qrc:/loginanDregister.qml")}
                                if (loader.aToken != ""){
                                    loader.fields[0] = (loader.login);
                                    loader.fields[1] = (loader.famil);
                                } else {
                                    loader.fields[0] = ""
                                    loader.fields[1] = ""
                                    loader.fields[2]=password
                                }
                                loader.fields[4] = phone;
                                partnerHeader.page = 1;
                                break;
                            case -1:
                                blankeDrawer.close()
                                informDialog.show("Временно нету доступа до интернету", 0)
                                break;
                        }
                    } else {
                        var findResult = false;
                        for (var i = 0; i < privated.visitedPageList.length; i++)
                            if (privated.visitedPageList[i].search("profile.qml") != -1) {
                                findResult=true
                                break;
                            }
                        if (!findResult) {
                            loader.goTo(("qrc:/profile.qml"));
                            tmpLogin = password
                            tmpPhone = phone
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
            console.log("name=" + loader.tel + "&friend=" + friend + "&remove=" + flag)
            request.send("name="+ loader.tel + "&friend=" + friend + "&remove=" + flag)
        }

        // colors variables
        property string menu1Color: "#939393";
        property string menu2Color: "#E0E0E0";
        property string menu3Color: "#76899E";
        property string menu4Color: "#6E737F";
        property string menu5Color: "#B24A3E";
        property string menu6Color: "#96281B";
        property string menu7Color: "#F1F1F1";
        property string menu9Color: "#E5E5E5";

        property string menu10Color:"#545454";
        property string menu11Color:"#597FB2";
        property string menu12Color:"#4F7E9E";
        property string menu13Color:"#B1B1B1";
        property string menu14Color:"#839EAF";
        property string menu15Color:"#8DACBC";

        property string head1Color: "#515151";
        property string head2Color: "#92AF7B";

        property string sets1Color: "#4B4E55";
        property string sets2Color: "#C4C4C4";
        property string sets3Color: "#D6D6D6";
        property string sets4Color: "#565960";

        property string feed1Color: "#7F7875";
        property string feed2Color: "#8E8784";

        property string chat1Color: "#EAEAEA";
        property string chat2Color: "#A7A7A7";
        property string chat3Color: "#B3E5A0";
        property string chat4Color: "#A5D394";

        property string feedColor: "#EDEDED";
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
        loader.focus = true
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape || event === true) {
            event.accepted= true
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
        visible: loader.source != "qrscan.qml"
        id: partnerHeader;
    }

    FontLoader {
        source: "qrc:/fonts/TrebuchetMSn.ttf";
        id: trebu4etMsNorm
    }

    P2PStyle.DefaultDialog {id: informDialog;}

    P2PStyle.ImagesDialog {id: avatarDialog}

    P2PStyle.BlankeDrawer {id: blankeDrawer}

    P2PStyle.ChatMenuList {id:chatMenuList}
}
