import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Drawer {
    id: drawer

    Connections {
        target: drawer;
        onPositionChanged: {
            if (loader.isLogin != true || loader.webview) {
                close()
                position = 0
            } else if (position == 1) {
                helperDrawer.visible(true)
                if (loader.frienList =="") {
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
            } else if (position == 0) {
                helperDrawer.visible(false);
                loader.focus = !false
                find = true;
            }
        }
    }

    Connections {
        target: loader
        onIsOnlineChanged: if(loader.isOnline) getFriends()
    }

    dragMargin:facade.toPx(40)
    property bool find: (true)
    property alias cindex: listView.currentIndex;
    background: Rectangle {color: "transparent";}
    width: {Math.min(facade.toPx(780), 0.9 * parent.width)}
    height: parent.height;
    function getHelperHeight() {return (leftSlider.height)}
    function getProfHeight() {
        return (profile.height) + (profile.y - 1)
    }
    function getCurPeerInd() {return listView.currentIndex}
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

    function filterList(param) {
        for (var i = 0; i < usersModel.count; i = i+1) {
            var name = " " + usersModel.get(i).login + usersModel.get(i).famil
            if (name.toLowerCase().search(param) > 0 || param === "")
                usersModel.setProperty(i, "activity", 1)
            else
                usersModel.setProperty(i, "activity", 0)
        }
    }

    function getFriends() {
        var request = new XMLHttpRequest()
        request.open('POST', "http://www.hoppernet.hol.es")
        request.onreadystatechange =function() {
            if (request.readyState ==XMLHttpRequest.DONE) {
                if (request.status&&request.status ==200) {
                    getMePeers(loader.frienList=request.responseText)
                }
            }
        }
        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.send("READ=3&name="+loader.tel);
    }

    function getMePeers(name) {
        var request = new XMLHttpRequest(), obj,index
        request.open('POST', "http://www.hoppernet.hol.es")
        request.onreadystatechange =function() {
            if (request.readyState ==XMLHttpRequest.DONE) {
                if (request.status&&request.status ==200) {
                    try {
                    obj = JSON.parse(request.responseText);
                    } catch(e) {}
                    for (var i = 0; obj != null && i < obj.length; i+=1) {
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
                            if (obj[i].name ==loader.tel) {
                                listView.currentIndex = i
                            }
                        }else {
                            if (usersModel.get(index).image == "") {
                                usersModel.setProperty(index, "image", "http://lorempixel.com/200/20" + i + "/sports")
                            }
                            usersModel.setProperty(index,"famil",obj[i].famil)
                            usersModel.setProperty(index,"login",obj[i].login)
                            usersModel.setProperty(index, "port", obj[i].port)
                            usersModel.setProperty(index, "ip", obj[i].ip)
                        }
                    }
                    var friends = []
                    for (i = 0; i <usersModel.count; i++) {
                        friends.push({famil: usersModel.get(i).famil, login: usersModel.get(i).login, phone: usersModel.get(i).phone, port: usersModel.get(i).port, ip: usersModel.get(i).ip})
                    }
                    event_handler.saveSet("frd" , JSON.stringify(friends))
                }
            }
        }
        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.send("READ=2&name=" + name)
    }

    Rectangle {
        anchors.fill: parent
        color: loader.menu9Color;
        anchors.topMargin:profile.height
    }

    Rectangle {
        Rectangle {
            width: (parent.width)
            color: loader.isOnline?loader.menu2Color:loader.menu4Color
            height: 6
        }
        id: rightRect
        color: (loader.isOnline? loader.menu3Color: loader.menu3Color)
        width: (drawer.width - avatarButton.width)/2 + facade.toPx(13)
        anchors {
            top: profile.top
            right: parent.right
            bottom:profile.bottom
            topMargin: 1*profile.height/4
        }
    }
    Rectangle {
        id: leftRect;
        Rectangle {
            height: 6
            width: (parent.width)
            color: loader.isOnline?loader.menu2Color:loader.menu4Color
        }
        color: (loader.isOnline? loader.menu3Color: loader.menu3Color)
        width: (drawer.width - avatarButton.width)/2 + facade.toPx(14)
        anchors {
            top: profile.top
            bottom:profile.bottom
            topMargin: 3*profile.height/4-myRow.height
        }
    }
    Canvas {
        id: canva
        anchors {
            bottomMargin: -1
            top: (rightRect.top);
            left: leftRect.right;
            right: rightRect.left
            bottom:profile.bottom
        }
        Connections {
            target: loader;
            onIsOnlineChanged: {canva.requestPaint();}
        }
        onPaint: {
            var context =getContext("2d");
            context.reset()
            context.fillStyle=loader.isOnline == true? loader.menu3Color:loader.menu3Color
            context.moveTo(0,height - leftRect.height)
            context.lineTo(0,height)
            context.lineTo(width, height);
            context.lineTo(width, 0)
            context.closePath()
            context.fill();

            context.fillStyle=loader.isOnline == true? loader.menu2Color:loader.menu4Color
            context.beginPath()
            context.moveTo(0,height-leftRect.height+6)
            context.lineTo(0,height-leftRect.height+0)
            context.lineTo(width, 0)
            context.lineTo(width, 6)
            context.closePath()
            context.fill();
        }
    }

    Column {
        id: profile
        spacing:facade.toPx(10)
        anchors{
            horizontalCenter: parent.horizontalCenter;
        }
        Item{
            width: parent.width
            height: facade.toPx(10);
        }
        Row {
            id: firstRow
            anchors.horizontalCenter:parent.horizontalCenter
            spacing: {facade.toPx(30) - (facade.toPx(708) - drawer.width)/facade.toPx(10)}
            Column {
                anchors {
                    top: parent.top;
                    topMargin: facade.toPx(10)
                }
                Text {
                    color: "#FFFFFF"
                    font.bold: !false
                    styleColor:"black";
                    style: Text.Raised;
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(46);
                    text: usersModel.count > 0?usersModel.count-1: 0
                    anchors.horizontalCenter:parent.horizontalCenter
                }
                Text {
                    text:qsTr("Друзья")
                    color:qsTr("white")
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(24);
                    anchors.horizontalCenter:parent.horizontalCenter
                }
            }
            Button {
                id: avatarButton
                width: facade.toPx(225)
                height:facade.toPx(225)
                background: Rectangle {
                    radius: width * 0.5
                    color:"transparent"
                    border {
                      width: 1.4
                      color:"#50FFFFFF"
                    }
                }

                onClicked: {
                    drawer.close()
                    loader.avatar= true
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
                anchors {
                    bottom: parent.bottom
                    bottomMargin: facade.toPx(20)
                }
                Text {
                    text: "0"
                    color: "white"
                    font.bold: true
                    styleColor:"black";
                    style: Text.Raised;
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(46);
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

        Item{
            width: {(parent.width)}
            height: facade.toPx(30)
        }
    }

    ListView {
        clip:true
        id: listView
        spacing:-1
        property int memIndex:0
        anchors {
            topMargin: -1
            left: parent.left
            right: parent.right
            top: profile.bottom
            bottom:listMenu.top
            leftMargin: leftSlider.width
        }
        boundsBehavior: {(Flickable.StopAtBounds)}

        model:ListModel{id: usersModel;}
        snapMode: {ListView.SnapToItem;}
        Component.onCompleted:{
            if (loader.chats.length<1) {
                var mchat = event_handler.loadValue("chats")
                if (mchat!= "")
                    loader.chats=JSON.parse(mchat)
            }
            usersModel.clear();
        }

        delegate: Item {
            id: baseItem
            visible: activity
            width: parent.width
            height: {
                if (activity == 1)
                    facade.toPx(20) + Math.max(bug.height,fo.height)
                else 0
            }
            Row {
                Repeater {
                    anchors.verticalCenter:parent.verticalCenter
                    model: [("trashButton.png"), "dialerButton.png"]
                    Rectangle {
                        y: 1
                        width:baseItem.width/2
                        color: loader.menu5Color
                        height: baseItem.height- y*2;
                        Rectangle {
                            color: loader.menu6Color;
                            x: index*(parent.width -width)
                            width:parent.width/3
                            height:parent.height
                        }
                        Image {
                            x: {
                                var fac = -facade.toPx(30)
                                if (index!=0)fac+=parent.width-width
                                return Math.abs(fac);
                            }
                            anchors.verticalCenter: {
                                parent.verticalCenter
                            }
                            source: "qrc:/ui/buttons/" + (modelData)
                            width: {(facade.toPx(sourceSize.width))}
                            height: {facade.toPx(sourceSize.height)}
                            fillMode:Image.PreserveAspectFit
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
                        var json
                        partnerHeader.text = usersModel.get(index).login
                        partnerHeader.text+= " "
                        partnerHeader.text+= usersModel.get(index).famil
                        json = {ip:usersModel.get(index).ip,pt:usersModel.get(index).port}
                        partnerHeader.stat = (json.port == 0) == true? "Offline": "Online"
                        partnerHeader.phot = usersModel.get(index).image
                        if (index != -1) {listView.currentIndex = index}
                        var jstring=JSON.stringify(json)
                        console.log(jstring)
                        event_handler.sendMsgs(jstring);
                        if (loader.source != "qrc:/chat.qml") loader.goTo("qrc:/chat.qml")
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
                                informDialog.show("Хотите удалить <strong>" + login + " " + famil + "</strong> из друзей?", 2)
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
                    target: informDialog
                    onChooseChanged: {
                        if (listView.memIndex== index) {
                            if (informDialog.choose == false) {
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
                            var indx = 0, m = ""
                            if (typeof loader.chats[index] !== ('undefined'))
                                {indx = (loader.chats[index].message.length)}
                            if (indx >= 1) {
                                if (loader.chats[index].message[indx-1].flag)
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
        width: {facade.toPx(40)}
        anchors.topMargin: (-1);
        color: loader.menu4Color
        anchors.top: {profile.bottom}
        anchors.bottom: listMenu.top;
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


    HelperDrawer {id: helperDrawer}
    Rectangle {
        width: 6;
        color: {
            if (loader.isOnline==true) loader.menu2Color
            else loader.menu4Color;
        }
        anchors.left: parent.right;
        anchors {
            bottom: {parent.bottom}
            top: rightRect.top
        }
    }

    DropShadow {
        radius: 40
        samples: 40
        source: listMenu
        color: "#80000000";
        verticalOffset: -10
        anchors.fill: listMenu
    }
    ListView {
        clip: true
        id: listMenu
        width: parent.width
        snapMode:ListView.SnapOneItem
        property bool isShowed: false
        height: {
            var length= parent.height
            length -= facade.toPx(540) + getProfHeight()
            var count= Math.ceil(length/facade.toPx(80))
            if (count >navigateDownModel.count)
               count = navigateDownModel.count;
            if (count < 1) count = 1;
            (count)*facade.toPx(80)
        }
        anchors.bottom: parent.bottom
        boundsBehavior: Flickable.StopAtBounds;
        Component.onCompleted: currentIndex=-1;

        model:ListModel {
            id: navigateDownModel
            ListElement {image: ""; target: ""}
            ListElement {image: ""; target: ""}
            ListElement {
                image : "qrc:/ui/icons/devIconBlue.png";
                target: "Настройки"
            }
            ListElement {
                image : "qrc:/ui/icons/outIconBlue.png";
                target: "Выйти"
            }
        }
        delegate:Rectangle {
            width: parent.width;
            height: facade.toPx(80)
            color: ListView.isCurrentItem? ("#D3D3D3"): "#E5E5E5"
            MouseArea {
                id: menMouseArea
                anchors.fill:parent
                onEntered: if(index>0)listMenu.currentIndex=index
                onClicked: {
                    switch(index) {
                    case 2:
                        if (helperDrawer.position <=1) {
                            helperDrawer.open()
                        }
                        break;
                    case 3:
                        drawer.close()
                        event_handler.saveSet("user","")
                        loader.goTo("qrc:/loginanDregister.qml");
                        helperDrawer.visible((false))
                        loader.restores()
                    }
                    if (index == 1) {
                        myswitcher.checked = !myswitcher.checked;
                    } else if (index > 1 && index <=2) {
                        listMenu.currentIndex = index
                    }
                }
                onExited: listMenu.currentIndex = -1;
            }

            Rectangle {
                visible: (index == 0)
                color: loader.menu7Color;
                width: firstRow.width
                height: facade.toPx(50)
                radius: facade.toPx(25)
                anchors.verticalCenter: {(parent.verticalCenter)}
                anchors.horizontalCenter: parent.horizontalCenter

                Row {
                    spacing: {facade.toPx(10);}
                    anchors.left: {parent.left}
                    anchors.leftMargin: facade.toPx(20);
                    anchors.verticalCenter: parent.verticalCenter
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
                        onClicked: {
                            if(find == false) find=true;
                        }
                    }
                    Connections {
                        target: drawer;
                        onFindChanged:{
                            if (find) {
                                inerText.focus = (false)
                                inerText.clear();
                                filterList("");
                            }
                        }
                    }
                    TextField {
                        id: inerText
                        color: loader.menu15Color
                        height: (parent.parent.height)
                        rightPadding: parent.parent.radius;
                        onAccepted:filterList(text.toLowerCase())
                        width: parent.parent.width - inerImage.width - parent.spacing - facade.toPx(20);
                        placeholderText: "Найти друзей";
                        font.bold: true
                        font.pixelSize: facade.doPx(18);
                        font.family: trebu4etMsNorm.name
                        onActiveFocusChanged:find=false;
                        background: Rectangle{opacity:0}
                        verticalAlignment:Text.AlignVCenter
                        onTextChanged: {
                            if (event_handler.currentOSys() !== 1 && event_handler.currentOSys() !== 2){
                            filterList(text.toLowerCase());
                            }
                        }
                    }
                }
            }

            Row {
                spacing:facade.toPx(25)
                anchors {
                    fill: parent;
                    leftMargin: facade.toPx(20)
                }
                Image {
                    id: icon
                    source:image;
                    visible: index >= 2
                    width: {
                      facade.toPx(sourceSize.width* 1.5)
                    }
                    height:{
                      facade.toPx(sourceSize.height*1.5)
                    }
                    anchors.verticalCenter: {
                        parent.verticalCenter
                    }
                }
                Connections {
                    target: loader
                    onIsOnlineChanged: {
                      myswitcher.checked=loader.isOnline
                    }
                }
                Switch {
                    id: myswitcher
                    visible: index == 1
                    indicator: Rectangle {
                        radius: facade.toPx(25)
                        y: (parent.height/2 - height/2);
                        implicitWidth: (facade.toPx(60))
                        implicitHeight:(facade.toPx(30))
                        color: {
                            if (parent.checked  == true)
                                loader.menu12Color
                            else loader.menu13Color
                        }
                        Rectangle {
                            color:"#76CCCCCC"
                            x: {
                                if(myswitcher.checked) {
                                    parent.width - width - (parent.height - height)/2
                                } else (parent.height - height)/2
                            }
                            anchors {
                                verticalCenter: {
                                   parent.verticalCenter
                                }
                            }
                            width: (myswitcher.height/2)
                            height:(myswitcher.height/2)
                            radius: {width/2}
                        }
                        Rectangle {
                            radius: {width/2}
                            x: {
                                if(myswitcher.checked) {
                                    parent.width - width - (parent.height - height)/2
                                } else (parent.height - height)/2
                            }
                            color:loader.feedColor;
                            anchors.verticalCenter: parent.verticalCenter
                            width: myswitcher.height/2.3
                            height:myswitcher.height/2.3
                        }
                    }
                    onCheckedChanged: {
                        loader.isOnline = checked;
                    }
                    anchors.verticalCenter: {
                        parent.verticalCenter
                    }
                    width: {facade.toPx(64);}
                    height: {facade.toPx(80)}
                }
                Text {
                    width: {
                        var par3 = icon.width
                        var par1 = ((parent.width))
                        var par2 = facade.toPx(40);
                        return (par1 - par3 - par2)
                    }
                    anchors.verticalCenter: {
                        parent.verticalCenter
                    }
                    font.pixelSize: facade.doPx(20)
                    font.family:trebu4etMsNorm.name
                    elide: {Text.ElideRight;}
                    color: loader.menu10Color
                    text: {
                        if (index == 1) {
                            if (myswitcher.checked)
                                "В сети"
                            else "Невидимый";
                        } else target
                    }
                }
            }
        }
    }
}
