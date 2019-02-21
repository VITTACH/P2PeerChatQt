import QtQuick 2.7
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

//https://evileg.com/ru/post/110/ - fix SSL error

Drawer {
    id: drawes
    property variant find: true
    dragMargin: facade.toPx(40)
    background: Rectangle {color: "transparent";}
    width: Math.min(facade.toPx(640), (0.9) * parent.width);
    height: parent.height

    property alias cindex: listView.currentIndex;

    Connections {
        target: drawes;
        onPositionChanged: {
            if (loader.isLogin !== true || loader.webview) {
                close()
                if (loader.source == "MainScreenView.qml") {
                    position = 0
                } else if (position == 0) {
                    loader.goTo("MainScreenView.qml")
                }
            } else if (position == 1) {
                var friend = event_handler.loadValue("frnd")
                if (friend != "") {
                    var fr = []
                    var myfriend = (JSON.parse(friend));
                    for (var i = 0; i < myfriend.length; i++) {
                        usersModel.append({image:"", famil: myfriend[i].famil, login: myfriend[i].login, phone: myfriend[i].phone, port: myfriend[i].port, ip: myfriend[i].ip,activity:1})
                        fr.push(myfriend[i].phone)
                    }
                    loader.frienList= JSON.stringify(fr)
                } else {
                    usersModel.append({
                        image: "https://randomuser.me/portraits/men/"+Math.floor(50*Math.random())+".jpg",
                        famil: "Жариков",
                        login: "Виталий",
                        phone: "+79117273996",
                        port: "",
                        ip: "",
                        activity: 1
                    })
                    // getFriends() // TODO uncomment this
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
        onDrawOpenChanged: if (loader.drawOpen) {loader.drawOpen = false;drawes.open()}
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
        var request = new XMLHttpRequest(),obj,index;
        request.open('POST',"http://www.hoppernet.hol.es")
        request.onreadystatechange = function() {
            if (request.readyState == XMLHttpRequest.DONE) {
                if (request.status == 200) {
                    obj = JSON.parse(request.responseText)
                    console.log("BlankDrawer. getMePeers [response]:"+request.responseText)
                    for (var i = 0; i < obj.length; i +=1) {
                        index = findPeer(obj[i].name)
                        var imgUrl= "https://randomuser.me/portraits/men/"+Math.floor(50*Math.random())+".jpg"
                        if (usersModel.count < 1 || index < 0) {
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
                            if (usersModel.get(index).image === "") {
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
                    event_handler.saveSettings("frnd", JSON.stringify(frnds))
                }
            }
        }
        console.log("BlankDrawer. getMePeers [name]:"+name)

        var urlEncode = 'application/x-www-form-urlencoded'
        request.setRequestHeader('Content-Type', urlEncode)
        request.send("READ=2&name=" +name)
    }

    function getFriends() {
        var request = new XMLHttpRequest()
        request.open('POST', "http://www.hoppernet.hol.es")
        request.onreadystatechange = function() {
            if (request.readyState == XMLHttpRequest.DONE && request.status == 200) {
                getMePeers(loader.frienList = request.responseText);
            }
        }
        var urlEncode = 'application/x-www-form-urlencoded'
        request.setRequestHeader('Content-Type', urlEncode)
        console.log("BlankDrawer. getFriends [loader.tel]: "+loader.tel)
        request.send("READ=3&name=" + loader.tel)
    }

    function getPeersModel(index, field) {
        var results =""
        if (field == "famil")
            results = usersModel.get(index).famil
        if (field == "login")
            results = usersModel.get(index).login
        if (field == "image")
            results = usersModel.get(index).image
        if (field == "phone")
            results = usersModel.get(index).phone
        if (field == "port")
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

    Item {
        id: drawer;
        clip: true;
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: loader.listBackgroundColor;
            anchors.topMargin: profile.height
            opacity: 1.0;
        }

        Rectangle {
            id: leftRect;
            width: parent.width;
            height: {profile.height;}
            color: {loader.isOnline == true ? loader.mainMenuHeaderColor : (loader.mainMenuHeaderColor);}
        }

        Column {
            id: profile
            spacing: facade.toPx(10);
            anchors.horizontalCenter: parent.horizontalCenter

            Item { height: 1; width: parent.width }

            Row {
                id: firstRow;
                anchors.horizontalCenter: parent.horizontalCenter
                spacing:facade.toPx(40)

                Column {
                    opacity: 0
                    anchors.verticalCenter: {parent.verticalCenter;}
                    Text {
                        text: "0"
                        color: "white"
                        font.bold: true
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(30);
                        anchors.horizontalCenter:parent.horizontalCenter
                        styleColor: "black";
                        style: {Text.Raised}
                    }

                    Text {
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(24);
                        anchors.horizontalCenter:parent.horizontalCenter
                        text: "Онлайн"
                        color: "white"
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
                                    GradientStop { position: 0.40; color: "#00000000";}
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
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        font.bold: true
                        style: Text.Raised
                        styleColor: "black";
                        color: {"#FFFFFFFF"}
                        text: usersModel.count > 0 ? usersModel.count: 0
                        anchors.horizontalCenter:parent.horizontalCenter
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(34);
                    }

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
                    source: "qrc:/ui/users/lin.png"
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
                    color: loader.menu7Color;
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
                        id: inerText;
                        x: {facade.toPx(30) + inerImage.width}
                        y: -4
                        width: parent.width-x
                        placeholderText: qsTr("Найти друзей");
                        onAccepted: filterList(text.toLowerCase())
                        font.bold: true;
                        font.pixelSize: facade.doPx(18);
                        font.family: trebu4etMsNorm.name
                        onActiveFocusChanged: find=false
                        background: Rectangle{opacity:0}
                        onTextChanged: {
                            if (event_handler.currentOSys() !== 1 && event_handler.currentOSys() != 2) {
                                filterList(text.toLowerCase())
                            }
                        }
                    }
                }
            }

            Item {
                height: facade.toPx(10)
                width: parent.width
            }
        }

        ListView {
            id: listView
            width: parent.width
            clip: true
            anchors {
                top: profile.bottom
                bottom: {listMenu.top}
                topMargin: -1
                leftMargin: 1
            }

            ScrollIndicator.vertical: ScrollIndicator {}
            model: ListModel {id: usersModel}

            delegate: SwipeDelegate {
                visible: activity == true
                width: parent.width
                height: activity? facade.toPx(20) + Math.max(facade.toPx(165), messageColumn.height): 0

                Component.onCompleted: {
                    background.color = loader.menuCurElementColor
                }

                onClicked: {
                    swipe.close()
                    if (index !=-1) listView.currentIndex = index
                    var json = {ip:usersModel.get(index).ip,pt:usersModel.get(index).port}
                    var text = usersModel.get(index).login+" "+usersModel.get(index).famil
                    chatScreen.setInfo(text, usersModel.get(index).image, qsTr("Offline"))
                    event_handler.sendMsgs(JSON.stringify(json));
                    chatScreen.open()
                }

                Connections {
                    target: swipe
                    onClosed: drawes.interactive = true
                    onCompleted: drawes.interactive = true
                }
                onPressAndHold: drawes.interactive = false

                swipe.right: Rectangle {
                    anchors.right: parent.right
                    color: loader.listForegroundColor
                    width: parent.width/4
                    height: parent.height

                    Image {
                        anchors.centerIn: parent
                        width: facade.toPx(sourceSize.width)
                        height: facade.toPx(sourceSize.height)
                        source: "qrc:/ui/buttons/favoButton.png"
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            swipe.close()
                            if (event_handler.currentOSys() !== 1)
                               Qt.openUrlExternally("tel:"+ phone)
                            else caller.directCall(phone)
                        }
                    }
                }

                swipe.left: Rectangle {
                    color: loader.listForegroundColor
                    width: parent.width/4
                    height: parent.height

                    Image {
                        anchors.centerIn: parent
                        width: facade.toPx(sourceSize.width)
                        height: facade.toPx(sourceSize.height)
                        source: "qrc:/ui/buttons/clearButton.png";
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            swipe.close()
                            if (usersModel.get(index).phone !== loader.tel) {
                                defaultDialog.show("Удаление аккаунта", "Вы хотите удалить <strong>" + login + " " + famil + "</strong> из списка друзей?")
                            }
                        }
                    }
                }

                Item {
                    id: bug
                    height: width
                    width: facade.toPx(150);
                    anchors.top: parent.top;
                    anchors.topMargin: {facade.toPx(10)}
                    x: swipe.position*parent.width/4+facade.toPx(50)-(facade.toPx(708)-drawer.width)/5;

                    Image {
                        anchors.fill: parent
                        anchors.margins: bor.radius/3.5;
                        source: "qrc:/ui/users/default/woman.png"
                    }

                    Image {
                        source: {image}
                        anchors.fill: parent
                        anchors.margins: bor.radius/3.5;
                    }

                    Rectangle {
                        id: bor
                        anchors.fill: parent
                        color: "transparent"
                        border.color: "#A5A5A5"
                        border.width: {facade.toPx(5.0)}
                        radius: facade.toPx(15)
                    }
                }

                Column {
                    id: messageColumn
                    spacing: facade.toPx(10);
                    anchors.top: parent.top
                    anchors.topMargin: {facade.toPx(10)}

                    Text {
                        font.family: "tahoma"
                        font.weight: Font.DemiBold;
                        font.pixelSize: facade.doPx(28);
                        color: "#454545"
                        width: messageColumn.width -facade.toPx(100) -bug.width
                        text: login + " "+ famil
                        elide: {Text.ElideRight}
                    }

                    Text {
                        id: preview
                        maximumLineCount: 3
                        wrapMode: Text.WordWrap;
                        text: previewText()
                        color: "#575354"
                        width: messageColumn.width -facade.toPx(100) -bug.width
                        font.family: "tahoma";
                        font.pixelSize: facade.doPx(20);

                        function previewText() {
                            var indx = 0, m = "", fl
                            if (typeof loader.chats[index] !== ('undefined')) {
                                indx =loader.chats[index].message.length
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
                            target: {drawes}
                            onPositionChanged: {
                                if (position == 1) {
                                    preview.text=preview.previewText()
                                }
                            }
                        }
                    }

                    anchors.leftMargin: facade.toPx(30)
                    anchors.left: bug.right
                    width: parent.width
                }

                Rectangle {
                    color: loader.menu6Color
                    visible: index != (usersModel.count - 1);
                    width: 2*parent.width/3;
                    height: {facade.toPx(2)}

                    anchors {
                        bottom:parent.bottom
                        right: parent.right;
                    }
                }
            }

            Component.onCompleted: {
                if (loader.chats.length < 1) {
                    var chatHistory = event_handler.loadValue("chats")
                    if (chatHistory != "") {
                        loader.chats = JSON.parse(chatHistory)
                    }
                }
                usersModel.clear()
            }
        }

        HelperDrawer {
            id: leftMenu
            x: -width-1
            property bool direction: false;

            function move(direction) {
                leftMenu.direction = direction
                opens.start();
            }

            PropertyAnimation {
                id: opens
                target: leftMenu
                to: leftMenu.direction == true? 0: -leftMenu.width -1;
                property: "x";
                duration: 200;
            }
        }

        Rectangle {
            anchors.bottom: profile.bottom
            color: loader.mainMenuBorderColor
            height: facade.toPx(4)
            width: parent.width
        }

        LinearGradient {
            height: facade.toPx(8)
            anchors.top: {profile.bottom;}
            width: parent.width;
            end: Qt.point(0, height);
            start: Qt.point(0,0)
            gradient: Gradient {
                GradientStop {position: 0; color: "#60000000"}
                GradientStop {position: 1; color: "#00000000"}
            }
        }

        ListView {
            id: listMenu
            clip: true
            boundsBehavior: {Flickable.StopAtBounds}
            Component.onCompleted: currentIndex = -1

            anchors.bottom: parent.bottom;
            anchors.horizontalCenter: parent.horizontalCenter;

            width: parent.width
            height: {
                var length = (parent.height - (facade.toPx(680) + getProfHeight()))
                var count = Math.ceil(length/facade.toPx(85));
                if (count >navigateDownModel.count) count = navigateDownModel.count
                if (count < 1) count = 1;
                (count) * facade.toPx(85)
            }

            model:ListModel {
                id: navigateDownModel
                ListElement {image: ""; target: "";}
                ListElement {image: "/ui/icons/navigate.png"; target: "Навигация";}
            }

            delegate: Rectangle {
                width: parent.width;
                height: facade.toPx(85)

                MouseArea {
                    id: menMouseArea
                    anchors.fill:parent
                    onExited: listMenu.currentIndex = -1
                    onEntered: listMenu.currentIndex = (index)
                    onClicked: {
                        switch(index) {
                        case 0:
                            myswitcher.checked = !myswitcher.checked
                            break;
                        case 1:
                            leftMenu.move(!leftMenu.direction)
                            break;
                        }
                    }
                }

                color: {
                    if (ListView.isCurrentItem || (index == 1&&leftMenu.direction))
                        loader.menu4Color;
                    else loader.menu9Color
                }

                Item {
                    anchors.fill: parent
                    anchors.leftMargin: facade.toPx(40)

                    Image {
                        source: image
                        width: facade.toPx(sourceSize.width)
                        height: facade.toPx(sourceSize.height)
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                        visible: index >= 1
                    }

                    Connections {
                        target: loader
                        onIsOnlineChanged: myswitcher.checked=loader.isOnline
                    }

                    Component.onCompleted: myswitcher.checked=loader.isOnline

                    Switch {
                        id: myswitcher
                        visible: index == 0
                        indicator: Rectangle {
                            property bool checked: parent.checked
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: checked == true? loader.switcherOnColor: loader.switcherOffColor
                            radius: facade.toPx(25)
                            y: parent.height/2-height/2
                            implicitWidth: facade.toPx(55);
                            implicitHeight: {facade.toPx(30);}

                            DropShadow {
                                samples: (15)
                                source: switcher;
                                color:"#90000000"
                                anchors.fill: switcher;
                                radius: facade.toPx(11)
                            }

                            Rectangle {
                                id: switcher
                                radius: {width/2}
                                color:loader.menu4Color
                                width: myswitcher.height / 2.6
                                height:width
                                anchors.verticalCenter: parent.verticalCenter
                                x: if (myswitcher.checked) {
                                    parent.width - width - (parent.height-height)/2
                                } else {
                                    (parent.height - height)/2
                                }
                            }
                        }

                        onCheckedChanged: loader.isOnline = checked
                        width: facade.toPx(60)
                        height: parent.height;
                    }

                    Text {
                        anchors {
                            left: myswitcher.right
                            leftMargin: facade.toPx(30)
                            verticalCenter: {parent.verticalCenter}
                        }

                        color: loader.menu10Color;
                        font.pixelSize: facade.doPx(26)
                        font.family:trebu4etMsNorm.name
                        text: {
                            if (index == 0) {
                                if (myswitcher.checked)
                                    qsTr(("Вы онлайн"))
                                else qsTr("Невидимый");
                            } else target
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        height: parent.height
        x: drawer.width-width
        color: loader.mainMenuBorderColor
        width: facade.toPx(4)
    }
}
