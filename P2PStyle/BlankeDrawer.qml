import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Drawer {
    id: drawer
    property bool find: true
    property alias cindex: listView.currentIndex;
    background: Rectangle {color: "transparent";}
    width: {Math.min(facade.toPx(640), 0.9 * parent.width)}
    height: {parent.height;}
    dragMargin:facade.toPx(40)

    Connections {
        target: drawer;
        onPositionChanged: {
            if (loader.isLogin != true || loader.webview) {
                close()
                position = 0
            } else if (position == 1) {
                helperDrawer.visible(true)
                if (typeof loader.frienList == "undefined") {
                    var friend
                    friend = event_handler.loadValue("frd")
                    if (friend != "") {
                        var myfriend = (JSON.parse(friend))
                        var triend = []
                        for(var i=0;i<myfriend.length;i++){
                            usersModel.append({image:"", famil: myfriend[i].famil, login: myfriend[i].login, phone: myfriend[i].phone, port: myfriend[i].port, ip: myfriend[i].ip,activity:1})
                            triend.push(myfriend[i].phone);
                        }
                    }
                    loader.frienList=JSON.stringify(triend)
                }
                getMePeers(loader.frienList)
            } else if (position == (0)) {
                helperDrawer.visible(false);
                loader.forceActiveFocus()
                find = true;
            }
        }
    }

    Connections {
        target: loader
        onIsOnlineChanged: if(loader.isOnline) getFriends()
    }

    function getHelperHeight() {return (leftSlider.height)}

    function getProfHeight() {
        return (profile.height) + (profile.y - 1)
    }

    function getCurPeerInd() {return listView.currentIndex}

    function filterList(param) {
        for (var i = 0; i < usersModel.count; i = i+1) {
            var name = " " + usersModel.get(i).login + usersModel.get(i).famil
            if (name.toLowerCase().search(param) > 0 || param === "")
                usersModel.setProperty(i, "activity", 1)
            else
                usersModel.setProperty(i, "activity", 0)
        }
    }

    function getMePeers(name) {
        var request = new XMLHttpRequest(), obj,index
        request.open('POST', "http://www.hoppernet.hol.es")
        request.onreadystatechange =function() {
            if (request.readyState ==XMLHttpRequest.DONE) {
                if (request.status&&request.status ==200) {
                    try {
                        obj=JSON.parse(request.responseText)
                    } catch(e) {
                        console.log("parse: "+e)
                        return
                    }
                    for (var i = 0; i < obj.length; i+=1) {
                        index = findPeer(obj[i].name)
                        if (usersModel.count<1|| index<0) {
                            loader.chats.push({phone:obj[i].name, message:[]})
                            usersModel.append({
                                image: "http://lorempixel.com/200/20" + i,
                                famil: obj[i].family,
                                login: obj[i].login,
                                phone: obj[i].name,
                                port: obj[i].port,
                                ip: obj[i].ip,
                                activity: 1
                            });
                            if(obj[i].name==loader.tel)listView.currentIndex=i
                        } else {
                            if (usersModel.get(index).image == "") {
                                usersModel.setProperty(index, "image", "http://lorempixel.com/200/20" + i + "/sports")
                            }
                            usersModel.setProperty(index,"famil",obj[i].famil)
                            usersModel.setProperty(index,"login",obj[i].login)
                            usersModel.setProperty(index, "port", obj[i].port)
                            usersModel.setProperty(index, "ip", obj[i].ip)
                        }
                    }
                    var frnds = []
                    for (i = 0; i <usersModel.count; i++) {
                        frnds.push({famil: usersModel.get(i).famil, login: usersModel.get(i).login, phone: usersModel.get(i).phone, port: usersModel.get(i).port, ip: usersModel.get(i).ip})
                    }
                    event_handler.saveSet("frd",JSON.stringify(frnds))
                }
            }
        }
        var urlEncode = 'application/x-www-form-urlencoded'
        request.setRequestHeader('Content-Type', urlEncode)
        request.send("READ=2&name=" +name)
    }

    function getFriends() {
        var request = new XMLHttpRequest()
        request.open('POST', "http://www.hoppernet.hol.es")
        request.onreadystatechange =function() {
            if (request.readyState ==XMLHttpRequest.DONE) {
                if (request.status&&request.status ==200) {
                    getMePeers(loader.frienList =request.responseText)
                }
            }
        }
        var urlEncode = 'application/x-www-form-urlencoded'
        request.setRequestHeader('Content-Type', urlEncode)
        request.send("READ=3&name="+loader.tel);
    }

    function getPeersModel(index, field) {
        var results =""
        if(field == "famil")
            results = usersModel.get(index).famil
        if(field == "login")
            results = usersModel.get(index).login
        if(field == "image")
            results = usersModel.get(index).image
        if(field == "phone")
            results = usersModel.get(index).phone
        if(field == "port")
            results = usersModel.get(index).port;
        return results
    }

    function findPeer(phone) {
        for(var i = 0; i<usersModel.count; i++) {
            if (usersModel.get(i).phone == phone)
                return i;
        }
        return -1;
    }

    Rectangle {
        anchors.fill: (parent)
        color: (loader.menu9Color)
        anchors.topMargin: profile.height;
    }

    Rectangle {
        Rectangle {
            id: iner
            width: {parent.width;}
            color: loader.isOnline?loader.menu4Color:loader.menu2Color
            height: 6
        }
        id: leftRect;
        color: (loader.isOnline? loader.menu3Color: loader.menu3Color)
        width: parent.width - canva.width;
        anchors {
            top: (profile.top)
            bottom: profile.bottom
            topMargin:partnerHeader.height-facade.toPx(11)-iner.height
        }
    }

    Canvas {
        id: canva
        anchors {
            top: leftRect.top;
            left: leftRect.right
            bottom: profile.bottom
        }
        width: facade.toPx(120)
        Connections {
            target: loader;
            onIsOnlineChanged: canva.requestPaint();
        }
        antialiasing: true;
        smooth: false
        onPaint: {
            var context=getContext("2d")
            context.reset()
            context.fillStyle=loader.isOnline == true? loader.menu3Color:loader.menu3Color
            context.moveTo(0,0)
            context.lineTo(width, width)
            context.lineTo(width,height)
            context.lineTo(0,height)
            context.closePath()
            context.fill();

            context.fillStyle=loader.isOnline == true? loader.menu4Color:loader.menu2Color
            context.beginPath()
            context.moveTo(0,0)
            context.lineTo(width-0,width)
            context.lineTo(width-6,width)
            context.lineTo(0,6)
            context.closePath()
            context.fill();
        }
    }

    Column {
        id: profile
        spacing:facade.toPx(10)
        anchors.horizontalCenter: parent.horizontalCenter
        Item{
            id: firstItem
            width: parent.width
            height: facade.toPx(10);
        }
        Row {
            id: firstRow;
            anchors.horizontalCenter:parent.horizontalCenter
            spacing: {facade.toPx(30) - (facade.toPx(708) - drawer.width)/facade.toPx(10)}
            Column {
                anchors.bottom: parent.bottom
                Text {
                    font.bold: true;
                    style: Text.Raised
                    styleColor: "black";
                    color: {"#FFFFFFFF"}
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(30);
                    text: usersModel.count > 0 ? usersModel.count: 0
                    anchors.horizontalCenter:parent.horizontalCenter
                }
                Text {
                    text: qsTr("Друзья")
                    color: qsTr("white")
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(24);
                    anchors.horizontalCenter:parent.horizontalCenter
                }
            }
            Button {
                id: avatarButton
                width: facade.toPx(225);
                height: facade.toPx(225)
                background: Rectangle {
                    radius: width * 0.5;
                    color: "transparent"
                    border {
                      width: 1.4
                      color: "#50FFFFFF"
                    }
                }

                onClicked: {
                    drawer.close()
                    chatScreen.close()
                    loader.avatar = true
                }
                Rectangle {
                    id: bag
                    clip: true
                    smooth: true
                    visible: false
                    width: parent.width - facade.toPx(45.0);
                    height: parent.height - facade.toPx(45);
                    anchors {
                        horizontalCenter: parent.horizontalCenter;
                        verticalCenter:parent.verticalCenter
                    }
                    Image {
                        source:loader.avatarPath
                        height:sourceSize.width>sourceSize.height? parent.height: sourceSize.height*(parent.width/sourceSize.width);
                        width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height/sourceSize.height): parent.width;
                        anchors.centerIn: parent
                        RadialGradient {
                            anchors.fill: parent
                            gradient: Gradient {
                                GradientStop { position: 0.4; color: "#20000000"}
                                GradientStop { position: 0.8; color: "#90000000"}
                            }
                        }
                    }
                }

                DropShadow {
                    radius: 15
                    samples: 15
                    source: big
                    color:"#90000000"
                    anchors.fill:big;
                }
                OpacityMask {
                    id: big
                    source: bag
                    maskSource: misk;
                    anchors.fill: bag
                }

                Image {
                    id: misk
                    smooth: true;
                    visible:false
                    source: "qrc:/ui/mask/round.png"
                    sourceSize:Qt.size(bag.width,bag.height)
                }
            }
            Column {
                opacity: 0
                anchors.bottom: parent.bottom
                Text {
                    text: "0"
                    color: "white"
                    font.bold: true
                    styleColor:"black";
                    style: Text.Raised;
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(30);
                    anchors.horizontalCenter:parent.horizontalCenter
                }
                Text {
                    text: "Онлайн"
                    color: "white"
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(24);
                    anchors.horizontalCenter:parent.horizontalCenter
                }
            }
        }

        Row {
            id: myRow
            width: firstRow.width
            Text {
                color: "white"
                elide: Text.ElideRight
                font.bold: {true}
                font.family: {trebu4etMsNorm.name}
                font.pixelSize: {facade.doPx(28);}
                text:loader.login+" "+loader.famil
                width: parent.width-scope1.implicitWidth-scope2.implicitWidth-image1.width
            }
            Text {
                id: scope1
                text: " [ "
                color: "white"
                font.family: {trebu4etMsNorm.name}
                font.pixelSize: {facade.doPx(28);}
            }
            Image {
                id: image1
                source: "qrc:/ui/profiles/lin.png"
                width: {
                facade.toPx(sourceSize.width* 1.5)
                }
                height: {
                facade.toPx(sourceSize.height*1.5)
                }
                anchors {
                    top: parent.top
                    topMargin: facade.toPx(15)
                }
            }
            Text {
                id: scope2
                text: " 0 ]"
                color: "white"
                font.family: {trebu4etMsNorm.name}
                font.pixelSize: {facade.doPx(28);}
            }
        }

        Rectangle {
            width: firstRow.width
            height: facade.toPx(50);
            radius: facade.toPx(25);
            color: loader.menu7Color
            Row {
                Button {
                    id: inerImage
                    width: facade.toPx(40);
                    height:facade.toPx(innerImage.sourceSize.height)
                    anchors.verticalCenter: {parent.verticalCenter;}
                    background:Image {
                        id: innerImage
                        width: {facade.toPx(sourceSize.width /1.3);}
                        height:{facade.toPx(sourceSize.height/1.3);}
                        anchors.verticalCenter:parent.verticalCenter
                        source: "qrc:/ui/icons/"+(find? "searchIconWhite": "DeleteIconWhite")+".png"
                    }
                    onClicked: if(find == false) {find = true;}
                }
                Connections {
                    target: drawer;
                    onFindChanged:{
                        if (find) {
                            inerText.focus = (false)
                            inerText.clear();
                            filterList("")
                        }
                    }
                }
                TextField {
                    id: inerText
                    color: loader.menu15Color
                    height: parent.parent.height
                    rightPadding: parent.parent.radius
                    onAccepted:filterList(text.toLowerCase())
                    width: parent.parent.width - inerImage.width - parent.spacing - facade.toPx(20);
                    placeholderText: qsTr("Найти ваших друзей")
                    font.bold: true
                    font.pixelSize: facade.doPx(18);
                    font.family: trebu4etMsNorm.name
                    onActiveFocusChanged:find=false;
                    background: Rectangle{opacity:0}
                    verticalAlignment: {Text.AlignVCenter}
                    onTextChanged:{
                        if (event_handler.currentOSys() !== 1 && event_handler.currentOSys() !== 2){
                            filterList(text.toLowerCase())
                        }
                    }
                }
                anchors.verticalCenter: {parent.verticalCenter}
                anchors.leftMargin: facade.toPx(20);
                spacing: {facade.toPx(10);}
                anchors.left: {parent.left}
            }
        }

        Item {
            width: {(parent.width)}
            height: facade.toPx(10)
        }
    }

    ListView {
        id: listView
        anchors {
            topMargin: -1
            left: parent.left
            right: parent.right;
            top: profile.bottom;
            bottom:listMenu.top;
            leftMargin: leftSlider.opacity == 1? leftSlider.width: 0
        }
        clip: true
        spacing:-1
        property int memIndex:0;
        model:ListModel {id: usersModel}
        Component.onCompleted: {
            if (loader.chats.length<1) {
                var history =event_handler.loadValue("chats")
                if (history != "") loader.chats =JSON.parse(history)
            } usersModel.clear()
        }

        delegate: Item {
            id: baseItem
            visible: activity
            width: parent.width
            height: activity? facade.toPx(20)+Math.max(bug.height,fo.height):0
            Row {
                Repeater {
                    anchors.verticalCenter: parent.verticalCenter
                    model: [("trashButton.png"), "dialerButton.png"]
                    Rectangle {
                        y: 1
                        color: {loader.menu5Color}
                        width: baseItem.width * 5/10;
                        height: baseItem.height - (2*y)
                        property var fac: facade.toPx(40)
                        Rectangle {
                            width: splashImage.width + 2*fac;
                            height: {(parent.height)}
                            color: loader.menu6Color;
                            x: index * (parent.width - width)
                        }
                        Image {
                            x: {
                                if (index!=0) parent.width-width-fac
                                else Math.abs(fac);
                            }
                            anchors.verticalCenter: parent.verticalCenter
                            source: "qrc:/ui/buttons/" + (modelData)
                            width: {(facade.toPx(sourceSize.width))}
                            height: {facade.toPx(sourceSize.height)}
                            fillMode: Image.PreserveAspectFit
                            id:splashImage
                        }
                    }
                }
            }

            Rectangle {
                clip: true
                id: delegaRect
                width: parent.width
                height: parent.height
                color: {
                    if (index === 0) {
                        loader.menu14Color
                    } else "#FFEDEDED"
                }

                Rectangle {
                    width: 0
                    height: 0
                    id: coloresRect
                    color: {
                        if (index === 0) {
                            if (loader.isOnline) loader.menu15Color;
                            else
                               loader.menu1Color
                        } else loader.menu9Color
                    }

                    transform: Translate {
                        x: -coloresRect.width /2
                        y: -coloresRect.height/2
                    }
                }

                PropertyAnimation {
                    duration: 500
                    target: coloresRect
                    id: circleAnimation
                    properties:("width, height, radius")
                    from: 0
                    to: (delegaRect.width * 3);

                    onStopped: {
                        coloresRect.width  = 0;
                        coloresRect.height = 0;
                    }
                }

                MouseArea {
                    id: myMouseArea
                    anchors.fill:parent
                    property var presed
                    onClicked: {
                        if (index !=-1) listView.currentIndex = index
                        var json = {ip:usersModel.get(index).ip,pt:usersModel.get(index).port}
                        var text = usersModel.get(index).login+" "+usersModel.get(index).famil
                        chatScreen.setInfo(text, usersModel.get(index).image, json.port == 0? qsTr("Offline"): qsTr("Online"))
                        event_handler.sendMsgs(JSON.stringify(json));
                        chatScreen.open()
                        drawer.close();
                    }
                    drag.axis: {Drag.XAxis}
                    drag.minimumX: -width*0.40;
                    onPressAndHold: presed=true
                    drag.target: presed?parent:undefined
                    drag.maximumX: {
                        if (usersModel.count>=index+1) {
                            -drag.minimumX;
                        } else 0
                    }
                    onExited: {
                        circleAnimation.stop();
                    }
                    onPressed: {
                        coloresRect.x = mouseX;
                        coloresRect.y = mouseY;
                        circleAnimation.start()
                    }
                    onReleased: {
                        presed = false
                        if (parent.x >= drag.maximumX) {
                            if (usersModel.get(index).phone !== loader.tel) {
                                drawer.close();
                                listView.memIndex=index;
                                defaultDialog.show("Хотите удалить <strong>" + login + " " + famil + "</strong> из друзей?", 2)
                            }
                        }
                        if (parent.x <= drag.minimumX) {
                            if (event_handler.currentOSys() != 1)
                               Qt.openUrlExternally("tel:"+phone)
                            else
                                caller.directCall(phone)
                        }
                        parent.x=0
                    }
                }

                Connections {
                    target: defaultDialog
                    onChooseChanged: {
                        if (listView.memIndex== index) {
                            if (defaultDialog.choose == false) {
                                var phn=0;
                                if (typeof usersModel.get(index) !== 'undefined')
                                phn = usersModel.get(index).phone
                                var obj =JSON.parse(loader.frienList)
                                for (var i = 0; i < obj.length;i++) {
                                    var friend=obj[i].replace('"','')
                                    if (friend == phn) {
                                        obj.splice(i, 1)
                                        event_handler.saveSet("frd", loader.frienList = JSON.stringify(obj))
                                        loader.addFriend(friend, false)
                                        listView.memIndex = -1;
                                        break;
                                    }
                                }
                                usersModel.remove(index)
                            }
                        }
                    }
                }

                DropShadow {
                    radius: 10
                    samples: 10
                    source: bug
                    color:"#90000000"
                    anchors.fill:bug;
                }
                Rectangle {
                    id: bug
                    clip: true
                    smooth: true
                    x: facade.toPx(50) - (facade.toPx(708) - drawer.width)/facade.toPx(5);
                    width: facade.toPx(120)
                    height:facade.toPx(120)
                    anchors {
                        top: parent.top
                        topMargin: facade.toPx(10);
                    }
                    Image {
                        source: image
                        anchors.centerIn: {parent;}
                        height:sourceSize.width>sourceSize.height? parent.height: sourceSize.height*(parent.width/sourceSize.width);
                        width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height/sourceSize.height): parent.width;
                    }
                }

                Column {
                    id: fo
                    Text {
                        font.pixelSize: facade.doPx(30);
                        font.family: trebu4etMsNorm.name
                        width:fo.width-facade.toPx(100)-bug.width
                        color: {
                            if (index == 0) "white"
                            else loader.menu10Color
                        }
                        text: (login + " " + famil)
                        elide: Text.ElideRight
                    }
                    Text {
                        id: preview
                        maximumLineCount: 3
                        wrapMode: Text.WordWrap;
                        function previewText() {
                            var indx = 0, m = "", fl
                            if (typeof loader.chats[index] !== ('undefined'))
                                {indx = (loader.chats[index].message.length)}
                            if (indx >= 1) {
                                fl = loader.chats[index].message[indx-1].flag
                                if (Math.abs(fl-2) != 0)
                                    m= qsTr("Вам: ")
                                else m= qsTr("Вы: ")
                                m += loader.chats[index].message[indx-1].text
                            } else if (indx === 0) {
                                m = qsTr("Начните новый диалог");
                            }
                            return m;
                        }
                        Connections {
                            target: drawer;
                            onPositionChanged: {
                                if (position == 1) {
                                    var a = preview.previewText()
                                    preview.text = a
                                }
                            }
                        }
                        text: previewText()
                        color:index==0?"white":loader.menu11Color
                        width:fo.width-facade.toPx(100)-bug.width
                        font.family:trebu4etMsNorm.name;
                        font.pixelSize: facade.doPx(18);
                    }
                    anchors.leftMargin: facade.toPx(40);
                    anchors.left: (bug.right);
                    width: parent.width
                }
            }
        }
    }

    Rectangle {
        id: leftSlider
        opacity: 0
        width: facade.toPx(40)
        color: loader.menu4Color
        anchors {
            topMargin: -1;
            top: profile.bottom;
            bottom: listMenu.top
        }
        x:helperDrawer.position==0?0: helperDrawer.x + helperDrawer.width-1;
        MouseArea {
            property int p
            anchors.fill:parent;
            onPressed: p=mouse.x
            onPositionChanged: {
                if (mouse.x>p&&helperDrawer.position==0) helperDrawer.open()
            }
        }
        DropShadow {
            radius: 10
            samples: 10
            anchors.fill:linesColumn;
            color: "#80000000";
            source:linesColumn;
        }
        Row {
            id: linesColumn
            x: facade.toPx(10);
            spacing: {facade.toPx(6)}
            height:0.25*parent.height
            anchors.verticalCenter:parent.verticalCenter
            Repeater {
                model: 1
                Rectangle {
                    width: 3
                    height: linesColumn.height;
                }
            }
        }
    }

    DropShadow {
        radius: 14
        samples: 20
        source: (listMenu);
        color: "#90000000";
        anchors.fill: listMenu;
    }

    Rectangle {
        width: 6;
        anchors {
            top:leftRect.top
            left: parent.right;
            bottom:parent.bottom;
            leftMargin: -width*1.0;
            topMargin: (canva.width);
        }
        color: {
            if(loader.isOnline==true) loader.menu4Color;
            else {loader.menu2Color;}
        }
    }

    HelperDrawer {id : helperDrawer;}

    LinearGradient {
        anchors.top: {profile.bottom}
        anchors.topMargin: -1
        height: 10
        width: parent.width
        start: Qt.point(0, 0)
        end: Qt.point(0, height)
        gradient: Gradient {
            GradientStop {position:0; color:"#65000000"}
            GradientStop {position:1; color:"#00000000"}
        }
    }

    ListView {
        id: listMenu
        width: parent.width - 6
        property bool isShowed: false
        snapMode:ListView.SnapOneItem
        anchors.bottom: parent.bottom
        boundsBehavior: Flickable.StopAtBounds;
        Component.onCompleted: currentIndex=-1;

        clip: true
        model:ListModel {
            id: navigateDownModel
            ListElement {image: ""; target: ""}
            ListElement {
                image : "qrc:/ui/icons/devIconBlue.png";
                target: qsTr("Настройки")
            }
            ListElement {
                image : "qrc:/ui/icons/outIconBlue.png";
                target: qsTr("Выйти")
            }
        }

        height: {
            var length= parent.height
            length-= facade.toPx(540) + getProfHeight();
            var count= Math.ceil(length/facade.toPx(85))
            if (count >navigateDownModel.count)
               count = navigateDownModel.count;
            if (count < 1) count = 1;
            (count) * facade.toPx(85)
        }

        delegate:Rectangle {
            width: (parent.width)
            height: {facade.toPx(85)}
            color: ListView.isCurrentItem? "#D3D3D3": "#E5E5E5"
            MouseArea {
                id: menMouseArea;
                anchors.fill: parent;
                onEntered: listMenu.currentIndex = index
                onClicked: {
                    switch(index) {
                        case 2:
                            loader.restores();
                            chatScreen.close()
                            drawer.close()
                            loader.goTo("loginanDregister.qml")
                            event_handler.saveSet("user" , "");
                            helperDrawer.visible(false)
                        break;
                        case 1:
                            if (helperDrawer.position <= (1)) {
                                helperDrawer.open()
                            }
                    }
                    if (index == 0) {
                        myswitcher.checked=!myswitcher.checked;
                    } else if (index > 0 && index <=1) {
                        listMenu.currentIndex=index
                    }
                }
                onExited: listMenu.currentIndex=-1;
            }

            Item {
                anchors {
                    fill: parent;
                    leftMargin: facade.toPx(30)
                }

                Image {
                    source: image
                    visible: index >= 1;
                    width: facade.toPx(sourceSize.width);
                    height:facade.toPx(sourceSize.height)
                    horizontalAlignment: {(Image.AlignHCenter)}
                    anchors {
                        verticalCenter: (parent.verticalCenter)
                    }
                }

                Connections {
                    target:loader
                    onIsOnlineChanged: {
                        myswitcher.checked = (loader.isOnline);
                    }
                }
                Switch {
                    id:myswitcher
                    visible: index==0;
                    indicator: Rectangle {
                        radius: facade.toPx(25)
                        y: parent.height/2-height/2
                        implicitWidth: facade.toPx(60)
                        implicitHeight:facade.toPx(30)
                        color: {
                            if (parent.checked  == true) {
                                loader.menu12Color
                            } else loader.menu13Color;
                        }
                        DropShadow {
                            radius: 15
                            samples: 15
                            source: {switcher}
                            color: "#90000000"
                            anchors.fill: switcher;
                        }
                        Rectangle {
                            id: switcher
                            color: loader.feedColor
                            width: myswitcher.height/2.3;
                            height:myswitcher.height/2.3;
                            radius:width/2
                            x: {
                                if (myswitcher.checked) {
                                    var p=parent.height-height;
                                    parent.width - width - p/2;
                                } else {
                                    (parent.height - height)/2;
                                }
                            }
                            anchors {
                                verticalCenter: {
                                    parent.verticalCenter
                                }
                            }
                        }
                    }
                    onCheckedChanged: {
                        loader.isOnline = (checked)
                    }
                    width: facade.toPx(64)
                    height:facade.toPx(85)
                }

                Text {
                    anchors {
                        left: myswitcher.right
                        leftMargin: facade.toPx(30)
                        verticalCenter: {parent.verticalCenter}
                    }
                    color: loader.menu10Color;
                    font.pixelSize: facade.doPx(22)
                    font.family:trebu4etMsNorm.name
                    text: {
                        if (index == 0) {
                            if (myswitcher.checked)
                                qsTr(("Вы онлайн"))
                            else qsTr(("Невидимы"))
                        } else {target}
                    }
                }
            }
        }
    }
}
