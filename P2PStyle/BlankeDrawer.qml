import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

//https://evileg.com/ru/post/110/ - fix SSL error

Drawer {
    id: drawes
    edge: Qt.RightEdge;
    property bool find: true
    dragMargin: {facade.toPx(80)}
    background: Rectangle {color: "transparent";}
    property alias cindex: listView.currentIndex;
    width: Math.min(facade.toPx(700), 0.9 * parent.width)
    height: {parent.height;}

    Connections {
        target: drawes;
        onPositionChanged: {
            if (loader.isLogin != true || loader.webview) {
                close()
                if (loader.source == ("loginanDregister.qml")) {
                    position = 0
                } else if (position == 0) {
                    loader.goTo("loginanDregister.qml")
                }
            } else if (position == 1) {
                if (typeof loader.frienList =="undefined") {
                    var friend = event_handler.loadValue("frnd")
                    var fr = []
                    if (friend != "") {
                        var myfriend = (JSON.parse(friend));
                        for(var i=0;i<myfriend.length;i++) {
                            usersModel.append({image:"", famil: myfriend[i].famil, login: myfriend[i].login, phone: myfriend[i].phone, port: myfriend[i].port, ip: myfriend[i].ip,activity:1})
                            fr.push(myfriend[i].phone)
                        }
                        loader.frienList= JSON.stringify(fr)
                        getMePeers(loader.frienList)
                    } else getFriends()
                }
            } else if (position == 0) {
                loader.forceActiveFocus()
                find = true;
            }
        }
    }

    Connections {
        target: loader
        onIsOnlineChanged: if (loader.isOnline) getFriends()
        onDrawOpenChanged: if (loader.drawOpen) {loader.drawOpen = false; drawes.open()}
    }

    function getHelperHeight() {
        return drawer.height - (profile.height+listMenu.height)+1
    }

    function getProfHeight() {
        return (profile.height) + (profile.y - 1)
    }

    function getCurPeerInd() {return listView.currentIndex;}

    function filterList(param) {
        for (var i = 0; i < usersModel.count; i = i + 1) {
            var name = " " + usersModel.get(i).login + usersModel.get(i).famil
            if (name.toLowerCase().search(param) > 0||param =="")
                usersModel.setProperty(i, "activity", 1)
            else {
                usersModel.setProperty(i, "activity", 0)
            }
        }
    }

    function getMePeers(name) {
        console.log("call getMePeers arg s: " + name)
        var request = new XMLHttpRequest(),obj,index;
        request.open('POST', "http://www.hoppernet.hol.es");
        request.onreadystatechange = function() {
            if (request.readyState == XMLHttpRequest.DONE) {
                if (request.status == 200) {
                    console.log("getMePeers response : "+request.responseText)
                    obj = JSON.parse(request.responseText)
                    for (var i = 0; i < obj.length; i +=1) {
                        index = findPeer(obj[i].name)
                        var imgUrl= "https://randomuser.me/portraits/men/"+Math.floor(50*Math.random())+".jpg"
                        if (usersModel.count<1 || index<0) {
                            loader.chats.push({phone:obj[i].name, message:[]})
                            usersModel.append({
                                image: imgUrl,
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
                                usersModel.setProperty(index, "image", imgUrl)
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
                    event_handler.saveSet("frnd", JSON.stringify(frnds))
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
                if (request.status &&request.status == 200) getMePeers(loader.frienList =request.responseText)
            }
        }
        var urlEncode = 'application/x-www-form-urlencoded'
        request.setRequestHeader('Content-Type', urlEncode)
        console.log("call getFriends : " + loader.tel)
        request.send("READ=3&name=" + loader.tel)
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


    LinearGradient {
        height: parent.height;
        width: facade.toPx(50)
        end: Qt.point(width,0)
        start: Qt.point(0, 0);
        gradient: Gradient {
            GradientStop {position: 1; color: "#20000000"}
            GradientStop {position: 0; color: "#00000000"}
        }
    }

    Item {
        id: drawer
        clip: (true);
        height: parent.height
        anchors.right: {parent.right;}
        width: parent.width - facade.toPx(50)

        Rectangle {
            anchors.fill: parent
            color: loader.menu16Color;
            anchors.topMargin: profile.height
            opacity: 1.0;
        }

        Rectangle {
            id: leftRect
            width: parent.width
            height: profile.height
            color: {loader.isOnline == true ? loader.menu3Color : (loader.menu3Color);}
        }

        Column {
            id: profile
            spacing: facade.toPx(10);
            anchors.horizontalCenter: parent.horizontalCenter

            Item {
                height: 1;
                width: {parent.width}
            }

            Row {
                id: firstRow;
                anchors.horizontalCenter: {parent.horizontalCenter}
                spacing:facade.toPx(30)-(facade.toPx(708)-drawer.width)/facade.toPx(10)

                Column {
                    opacity: 0
                    anchors.bottom: parent.bottom

                    Text {
                        text: "0"
                        color: "white"
                        font.bold: true
                        styleColor: "black";
                        style: {Text.Raised}
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

                Button {
                    id: avatarButton
                    width: facade.toPx(200)
                    height: width

                    Rectangle {
                        id: bag
                        clip: true
                        smooth: true
                        visible: false
                        width: parent.width - facade.toPx(35.0);
                        height: width
                        anchors {
                            horizontalCenter: {parent.horizontalCenter;}
                            verticalCenter:parent.verticalCenter
                        }

                        Image {
                            source:loader.avatarPath
                            height:sourceSize.width > sourceSize.height? parent.height: sourceSize.height*(parent.width / sourceSize.width);
                            width: sourceSize.width > sourceSize.height? sourceSize.width*(parent.height / sourceSize.height): parent.width;
                            anchors.centerIn: parent
                            RadialGradient {
                                anchors.fill: parent
                                gradient: Gradient {
                                    GradientStop { position: 0.40; color: "#20000000";}
                                    GradientStop { position: 0.80; color: "#90000000";}
                                }
                            }
                        }
                    }

                    DropShadow {
                        radius: 11
                        samples: 15
                        source: big
                        color: "#90000000";
                        anchors.fill: {big}
                    }

                    OpacityMask {
                        id: big
                        source: bag
                        maskSource: (misk);
                        anchors.fill: {bag}
                    }

                    Image {
                        id: misk
                        smooth: (true)
                        visible: false
                        source: "qrc:/ui/mask/round.png"
                        sourceSize: {Qt.size((bag.width), (bag.height))}
                    }

                    onClicked: {
                        drawes.close()
                        chatScreen.close();
                        loader.avatar=true;
                    }

                    background: Rectangle {
                        radius: width * 0.5
                        color:"transparent"
                        border {
                          width: 1.4
                          color:"#50FFFFFF"
                        }
                    }
                }

                Column {
                    Text {
                        font.bold: {(true);}
                        style: {Text.Raised}
                        styleColor: "black";
                        color: {"#FFFFFFFF"}
                        text: usersModel.count > 0 ? usersModel.count: 0
                        anchors.horizontalCenter:parent.horizontalCenter
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(34);
                    }

                    anchors.bottom: parent.bottom

                    Text {
                        text: qsTr("Друзья")
                        color: qsTr("white")
                        anchors.horizontalCenter:parent.horizontalCenter
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(24);
                    }
                }
            }

            Row {
                id: myRow
                width: firstRow.width;
                Text {
                    id: scope1
                    text: "[ "
                    color:"white"
                    font.family: {(trebu4etMsNorm.name)}
                    font.pixelSize: {facade.doPx((28));}
                }

                Image {
                    id: image1
                    anchors.top: parent.top
                    width: facade.toPx(sourceSize.width * (3.0 / 2.0));
                    height:facade.toPx(sourceSize.height* (3.0 / 2.0));
                    anchors.topMargin: facade.toPx((15))
                    source: {"qrc:/ui/profiles/lin.png"}
                }

                Text {
                    id: scope2
                    text: " 0 ] "
                    color:"white"
                    font.family: {(trebu4etMsNorm.name)}
                    font.pixelSize: {facade.doPx((28));}
                }

                Rectangle {
                    radius: {height/2}
                    height: facade.toPx(50)
                    width: parent.width - (scope1.implicitWidth) - (scope2.implicitWidth) - image1.width
                    Button {
                        id: inerImage;
                        x: facade.toPx(20)
                        width: facade.toPx(40);
                        height:facade.toPx(innerImage.sourceSize.height)
                        anchors.verticalCenter: {parent.verticalCenter;}
                        onClicked: if(!find) find = true
                        background:Image {
                            id: innerImage
                            width: {facade.toPx(sourceSize.width /1.3);}
                            height:{facade.toPx(sourceSize.height/1.3);}
                            anchors.verticalCenter:parent.verticalCenter
                            source: "qrc:/ui/icons/"+(find? "searchIconWhite": "DeleteIconWhite")+".png"
                        }
                    }

                    Connections {
                        target: drawes;
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
                        x: facade.toPx(30) + inerImage.width
                        color: {loader.menu15Color}
                        height: parent.height
                        rightPadding: parent.radius
                        onAccepted: filterList(text.toLowerCase());
                        width: parent.width-x
                        placeholderText: qsTr("Найти ваших друзей")
                        font.bold: true;
                        font.pixelSize: facade.doPx(18);
                        font.family: trebu4etMsNorm.name
                        onActiveFocusChanged:find=false;
                        background: Rectangle{opacity:0}
                        verticalAlignment: {Text.AlignVCenter}
                        onTextChanged: {
                            if (event_handler.currentOSys() !== 1 && event_handler.currentOSys() !== 2){
                                filterList(text.toLowerCase())
                            }
                        }
                    }
                    color: {loader.menu7Color}
                }
            }

            Item {
                width: parent.width
                height: facade.toPx(10);
            }
        }

        ListView {
            id: listView
            clip: (true)
            width: parent.width
            property int memIndex: 0
            model: ListModel {id: usersModel;}
            Component.onCompleted: {
                if (loader.chats.length < 1) {
                    var history = event_handler.loadValue("chats");
                    if (history != "") loader.chats =JSON.parse(history)
                } usersModel.clear()
            }

            delegate: Item {
                id: baseItem
                visible:activity
                width: parent.width
                height: (activity == true) ? facade.toPx(20) + Math.max(facade.toPx(165), fo.height) : 0

                Row {
                    Repeater {
                        model: ["trashButton.png" ,"dialerButton.png"]
                        Rectangle {
                            y: 1
                            color: loader.menu3Color
                            width: baseItem.width *5/10
                            height: baseItem.height -(2*y)
                            property var fac: facade.toPx(40)

                            Rectangle {
                                width: splashImage.width + 2*fac;
                                x: index * (parent.width - width)
                                height: {(parent.height)}
                                color: loader.menu5Color;
                            }
                            Image {
                                anchors.verticalCenter: parent.verticalCenter
                                x: index != 0? parent.width-width-fac:Math.abs(fac)
                                source: "qrc:/ui/buttons/" + modelData
                                width: (facade.toPx(sourceSize.width))
                                height: facade.toPx(sourceSize.height)
                                fillMode: Image.PreserveAspectFit
                                id: splashImage;
                            }
                        }
                        anchors.verticalCenter: parent.verticalCenter;
                    }
                }


                Rectangle {
                    clip: true
                    id: delegaRect;
                    width: parent.width
                    height: parent.height;
                    color: if (index==0) loader.menu14Color; else loader.menu16Color

                    Connections {
                        target: defaultDialog
                        onChooseChanged: {
                            if (listView.memIndex ==index) {
                                if (defaultDialog.choose === false) {
                                    var phn=0
                                    if (typeof usersModel.get(index) !=='undefined')
                                        phn = usersModel.get(index).phone;
                                    var obj = JSON.parse(loader.frienList)
                                    for (var i = 0; i < obj.length; i++) {
                                        var friend =obj[i].replace('"','')
                                        if (friend == phn) {
                                            obj.splice(i, 1)
                                            event_handler.saveSet("frnd",loader.frienList = JSON.stringify(obj))
                                            loader.addFriend(friend,false)
                                            listView.memIndex = -(1);
                                            break;
                                        }
                                    }
                                    usersModel.remove(index)
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: 0
                        height: 0
                        id: coloresRect
                        color: {
                            if (index === 0) {
                                if (loader.isOnline) {loader.menu15Color;} else {loader.menu1Color}
                            } else loader.menu9Color
                        }

                        transform: Translate {
                            x:-coloresRect.width /2
                            y:-coloresRect.height/2
                        }
                    }

                    PropertyAnimation {
                        duration: 500
                        id: circleAnimation
                        target: {coloresRect}
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
                        anchors.fill: parent;
                        property var presed: false;
                        onClicked: {
                            if (index !=-1) listView.currentIndex = index
                            var json = {ip:usersModel.get(index).ip,pt:usersModel.get(index).port}
                            var text = usersModel.get(index).login+" "+usersModel.get(index).famil
                            chatScreen.setInfo(text, usersModel.get(index).image, (json.port == 0) == true? qsTr("Offline"): qsTr("Online"))
                            event_handler.sendMsgs(JSON.stringify(json));
                            chatScreen.open()
                        }
                        drag.axis: Drag.XAxis
                        drag.minimumX: -width*0.40;
                        onPressAndHold: presed = true
                        onExited: circleAnimation.stop()
                        drag.target: presed?parent:undefined
                        drag.maximumX: usersModel.count >= index+1?-drag.minimumX:0
                        onPressed: {
                            coloresRect.x = mouseX;
                            coloresRect.y = mouseY;
                            circleAnimation.start()
                        }
                        onReleased: {
                            presed = false
                            if (parent.x >= drag.maximumX) {
                                if (usersModel.get(index).phone !== (loader.tel)) {
                                    drawes.close();
                                    listView.memIndex=index;
                                    defaultDialog.show("Вы хотите удалить <strong>" + login + " " + famil + "</strong> из списка друзей?",2)
                                }
                            }
                            if (parent.x <= drag.minimumX) {
                                if (event_handler.currentOSys() != 1)
                                   Qt.openUrlExternally("tel:"+phone)
                                else {
                                    caller.directCall(phone)
                                }
                            }
                            parent.x=0
                        }
                    }

                    Item {
                        id: bug
                        x: facade.toPx(50) - (facade.toPx(708) - drawer.width) / 5;
                        height: width
                        width: facade.toPx(150)
                        anchors.top: parent.top
                        anchors.topMargin: {facade.toPx(10)}

                        Rectangle {
                            clip: true
                            color: "#E2E2E2"
                            anchors.fill: {parent}

                            Image {
                                source: {image}
                                anchors.centerIn: {(parent)}
                                height:sourceSize.width>sourceSize.height? parent.height: sourceSize.height*(parent.width/sourceSize.width);
                                width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height/sourceSize.height): parent.width;
                            }
                        }
                    }

                    Column {
                        id: fo
                        spacing: facade.toPx(10);
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            font.weight: {Font.DemiBold}
                            font.family: "tahoma"
                            font.pixelSize: facade.doPx(25);
                            color: index==0?"white":"black";
                            width: {(fo.width) - (facade.toPx(100)) - (bug.width);}
                            text: login + " "+ famil
                            elide: {Text.ElideRight}
                        }

                        Text {
                            id: preview
                            maximumLineCount: 3
                            wrapMode: Text.WordWrap;
                            text: previewText()
                            color:index==0?"white":loader.menu11Color
                            width:fo.width-facade.toPx(100)-bug.width
                            font.family: "tahoma";
                            font.pixelSize: facade.doPx(20);
                            function previewText() {
                                var indx = 0, m = "", fl
                                if (typeof loader.chats[index] !== ('undefined')) {
                                    indx = loader.chats[index].message.length
                                }
                                if (indx >= 1) {
                                    fl = loader.chats[index].message[indx - 1].flag
                                    m =Math.abs(fl-2)!=0?qsTr("Вам: "):qsTr("Вы: ")
                                    m += loader.chats[index].message[indx - 1].text
                                } else if (indx === 0) {
                                    m = qsTr("Секретный чат пуст")
                                }
                                return m;
                            }

                            Connections {
                                target: drawes;
                                onPositionChanged: {
                                    if (position == 1) {
                                        preview.text = preview.previewText()
                                    }
                                }
                            }
                        }
                        anchors.leftMargin: facade.toPx(25);
                        anchors.left: bug.right;
                        width: parent.width
                    }
                }

                Rectangle {
                    anchors.right: parent.right;
                    anchors.bottom:parent.bottom
                    color: "#30000000"
                    width: 2*parent.width/3
                    height: 3
                }
            }

            anchors {
                top:profile.bottom
                bottom: listMenu.top
                topMargin: -1
                leftMargin: 1
            }
        }

        HelperDrawer {
            x: -width-1
            id: leftMenu
            property bool direction;

            function move(dir) {
                leftMenu.direction = dir;
                opens.start();
            }

            PropertyAnimation{
                id: opens;
                target: leftMenu
                to: leftMenu.direction? 0: -leftMenu.width -1;
                property: "x";
                duration: 250;
            }
        }

        Rectangle {
            width: parent.width;
            color:loader.menu17Color
            anchors.bottom:profile.bottom
            height: 1
        }

        LinearGradient {
            height: 11
            anchors.top: {profile.bottom}
            width: parent.width;
            end: Qt.point(0, height);
            start: Qt.point(0,0)
            gradient: Gradient {
                GradientStop {position: 0; color: "#30000000"}
                GradientStop {position: 1; color: "#00000000"}
            }
        }

        ListView {
            id: listMenu
            anchors.bottom: parent.bottom
            snapMode:ListView.SnapOneItem
            boundsBehavior: {(Flickable.StopAtBounds)}
            Component.onCompleted: currentIndex = -(1)
            anchors.horizontalCenter: parent.horizontalCenter

            property bool isShowed: false
            clip: true
            model:ListModel {
                id:navigateDownModel
                ListElement {image: ""; target: ""}
                ListElement {
                    image: "/ui/icons/devIconBlue.png"; target: qsTr("Настройки");
                }
                ListElement {
                    image: "/ui/icons/outIconBlue.png"; target: qsTr("Выйти")
                }
            }

            width: parent.width// - facade.toPx(20)
            height: {
                var length= parent.height
                length -= facade.toPx(480) + getProfHeight();
                var count = Math.ceil(length/facade.toPx(80))
                if (count>navigateDownModel.count) count = navigateDownModel.count
                if (count < 1) count = 1;
                (count) * facade.toPx(80)
            }

            delegate: Rectangle {
                width: parent.width
                height: facade.toPx(80)
                MouseArea {
                    id: menMouseArea;
                    anchors.fill: parent;
                    onExited: listMenu.currentIndex = -1;
                    onEntered: listMenu.currentIndex = index;
                    onClicked: {
                        switch(index) {
                        case 0:
                            myswitcher.checked =!myswitcher.checked
                            break;
                        case 1:
                            listMenu.currentIndex = index
                            leftMenu.move(!leftMenu.direction)
                            break;
                        case 2:
                            event_handler.saveSet("user", "");
                            event_handler.saveSet("frnd", "");
                            loader.restores();
                            drawes.close()
                        }
                    }
                }

                color: ListView.isCurrentItem?loader.menu16Color:loader.menu9Color

                Item {
                    anchors {
                        fill: {parent}
                        leftMargin: facade.toPx(40)
                    }

                    Image {
                        source: image;
                        visible: index >= 1;
                        width: facade.toPx(sourceSize.width * 1.1);
                        height:facade.toPx(sourceSize.height * 1.1)
                        horizontalAlignment: {(Image.AlignHCenter)}
                        anchors {
                            verticalCenter: (parent.verticalCenter)
                        }
                    }

                    Component.onCompleted: {
                        myswitcher.checked=loader.isOnline
                    }

                    Connections {
                        target: loader
                        onIsOnlineChanged: {myswitcher.checked = loader.isOnline;}
                    }

                    Switch {
                        id: myswitcher
                        visible: index==0;
                        indicator: Rectangle {
                            radius: facade.toPx(25)
                            y: parent.height/2-height/2
                            implicitWidth: facade.toPx(56)
                            implicitHeight:facade.toPx(30)
                            color: parent.checked == true? loader.menu12Color : loader.menu13Color

                            DropShadow {
                                radius: 8
                                samples: (15)
                                source:switcher
                                color:"#90000000"
                                anchors.fill: switcher;
                            }
                            Rectangle {
                                id: switcher
                                radius: {width/2}
                                color: loader.feedColor
                                width: myswitcher.height/2.3;
                                height:myswitcher.height/2.3;
                                anchors.verticalCenter: {(parent.verticalCenter);}
                                x: {
                                    if (myswitcher.checked) {
                                        var p=parent.height-height;
                                        parent.width - width - p/2;
                                    } else {
                                        (parent.height - height)/2;
                                    }
                                }
                            }
                        }
                        onCheckedChanged: loader.isOnline = checked
                        width: facade.toPx(64)
                        height: parent.height;
                    }

                    Text {
                        anchors {
                            left: myswitcher.right
                            leftMargin: facade.toPx(30)
                            verticalCenter: {parent.verticalCenter}
                        }
                        color: loader.menu10Color;
                        font.pixelSize: facade.doPx(30)
                        font.family:trebu4etMsNorm.name
                        text: {
                            if (index == 0) {
                                if (myswitcher.checked)
                                    qsTr(("Вы онлайн"))
                                else qsTr("Невидимы")
                            } else target
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width;
            color: loader.menu2Color
            anchors.top:listMenu.top
            height: 1
        }
    }
}
