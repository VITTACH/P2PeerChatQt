import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Drawer {
    id: drawer
    clip: true
    property bool find: true
    height: {parent.height;}
    width: Math.min(facade.toPx(708), 0.85 * parent.width);
    background: Rectangle {color: "transparent";}

    function getPeersCount() {
        return listView.count;
    }
    function getProfHeight() {
        return profile.height + facade.toPx(25);
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

    Connections {
        target: drawer;
        onPositionChanged: {
            if (loader.source != "qrc:/chat.qml")
                position = 0
            else if (position == 1) {
                settingDrawer.visible(true);
                getMePeers()
            }
            else if (position == 0) {
                settingDrawer.visible(false)
            }
            else if (position <= 1) {
                settingDrawer.close()
            }
        }
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

    function getMePeers() {
        var request = new XMLHttpRequest(), obj,index
        request.open('POST',"http://www.hoppernet.hol.es")
        request.onreadystatechange =function() {
            if (request.readyState==XMLHttpRequest.DONE) {
                if (request.status&&request.status==200) {
                    obj = JSON.parse(request.responseText)
                    for (var i = 0; i < obj.length; i++) {
                        if (obj[i].name===loader.tel) continue
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
                        }else {
                            usersModel.setProperty(index, "port", obj[i].port)
                            usersModel.setProperty(index, "ip", obj[i].ip)
                        }
                    }
                }
            }
        }
        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.send("READ=2")
    }

    LinearGradient {
        anchors.fill: parent
        start:Qt.point(0, 0)
        end:Qt.point(parent.width, 0)
        gradient: Gradient {
            GradientStop {
                position: 0.9; color: "#FEBCBCBC"
            }
            GradientStop {
                position: 1.0; color: "#CEFFFFFF"
            }
        }

        Rectangle {
            id: glass
            color: "#AA395F86";
            width: parent.width
            anchors {
                top:profile.top
                bottom:profile.bottom
            }
        }
        Rectangle {
            height: 1
            color: "#FFFFC129";
            width: parent.width
            anchors.top: {glass.top;}
        }

        Column {
            id: profile
            y: facade.toPx(25)
            spacing: facade.toPx(10);
            anchors{
                horizontalCenter:parent.horizontalCenter
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
                    anchors.verticalCenter: parent.verticalCenter;
                    Text {
                        color: "white"
                        font.bold: true
                        styleColor:"black";
                        style: Text.Raised;
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(46);
                        text: {usersModel.count;}
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

                    OpacityMask {
                        source: bag
                        maskSource: misk
                        anchors.fill:bag
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
                    anchors.verticalCenter: parent.verticalCenter;
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

        Rectangle {
            clip: true
            width: parent.width
            color:"transparent"
            anchors {
                topMargin: 2
                bottomMargin: 1
                top: profile.bottom
                bottom:listMenu.top
            }
            ListView {
                spacing: 2
                id: listView
                anchors.fill:parent
                anchors.leftMargin: {facade.toPx(40);}

                Component.onCompleted:{
                    usersModel.clear();
                }

                model:  ListModel {
                    id: usersModel;
                        ListElement {
                            activity: 1
                            image: ""
                            famil: ""
                            login: ""
                            phone: ""
                            port: ""
                            ip: ""
                        }
                    }
                delegate: Rectangle {
                    visible: activity
                    width: parent.width
                    color: myMouseArea.pressed? "lightgray": (ListView.isCurrentItem? "#4F81B6":"#FFFFFFFF")
                    height: activity == 1? facade.toPx(20) + Math.max(bug.height, fo.height):0

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
                        }
                    }

                    OpacityMask {
                        source: bug
                        maskSource: mask
                        anchors.fill:bug
                    }

                    Rectangle {
                        id: bug
                        clip: true
                        smooth: true
                        visible: false
                        x: facade.toPx(50) - (facade.toPx(708) - drawer.width)/facade.toPx(5);
                        width: facade.toPx(100)
                        height:facade.toPx(100)
                        anchors.verticalCenter: parent.verticalCenter
                        Image {
                            source: image
                            anchors.centerIn: parent
                            height:sourceSize.width>sourceSize.height? parent.height: sourceSize.height*(parent.width/sourceSize.width);
                            width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height/sourceSize.height): parent.width;
                        }
                    }

                    Image {
                        id: mask
                        smooth: true;
                        visible:false
                        source:"qrc:/ui/mask/round.png"
                        sourceSize: {Qt.size(bug.width, bug.height);}
                    }

                    Column {
                        id: fo
                        width: parent.width
                        anchors {
                            left: bug.right
                            leftMargin: facade.toPx(20)
                        }
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            lineHeight: 1.3
                            text: login+" "+famil;
                            elide: Text.ElideRight
                            font.family:trebu4etMsNorm.name
                            font.pixelSize: facade.doPx(24)
                            width:fo.width-facade.toPx(100)-bug.width
                            color:listView.currentIndex ==index? "white": "#10387F"
                        }
                        Text {
                            text:phone.substring(0,1)+"("+phone.substring(1,4)+")-"+phone.substring(4,7)+"-"+phone.substring(7)+": "+port
                            elide: Text.ElideRight
                            font.family:trebu4etMsNorm.name
                            font.pixelSize: facade.doPx(24)
                            width:fo.width-facade.toPx(100)-bug.width
                            color:listView.currentIndex ==index? "white": "#10387F"
                        }
                    }
                }
            }
        }

        ListView {
            id: listMenu
            width: parent.width
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
                color: ListView.isCurrentItem? "lightgrey": "#F2F2F2"
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
                            usersModel.clear()
                            settingDrawer.visible(false)
                            event_handler.saveSet("phone", "")
                            event_handler.saveSet("passw", "")
                            loader.restores()
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
                    color: "#80225895"
                    visible: index==0;
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
                                if(find) {inerText.clear(); filterList("");}
                            }
                        }
                        TextField {
                            id: inerText
                            color: "#90FFFFFF"
                            height:parent.parent.height
                            width: parent.parent.width - inerImage.width - parent.spacing - facade.toPx(20);

                            placeholderText: "Найти друзей";
                            onAccepted:filterList(text.toLowerCase())
                            rightPadding: parent.parent.radius
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
                        leftMargin: facade.toPx(20)
                    }
                    Image {
                        id: icon
                        visible: index >= 2
                        source:image;
                        width: facade.toPx(sourceSize.width *1.5)
                        height:facade.toPx(sourceSize.height*1.5)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Switch {
                        id: myswitcher
                        checked: true;
                        visible: index == 1
                        width: facade.toPx(64)
                        height:facade.toPx(80)
                        anchors.verticalCenter: parent.verticalCenter

                        indicator: Rectangle {
                            radius:facade.toPx(25)
                            y: parent.height/2 - height/2;
                            implicitWidth: facade.toPx(60)
                            implicitHeight:facade.toPx(30)
                            color: parent.checked==true? "#C5D9FB": "#B1B1B1"

                            Rectangle {
                                x: parent.parent.checked? parent.width - width - (parent.height - height)/2: (parent.height - height)/2;
                                anchors.verticalCenter: parent.verticalCenter
                                width: myswitcher.height/2
                                height:myswitcher.height/2
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
                        width:parent.width-icon.width-facade.toPx(40)
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#FF51587F"
                        elide: Text.ElideRight;
                        font.family: {trebu4etMsNorm.name}
                        font.pixelSize: {facade.doPx(20);}
                    }
                }
            }
        }
    }
}
