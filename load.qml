import QtQuick 2.7
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import"P2PStyle"as P2PStyle
import"js/xHRQuery.js" as XHRQuery
import"js/URLQuery.js" as URLQuery

ApplicationWindow {
    x: 0
    y: 0
    visible: true
    title:"p2peer.io"
    property var tmpLogin
    property var tmpPhone

    Timer {
        id: backTimer
        interval: 500
        onTriggered: loader.back()
    }

    Timer {
        id: connect
        interval: 4000
        onTriggered: {
            console.log("try connect")
            loader.logon(tmpPhone,tmpLogin)
        }
    }

    width: event_handler.currentOSys() == 1 || event_handler.currentOSys() == 2? 500: facade.toPx(1200)
    height:event_handler.currentOSys() == 1 || event_handler.currentOSys() == 2? 900: Screen.height - facade.toPx(100)

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
        id: imagePicker
        source: {
            if (event_handler.currentOSys() == 1) {"AndImagePicker.qml"}
            else
            if (event_handler.currentOSys() == 2) "IOsImagesPicker.qml";
            else ""
        }
        onLoaded: {
            item.onChange=function(urlimage) {
                loader.avatarPath = urlimage
                event_handler.sendAvatar(decodeURIComponent((urlimage)))
            }
        }
    }

    Loader {
        id: loader;
        focus: true
        objectName: "loader"
        anchors.fill: parent
        property real dpi: 0

        // some visible popup window
        property bool avatar: false;
        property bool dialog: false;
        property bool webvew: false;
        property bool context: false

        // info about user
        property string tel
        property string login;
        property string famil;
        property string avatarPath: "qrc:/ui/profiles/default/Human.png";

        // login by social
        property string aToken
        property string userId

        property bool isLogin: false
        property bool isOnline:false

        // history of chats
        property var chats:[];
        property var frienList: ""

        // loading web page
        property string urlLink: "";

        Keys.onReleased: listenBack(event);

        Component.onCompleted: strartPage()

        QtObject {
            id: privated
            property var visitedPageList:[]
        }

        property variant fields: ["", "", "", "", ""];

        function restores() {
            loader.isLogin = false
            loader.fields= ["","","","",""]
            loader.tel = ""
            loader.login = ""
            loader.famil = ""
            loader.userId= ""
            loader.aToken= ""
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
            XHRQuery.sendXHR('POST', "https://api.vk.com/method/users.get?access_token=" + loader.aToken, callback,
                             URLQuery.serializeParams(params))
        }

        function logon(phone, password) {
            var request = new XMLHttpRequest();var response;
            request.open('POST',"http://hoppernet.hol.es/default.php")
            request.onreadystatechange = function() {
                if (request.readyState == XMLHttpRequest.DONE) {
                    busyIndicator.visible=false;
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
                                if (loader.source!="qrc:/profile.qml")
                                    goTo("qrc:/profile.qml");
                                event_handler.sendMsgs(phone)
                                var u
                                u = {tel:phone,pass:password,login:loader.login,family:loader.famil,image:loader.avatarPath}
                                event_handler.saveSet("user", JSON.stringify(u));
                                break;
                            case 0:
                                windowsDialogs.show("Вы не зарегистрированы!", 0)
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
                                windowsDialogs.show("Нет доступа к интернету", 0)
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
                        connect.restart();
                    }
                }
            }
            request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.send("phone=" + phone + "&pass="+password)
            loader.isLogin=true
        }

        function addFriends() {
            var request = new XMLHttpRequest()
            request.open('POST',"http://www.hoppernet.hol.es")
            request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.send("name=" + loader.tel + "&friend=" +(frienList))
        }
    }

    function strartPage() {
        var usa
        usa = event_handler.loadValue("user");
        if (usa != "") {
            var objct = JSON.parse(usa);
            loader.avatarPath = (objct.image);
            loader.famil = objct.family;
            loader.login = objct.login
            loader.logon(objct.tel,objct.pass)
            loader.tel = objct.tel
        } else {
            loader.source = ("qrc:/start.qml")
            loader.goTo(loader.source)
        }
    }

    function listenBack(event) {
        loader.focus = true
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape || event === true) {
            event.accepted= true
            if (loader.dialog==true) {
                loader.dialog = !loader.dialog
            } else if(loader.context) {
                loader.context=!loader.context
            } else if(loader.avatar) {
                loader.avatar = !loader.avatar
            } else if(loader.webvew) {
                loader.webvew = !loader.webvew
            } else backTimer.restart()
        }
    }

    P2PStyle.HeaderSplash {
        visible: (loader.source != "qrc:/start.qml" && loader.source != "qrc:/qrscan.qml")
        id: partnerHeader;
    }

    FontLoader {
        source: "qrc:/fonts/TrebuchetMSn.ttf";
        id: trebu4etMsNorm
    }

    P2PStyle.Menusdrawer {id: menuDrawer}

    P2PStyle.BusyIndicator {id: busyIndicator}

    P2PStyle.Avatardialogs {id: avatardialogs}

    P2PStyle.WindsDialogs {id: windowsDialogs}

    P2PStyle.ContextMenu {id: contextDialog}
}
