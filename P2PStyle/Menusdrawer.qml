import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Drawer {
    id: drawer
    clip: true

    Connections {
        target: drawer;
        onPositionChanged: {
            if (loader.isLogin!=true) {
                position = 0
            } else if (position == 1) {
                settingDrawer.visible(true)
                if (loader.frienList == "") {
                    var friend
                    friend = event_handler.loadValue("frd")
                    if (friend != "") {
                        var myfriend = (JSON.parse(friend))
                        for(var i=0; i<myfriend.length;i++)
                            usersModel.append({image:"", famil: myfriend[i].famil, login: myfriend[i].login, phone: myfriend[i].phone, port: myfriend[i].port, ip: myfriend[i].ip,activity:1})
                    }
                    loader.frienList="[\"\"]"
                }
                getMePeers(loader.frienList);
            } else if (position == 0) {
                settingDrawer.visible(false);
                loader.focus = !false
                find = true;
            }
        }
    }

    Connections {
        target: loader
        onIsOnlineChanged: if(loader.isOnline) getFriends()
    }

    property bool find: true
    property alias cindex: listView.currentIndex;
    background: Rectangle {color: "transparent";}
    height: {parent.height;}
    width: Math.min(facade.toPx(738), 0.85 * parent.width);

    function getPeersCount() {
        return listView.count;
    }
    function getProfHeight() {
        return (profile.height) + facade.toPx(25)
    }
    function getMenuHeight() {
        return listMenu.height + getProfHeight();
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

    function findPeer(phone)
    {
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
        request.open('POST',"http://www.hoppernet.hol.es")
        request.onreadystatechange =function() {
            if (request.readyState==XMLHttpRequest.DONE) {
                if (request.status&&request.status==200) {
                    getMePeers(loader.frienList=request.responseText)
                }
            }
        }
        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.send("READ=3&name="+loader.tel);
    }

    function getMePeers(name) {
        var request = new XMLHttpRequest(), obj,index
        request.open('POST',"http://www.hoppernet.hol.es")
        request.onreadystatechange =function() {
            if (request.readyState==XMLHttpRequest.DONE) {
                if (request.status&&request.status==200) {
                    obj = JSON.parse(request.responseText)
                    for (var i = 0; i < obj.length; i++) {
                        index = findPeer(obj[i].name)
                        if (usersModel.count<1||index<0) {
                            loader.chats.push({phone:obj[i].name, message:[]})
                            usersModel.append({
                                image: "http://lorempixel.com/200/20" + i + "/sports",
                                famil: obj[i].family,
                                login: obj[i].login,
                                phone: obj[i].name,
                                port: obj[i].port,
                                ip: obj[i].ip,
                                activity: 1
                            });
                            if (obj[i].name == loader.tel)
                                listView.currentIndex=i
                        }else {
                            if (usersModel.get(index).image == "") {
                                usersModel.setProperty(index, "image", "http://lorempixel.com/200/20" + i + "/sports")
                            }
                            usersModel.setProperty(index, "port", obj[i].port)
                            usersModel.setProperty(index, "ip", obj[i].ip)
                        }
                    }
                    var friends = []
                    for (i = 0; i<usersModel.count; i++) {
                        friends.push({famil: usersModel.get(i).famil, login: usersModel.get(i).login, phone: usersModel.get(i).phone, port: usersModel.get(i).port, ip: usersModel.get(i).ip})
                    }
                    event_handler.saveSet("frd" , JSON.stringify(friends))
                }
            }
        }
        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.send("READ=2&name=" + name)
    }

    function updateFriends() {
        var request = new XMLHttpRequest()
        request.open('POST',"http://www.hoppernet.hol.es")
        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.send("name=" + loader.tel + "&friend=" + loader.frienList)
    }

    LinearGradient {
        anchors.fill: parent
        start:Qt.point(0, 0)
        end:Qt.point(parent.width, 0)
        gradient: Gradient {
            GradientStop {
                position: 1.0; color: "#FEE5E5E5"
            }
            /*
            GradientStop {
                position: 1.0; color: "#CEFFFFFF"
            }
            */
        }

        Rectangle {
            id: glass
            color: "#FF6F7584";
            width: parent.width
            anchors {
                top:profile.top
                bottom:profile.bottom
            }
        }
        Rectangle {
            height: 4
            color: "#FFFFC129";
            width: parent.width
            anchors.top: {glass.top;}
        }

        Rectangle {
            id: rightRect
            color: (loader.isOnline? "#95A1AB": "#95A1AB")
            width: (drawer.width-avatarButton.width)/2 + facade.toPx(14)
            anchors {
                top: profile.top
                right: parent.right
                bottom: profile.bottom
                topMargin: 1*profile.height/4
            }
            Rectangle {
                height: 3
                width: parent.width
            }
        }
        Rectangle {
            id: leftRect;
            color: (loader.isOnline? "#95A1AB": "#95A1AB")
            width: (drawer.width-avatarButton.width)/2 + facade.toPx(15)
            anchors {
                top: profile.top
                bottom: profile.bottom
                topMargin: 3*profile.height/4-myRow.height
            }
            Rectangle {
                height: 3
                width: parent.width
            }
        }
        Canvas {
            id: canva
            anchors {
                top: rightRect.top
                left: leftRect.right
                right: rightRect.left
                bottom:profile.bottom
            }
            Connections {
                target: loader
                onIsOnlineChanged: {canva.requestPaint();}
            }
            onPaint: {
                var context = getContext("2d")
                context.reset();
                context.fillStyle=loader.isOnline? "#95A1AB": "#95A1AB"
                context.moveTo(0,height - leftRect.height)
                context.lineTo(0,height)
                context.lineTo(width, height);
                context.lineTo(width, 0)
                context.closePath();
                context.fill();
            }
        }

        Column {
            id: profile
            y: facade.toPx(25)
            spacing: facade.toPx(10);
            anchors{
                horizontalCenter: parent.horizontalCenter;
            }
            Item{
                width: {parent.width}
                height:facade.toPx(10)
            }
            Row {
                id: firstRow
                anchors.horizontalCenter: parent.horizontalCenter;
                spacing: {facade.toPx(30) - (facade.toPx(708) - drawer.width)/facade.toPx(10)}
                Column {
                    anchors {
                        top: parent.top
                        topMargin: facade.toPx(10)
                    }
                    Text {
                        color: "white"
                        font.bold: true
                        styleColor:"black";
                        style: Text.Raised;
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(46);
                        text: usersModel.count > 0?usersModel.count-1: 0
                        anchors.horizontalCenter:parent.horizontalCenter
                    }
                    Text {
                        text: "Друзья"
                        color: "white"
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
                          width: 1.2
                          color:"#FFFFFFFF"
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
                        width: {parent.width - facade.toPx(45.0);}
                        height: {parent.height - facade.toPx(45);}
                        anchors {
                            verticalCenter: parent.verticalCenter;
                            horizontalCenter: (parent.horizontalCenter);
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
                        sourceSize: Qt.size(bag.width,bag.height);
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
                width:firstRow.width
                Text {
                    text:loader.login+" "+loader.famil
                    color: "white"
                    font.bold: true
                    font.family: {trebu4etMsNorm.name}
                    font.pixelSize: {facade.doPx(28);}
                    elide: Text.ElideRight
                    width: parent.width-scope1.implicitWidth-scope2.implicitWidth-image1.width
                }
                anchors.horizontalCenter: {
                    parent.horizontalCenter
                }
                Text {
                    id: scope1
                    text: " ( "
                    color: "#FFFFFF"
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
                    text: " 0 )"
                    color: "#FFFFFF"
                    font.family: {trebu4etMsNorm.name}
                    font.pixelSize: {facade.doPx(28);}
                }
            }

            Item{
                width: {parent.width}
                height: facade.toPx(10)
            }
        }

        ListView {
            id: listView
            clip:true
            anchors {
                left: parent.left
                right: parent.right
                top: profile.bottom
                bottom:listMenu.top
                leftMargin: leftSlider.width
            }
            spacing: facade.toPx(8)
            boundsBehavior: {(Flickable.StopAtBounds)}

            snapMode: {ListView.SnapToItem;}
            Component.onCompleted: usersModel.clear();

            model:ListModel{id: usersModel;}
            delegate: Item {
                id: baseItem
                visible: activity
                width: parent.width
                height: activity==1? facade.toPx(20)+Math.max(bug.height,fo.height):0

                Rectangle {
                    color: "#FF8B0000"
                    width: (0.7*parent.height);
                    height:(parent.height - 4);
                    Image {
                        anchors.centerIn:parent
                        width: facade.toPx(sourceSize.width)
                        height: facade.toPx(sourceSize.height)
                        source: "qrc:/ui/buttons/trashButton.png"
                    }
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    color: "#FF006400"
                    width: (0.7*parent.height);
                    height:(parent.height - 4);
                    anchors.right: parent.right
                    Image {
                        anchors.centerIn:parent
                        width: facade.toPx(sourceSize.width);
                        height:facade.toPx(sourceSize.height)
                        source:"qrc:/ui/buttons/dialerButton.png"
                    }
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    clip: true
                    id: delegaRect
                    width: parent.width
                    height: parent.height
                    color: baseItem.ListView.isCurrentItem? (loader.isOnline? "#455869": "#999999"): ("white")

                    Rectangle {
                        width: 0
                        height: 0
                        id: coloresRect
                        color:baseItem.ListView.isCurrentItem?(loader.isOnline?"#A9A9A9":"darkgray"):"#E5E5E5"

                        transform: Translate {
                            x:-coloresRect.width /2
                            y:-coloresRect.height/2
                        }
                    }

                    PropertyAnimation {
                        duration: 500
                        target: coloresRect;
                        id: circleAnimation;
                        properties:("width, height, radius")
                        from: 0
                        to: (delegaRect.width * 3)

                        onStopped: {
                            coloresRect.width = 0;
                            coloresRect.height= 0;
                        }
                    }

                    MouseArea {
                        id: myMouseArea
                        anchors.fill:parent
                        onClicked: {
                            var json
                            partnerHeader.text = usersModel.get(index).login+" "+usersModel.get(index).famil
                            json = {ip:usersModel.get(index).ip,pt:usersModel.get(index).port}
                            partnerHeader.stat = (json.port == 0) == true? "Offline": "Online"
                            partnerHeader.phot = usersModel.get(index).image
                            if (index!=-1) listView.currentIndex = index
                            event_handler.sendMsgs(JSON.stringify(json))
                            if (loader.source != "qrc:/chat.qml") {
                                loader.goTo("qrc:/chat.qml")
                            }
                            drawer.close();
                        }
                        drag.target: parent
                        drag.axis: Drag.XAxis
                        drag.minimumX: -height*0.7;
                        drag.maximumX: {
                            if (usersModel.count>=index+1) {
                                if (usersModel.get(index).phone != loader.tel) {
                                    -drag.minimumX;
                                } else 0
                            }
                        }
                        onExited: {
                            circleAnimation.stop();
                        }
                        onEntered: {
                            coloresRect.x = mouseX;
                            coloresRect.y = mouseY;
                            circleAnimation.start()
                        }
                        onReleased: {
                            if (parent.x >= drag.maximumX) {
                                if (usersModel.get(index).phone != loader.tel) {
                                    var friendPhone=usersModel.get(index).phone;
                                    var obj = JSON.parse(loader.frienList)
                                    for (var i = 0; i<obj.length; i++) {
                                        var friend = obj[i].replace('"', '')
                                        if (friend === friendPhone) {
                                            obj.splice(i, 1)
                                            loader.frienList=JSON.stringify(obj)
                                            updateFriends();
                                            break;
                                        }
                                    }
                                    usersModel.remove(index)
                                }
                            }
                            if (parent.x <= drag.minimumX) {
                                if (event_handler.currentOSys() != 1)
                                    Qt.openUrlExternally("tel:" + phone)
                                else
                                    caller.directCall(phone)
                            }
                            parent.x=0
                        }
                    }

                    DropShadow {
                        radius: 15
                        samples: 15
                        source: bug
                        color:"#90000000"
                        anchors.fill:bug;
                    }
                    /*
                    OpacityMask {
                        id: beg
                        source: bug
                        maskSource: mask;
                        anchors.fill:bug;
                    }
                    Image {
                        id: mask
                        smooth: true;
                        visible:false
                        source:"qrc:/ui/mask/round.png"
                        sourceSize: {Qt.size(bug.width, bug.height);}
                    }*/

                    Rectangle {
                        id: bug
                        clip: true
                        smooth: true
                        visible: false
                        x: facade.toPx(50) - (facade.toPx(708) - drawer.width)/facade.toPx(5);
                        width: facade.toPx(120)
                        height:facade.toPx(120)
                        anchors.verticalCenter: parent.verticalCenter
                        Image {
                            source: image
                            anchors.centerIn: parent
                            height:sourceSize.width>sourceSize.height? parent.height: sourceSize.height*(parent.width/sourceSize.width);
                            width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height/sourceSize.height): parent.width;
                        }
                    }

                    Column {
                        id: fo
                        width: parent.width
                        anchors {
                            left: (bug.right)
                            leftMargin: facade.toPx(40)
                        }
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            lineHeight: (1.3)
                            elide: Text.ElideRight
                            text: (login + " " + famil)
                            font.bold: true
                            font.family:trebu4etMsNorm.name
                            font.pixelSize: facade.doPx(26)
                            width:fo.width-facade.toPx(100)-bug.width
                            color:listView.currentIndex ==index? "white":"#10387F"
                        }
                        Text {
                            text:phone.substring(0,1)+"("+phone.substring(1,4)+")-"+phone.substring(4,7)+"-"+phone.substring(7)+":"+port
                            elide: Text.ElideRight
                            font.family:trebu4etMsNorm.name
                            font.pixelSize: facade.doPx(20)
                            width:fo.width-facade.toPx(100)-bug.width
                            color:listView.currentIndex ==index? "white":"#10387F"
                        }
                        Text {
                            text: "Статус: offline с 13:45"
                            elide: Text.ElideRight
                            font.family:trebu4etMsNorm.name
                            font.pixelSize: facade.doPx(16)
                            width:fo.width-facade.toPx(100)-bug.width
                            color:listView.currentIndex ==index? "white":"#10387F"
                        }
                    }
                }
            }
        }

        Rectangle {
            id: leftSlider
            width: facade.toPx(40)
            anchors.top: {profile.bottom}
            anchors.bottom: listMenu.top;
            color: loader.isOnline? "#FF455869": "#999999"
            x: settingDrawer.position==0?0: settingDrawer.x+settingDrawer.width-1;
            MouseArea {
                property int p
                anchors.fill: parent
                onPressed: p=mouse.x
                onPositionChanged: {
                    if (mouse.x > p)
                    settingDrawer.open();
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
                spacing: facade.toPx(6);
                height: 0.3*parent.height
                anchors.centerIn: parent;
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
            radius: 40
            samples: 40
            source: listMenu
            color: "#80000000"
            verticalOffset: -10
            anchors {
                fill: listMenu;
            }
        }
        ListView {
            clip: true
            id: listMenu
            width: parent.width
            snapMode:ListView.SnapOneItem
            property bool isShowed: false
            height: {
                var length = (parent.height - getProfHeight() - facade.toPx(540));
                var count = Math.ceil(length / facade.toPx(80))
                if (count >navigateDownModel.count)
                   count = navigateDownModel.count;
                if (count < 1) count = 1;
                (count)*facade.toPx(80)
            }
            anchors.bottom: parent.bottom
            boundsBehavior: Flickable.StopAtBounds;

            Component.onCompleted: currentIndex=-1;

            model:  ListModel {
                    id: navigateDownModel
                    ListElement{image:"";target:""}
                    ListElement{image:"";target:""}
                    ListElement{
                        image: "qrc:/ui/icons/DevsIconBlue.png"
                        target: qsTr("Настройки")
                    }
                    ListElement{
                        image: "qrc:/ui/icons/doorIconBlue.png"
                        target: qsTr("Выйти")
                    }
                }
            delegate: Rectangle{
                width: parent.width
                height: facade.toPx(80)
                color: ListView.isCurrentItem? "lightgrey": "#E5E5E5"
                MouseArea {
                    id:menMouseArea
                    anchors.fill:parent
                    onExited: {listMenu.currentIndex=-1}
                    onEntered: {
                        if (index > 0) listMenu.currentIndex = index;
                    }

                    onClicked: {
                        settingDrawer.close()
                        switch(index) {
                        case 2:
                            if(settingDrawer.position<1)
                            settingDrawer.open()
                            break;
                        case 3:
                            drawer.close()
                            loader.restores()
                            settingDrawer.visible(false)
                            event_handler.saveSet("phone", "")
                            event_handler.saveSet("passw", "")
                            loader.goTo("qrc:/loginanDregister.qml");
                        }
                        if (index == 1)
                            myswitcher.checked = !myswitcher.checked;
                        else if (index > 1) {
                            if (index<=2)listMenu.currentIndex=index;
                        }
                    }
                }

                Rectangle {
                    visible: index==0;
                    color: "#80225895"
                    width: firstRow.width
                    height: facade.toPx(50)
                    radius: facade.toPx(25)
                    anchors {
                        verticalCenter: parent.verticalCenter;
                        horizontalCenter: parent.horizontalCenter
                    }

                    Row {
                        spacing:facade.toPx(10)
                        anchors {
                            left: {parent.left}
                            leftMargin: facade.toPx(20);
                            verticalCenter: parent.verticalCenter
                        }
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
                                source: "qrc:/ui/icons/"+(find? "searchIconWhite": "closedIconWhite")+".png"
                            }
                            onClicked: {
                                if(find == false) find=true;
                            }
                        }
                        Connections {
                            target: drawer
                            onFindChanged: {
                                if(find) {
                                    inerText.focus = (false)
                                    inerText.clear(); filterList("");
                                }
                            }
                        }
                        TextField {
                            id: inerText
                            color: "#90FFFFFF"
                            height:parent.parent.height
                            width: parent.parent.width - inerImage.width - parent.spacing - facade.toPx(20);

                            rightPadding: {parent.parent.radius;}
                            onAccepted:filterList(text.toLowerCase())
                            onTextChanged:if(event_handler.currentOSys()!=1&&event_handler.currentOSys()!=2) filterList(text.toLowerCase())
                            placeholderText: "Найти друзей";
                            font.bold: true
                            font.pixelSize: facade.doPx(20);
                            font.family: trebu4etMsNorm.name
                            onActiveFocusChanged:find=false;
                            background: Rectangle{opacity:0}
                        }
                    }
                }

                Row {
                    spacing:facade.toPx(25)
                    anchors {
                        fill: parent;
                        leftMargin:facade.toPx(20)
                    }
                    Image {
                        id: icon
                        visible: index >= 2
                        source:image;
                        width: {facade.toPx(sourceSize.width * 1.5);}
                        height:{facade.toPx(sourceSize.height * 1.5)}
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Switch {
                        id: myswitcher
                        checked: {loader.isOnline}
                        visible: index == 1
                        width: facade.toPx(64)
                        height:facade.toPx(80)
                        anchors.verticalCenter: parent.verticalCenter
                        onCheckedChanged: {loader.isOnline = checked}
                        indicator: Rectangle {
                            radius:facade.toPx(25)
                            y: (parent.height/2 - height/2);
                            implicitWidth: (facade.toPx(60))
                            implicitHeight:(facade.toPx(30))
                            color: parent.checked==true? "#C5D9FB": "#B1B1B1"

                            Rectangle {
                                x: parent.parent.checked? parent.width - width - (parent.height - height)/2: (parent.height - height)/2;
                                anchors.verticalCenter: parent.verticalCenter
                                width: (myswitcher.height/2)
                                height:(myswitcher.height/2)
                                radius:width/2
                                color: "#76CCCCCC"
                            }
                            Rectangle {
                                radius:width/2
                                x: parent.parent.checked? parent.width - width - (parent.height - height)/2: (parent.height - height)/2;
                                color: myswitcher.down? "#004A7F": (myswitcher.checked? "#4182EF":"#ECECEC")
                                anchors.verticalCenter: parent.verticalCenter
                                width: myswitcher.height/2.3
                                height:myswitcher.height/2.3
                            }
                        }
                    }
                    Text {
                        text: index == 1? (myswitcher.checked == true? "В сети": qsTr("Невидимый")): target;
                        width: {parent.width - icon.width - facade.toPx(40);}
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#FF51587F"
                        elide: Text.ElideRight
                        font.family: {(trebu4etMsNorm.name)}
                        font.pixelSize: {(facade.doPx(20));}
                    }
                }
            }
        }
    }
    Settingdrawei {id:settingDrawer}
}
