import QtQuick 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import QtQuick.XmlListModel 2.0

Rectangle {
    id: rootPage;
    color: "#FFEDEDED";
    property bool find:true

    property var nWidth;
    property int curInd: 0;
    property int oldContentY: 0
    property int newsCardHgt: 0

    Component.onCompleted: {
        basicMenuDrawer.open();
    }

    ListView {
        id: basView
        width: parent.width
        spacing:facade.toPx(40)
        anchors {
            top: parent.top
            bottom: downRow.top
            topMargin: facade.toPx(40)
        }

        model : ListModel {
            id: feedsModel;
            ListElement {activiti: 0;}
            ListElement {activiti: 1;}
            ListElement {activiti: 0;}
        }

        delegate: Column {
            anchors.horizontalCenter:parent.horizontalCenter
            width: nWidth = Math.min(0.9*parent.width, facade.toPx(900))
            Component.onCompleted: {
                getMePeers();
                var rssNews = event_handler.loadValue("rss")
                if (rssNews != "") {
                    var rssOld = JSON.parse(rssNews);
                    for (var i =0; i < rssOld.length; i++) {
                        rssmodel.append({title: rssOld[i].title, image: rssOld[i].image, pDate: rssOld[i].pDate, pDesc: rssOld[i].pDesc, link: rssOld[i].link, enable: true})
                    }
                }
            }

            function findPeer(phone) {
                for (var i = 0; i < humanModel.count; i++) {
                    if (humanModel.get(i).phone === phone) {
                        return i;
                    }
                }
                return -1;
            }

            function filterList(param) {
                getMePeers()
                var succesFind = false
                for (var i = 0; i < humanModel.count; i ++) {
                    var name = " " + humanModel.get(i).login + humanModel.get(i).famil
                    if (name.toLowerCase().search(param)>0) {
                    humanModel.setProperty(i, "activity", 1);
                    if (!succesFind) listView.currentIndex=i;
                    succesFind = true
                    }
                    else {
                    humanModel.setProperty(i, "activity", 0);
                    }
                }
                if (succesFind == true)
                    feedsModel.setProperty(0, "activiti", 1);
                else
                    feedsModel.setProperty(0, "activiti", 0);
                listView.positionViewAtBeginning()
            }

            function getMePeers() {
                var request = new XMLHttpRequest(), obj,index
                request.open('POST',"http://www.hoppernet.hol.es")
                request.onreadystatechange =function() {
                    if (request.readyState==XMLHttpRequest.DONE) {
                        if (request.status&&request.status==200) {
                            obj = JSON.parse(request.responseText)
                            for (var i = 0; i < obj.length; i++) {
                                index = findPeer(obj[i].name)
                                if (humanModel.count<1||index<0) {
                                    loader.chats.push({phone:obj[i].name, message:[]})
                                    humanModel.append({
                                        image: "http://lorempixel.com/200/20" + i + "/sports",
                                        famil: obj[i].family,
                                        login: obj[i].login,
                                        phone: obj[i].name,
                                        port: obj[i].port,
                                        ip: obj[i].ip,
                                        activity: 0
                                    });
                                }else {
                                    humanModel.setProperty(index, "port", obj[i].port)
                                    humanModel.setProperty(index, "ip", obj[i].ip)
                                }
                            }
                        }
                    }
                }
                request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                request.send("READ=4")
            }

            Rectangle {
                radius: height/2;
                visible: index == 0;
                width: parent.width;
                height: visible? (finderRow.height + facade.toPx(20)): 0
                Row {
                    id: finderRow
                    spacing: {facade.toPx(10);}
                    anchors {
                        left: parent.left
                        leftMargin: facade.toPx(30);
                        verticalCenter: parent.verticalCenter
                    }

                    Button {
                        id:inerImage
                        width: facade.toPx(40);
                        height:facade.toPx(innerImage.sourceSize.height)
                        anchors.verticalCenter: {parent.verticalCenter;}
                        onClicked: {
                            if(find == false) find=true;
                            if(find) {inerText.clear(); filterList("");}
                        }
                        background:Image {
                            id: innerImage
                            width: {facade.toPx(sourceSize.width /1.3);}
                            height:{facade.toPx(sourceSize.height/1.3);}
                            anchors.verticalCenter:parent.verticalCenter
                            source: "qrc:/ui/icons/" + (find? "searchIconWhite": "closedIconWhite") + ".png"
                        }
                    }
                    Connections {
                        target: basicMenuDrawer
                        onPositionChanged: if((basicMenuDrawer.position == 1) == true) {inerText.focus = (false)}
                    }
                    TextField {
                        id: inerText
                        color: "#C0C8D0"
                        width: parent.parent.width - inerImage.width - (parent.spacing) - (facade.toPx(30));

                        rightPadding: parent.parent.radius;
                        onAccepted: filterList(text.toLowerCase())
                        onTextChanged: if (event_handler.currentOSys()!=1 && event_handler.currentOSys()!=2) filterList(text.toLowerCase());
                        placeholderText: "Найти друзей";
                        font.bold: true;
                        font.pixelSize: facade.doPx(20);
                        font.family: trebu4etMsNorm.name
                        onActiveFocusChanged:find=false;
                        background: Rectangle{opacity:0}
                    }
                }
            }

            Rectangle {
                clip: true
                width: parent.width
                color: "transparent";
                property int counter;
                height: {
                    var cunter = 0;
                    for (var i = 0; i < listView.count; i ++) {
                        if (humanModel.get(i).activity == 1 && visible) {
                            cunter++;
                        }
                    }
                    if (cunter > 4) {
                        cunter = 4;
                    }
                    counter=cunter;
                    cunter*facade.toPx(124)
                }
                visible: index==0&&activiti
                ListView {
                    id: listView
                    anchors.fill:parent
                    spacing: parent.counter>1?facade.toPx(10):0
                    snapMode: {ListView.SnapToItem;}
                    boundsBehavior: {(Flickable.StopAtBounds);}

                    property var friend

                    model:ListModel{id: humanModel;}
                    delegate: Item {
                        id: baseItem
                        visible: activity
                        width: parent.width
                        height: activity==1? facade.toPx(20)+Math.max(bug.height,fo.height):0

                        Rectangle {
                            color: loader.menu5Color
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                anchors.top: parent.top;
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.rightMargin: facade.toPx(30)
                                fillMode: {Image.PreserveAspectFit;}
                                width: facade.toPx(sourceSize.width)
                                height: {facade.toPx(sourceSize.height);}
                                source:"qrc:/ui/buttons/dialerButton.png"
                            }
                            width: 0.5*parent.width;
                            height: parent.height-4;
                        }

                        Rectangle {
                            clip: true
                            id: delegaRect
                            width: parent.width
                            height: parent.height;
                            color: baseItem.ListView.isCurrentItem? (loader.isOnline==true? loader.feed1Color: loader.menu4Color):"white"

                            Rectangle {
                                width: 0
                                height: 0
                                id: coloresRect
                                color:baseItem.ListView.isCurrentItem? (loader.isOnline?loader.feed2Color: "darkgray"): loader.menu9Color

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
                                to: (delegaRect.width * 3);

                                onStopped: {
                                    coloresRect.width = 0;
                                    coloresRect.height = 0;
                                }
                            }

                            MouseArea {
                                id: myMouseArea
                                property var presed
                                anchors.fill: parent;
                                onPressAndHold: presed=true
                                drag.target: presed?parent:undefined
                                drag.axis: Drag.XAxis
                                drag.minimumX: -width*0.40;
                                drag.maximumX: 0
                                onExited: {(circleAnimation.stop())}
                                onPressed: {
                                    coloresRect.x = mouseX;
                                    coloresRect.y = mouseY;
                                    circleAnimation.start()
                                }
                                onReleased: {
                                    presed = false
                                    if (parent.x <= drag.minimumX) {
                                        if (event_handler.currentOSys() != 1){
                                            Qt.openUrlExternally("tel:"+phone)
                                        } else {
                                            caller.directCall(phone)
                                        }
                                    }
                                    parent.x=0
                                }
                                onClicked: {
                                    listView.friend = phone
                                    windowsDialogs.show("Отправить заявку в друзья для <strong>" + login + " " + famil + "</strong>?", 2)
                                }
                            }

                            Connections {
                                target: windowsDialogs
                                onChooseChanged: {
                                    var objct = JSON.parse((loader.frienList))
                                    if (windowsDialogs.choose ==false && listView.friend != null) {
                                        if (objct == null) {
                                            objct = []
                                        }
                                        var objs = objct.push(listView.friend)
                                        loader.frienList=JSON.stringify(objct)
                                        loader.addFriend(listView.friend)
                                    }
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
                                sourceSize: {Qt.size(bug.width , bug.height);}
                            }*/

                            Rectangle {
                                id: bug
                                clip: true
                                smooth: true
                                visible: false
                                x:facade.toPx(30)
                                width: facade.toPx(100)
                                height:facade.toPx(100)
                                anchors.verticalCenter: parent.verticalCenter;
                                Image {
                                    source: image
                                    anchors.centerIn: parent
                                    height:sourceSize.width>sourceSize.height? parent.height: sourceSize.height*(parent.width/sourceSize.width);
                                    width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height/sourceSize.height): parent.width;
                                }
                            }

                            Row {
                                id: fo
                                spacing: facade.toPx(20)
                                height: Math.max(fullName.implicitHeight, telPhone.implicitHeight);
                                anchors {
                                    left: bug.right
                                    leftMargin: facade.toPx(30)
                                    verticalCenter: {(parent.verticalCenter);}
                                }
                                Text {
                                    id: fullName
                                    text: (login + " " + famil)
                                    font.family:trebu4etMsNorm.name
                                    font.pixelSize: facade.doPx(24)
                                    font.bold: true
                                    color: listView.currentIndex==index? "white":"#10387F"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    id: telPhone
                                    elide: Text.ElideRight
                                    text:phone.substring(0,1)+"("+phone.substring(1,4)+")-"+phone.substring(4,7)+"-"+phone.substring(7)+":"+port
                                    font.family:trebu4etMsNorm.name
                                    font.pixelSize: facade.doPx(18)
                                    width: delegaRect.width - bug.width - bug.x - fullName.implicitWidth - parent.spacing - 2 * facade.toPx(30);
                                    color:listView.currentIndex ==index? "white": "gray"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
                LinearGradient {
                    width: parent.width
                    height: facade.toPx(30)
                    end:  Qt.point(0, height)
                    visible: parent.counter > 2
                    anchors.bottom: parent.bottom
                    start:Qt.point(0, 0)
                    gradient: Gradient {
                        GradientStop {position: (0.40); color: ("#00000000");}
                        GradientStop {position: (1.00); color: ("#50000000");}
                    }
                }
            }

            XmlListModel {
                id: xmlmodel
                query: "/rss/channel/item"
                XmlRole {name: "link"; query : "link/string()";}
                XmlRole {name: "title"; query: "title/string()";}
                XmlRole {name: "pDate"; query: "pubDate/string()"}
                XmlRole {name: "pDesc"; query: "description/string()"}
                XmlRole {name: "image"; query: "media:content/@url/string()";}
                source:"http://rss.nytimes.com/services/xml/rss/nyt/World.xml"
                namespaceDeclarations: "declare namespace media=\"http://search.yahoo.com/mrss/\";"
                onStatusChanged: {
                    if ((status == XmlListModel.Ready) && (rssRect.visible)) {
                        var RssCache = []
                        for (var i = 0; i < xmlmodel.count; i++) {
                            var obj = {link: xmlmodel.get(i).link,
                                        title: xmlmodel.get(i).title,
                                          image: xmlmodel.get(i).image,
                                            pDate: xmlmodel.get(i).pDate,
                                              pDesc: xmlmodel.get(i).pDesc}
                            RssCache.push(obj)
                            for (var j = 0; j < rssView.model.count; j++) {
                                if (rssView.model.get(j).title == obj.title) {
                                    break;
                                }
                            }
                            if(j == rssView.model.count){
                                rssView.model.append(obj)
                            }
                        }
                        event_handler.saveSet("rss", JSON.stringify(RssCache))
                    }
                }
            }

            Rectangle {
                id: rssRect;
                visible: index == 1
                color: ("transparent")
                width: {parent.width;}
                height: if (visible) {3*facade.toPx(200)}
                DropShadow {
                    radius: 12
                    samples:15
                    source: {rssView;}
                    color: "#50000000"
                    anchors.fill: {rssView;}
                }
                ListView {
                    clip:true
                    id: rssView
                    width: parent.width;
                    height:parent.height
                    spacing: facade.toPx(20)
                    onContentYChanged: {
                        if (contentY < -200) {xmlmodel.reload()}
                        curInd=Math.floor((contentY-1)/(newsCardHgt+spacing));
                        if (contentY > oldContentY && curInd>=0) {
                            rssmodel.get(curInd).enable = false;
                        } else if (curInd >= -1) {
                            rssmodel.get(curInd+1).enable = true
                        }
                        oldContentY=contentY
                    }
                    Connections {
                        target: basView
                        onFlickStarted: oldContentY = basView.contentY
                        onContentYChanged: {
                            if (basView.contentY == 0 && oldContentY < -300) {
                                rssView.positionViewAtBeginning();
                                for (var i = 0; i < rssmodel.count; i = i+1) {
                                    rssmodel.get(i).enable = true;
                                }
                            }
                        }
                    }
                    model: ListModel {id: rssmodel}
                    snapMode: {ListView.SnapToItem}
                    delegate: Rectangle {
                        clip: true;
                        visible: enable
                        radius: height/2;
                        width: parent.width;
                        height: newsCardHgt = rssView.height/3-rssView.spacing
                        Rectangle {
                            color: parent.color
                            radius: parent.height/3
                            anchors {
                                fill: parent
                                leftMargin: parent.radius
                            }
                            Rectangle {
                                clip:true
                                color:"transparent"
                                anchors {
                                    fill: {parent;}
                                    rightMargin: {(parent.radius)}
                                }
                                Rectangle {
                                    width: 0
                                    height: 0
                                    id:coloresRect2
                                    color:"#EDEDED"

                                    transform:Translate {
                                        x: -coloresRect2.width /2;
                                        y: -coloresRect2.height/2;
                                    }
                                }
                            }
                            PropertyAnimation {
                                duration: 500
                                target:coloresRect2
                                id:circleAnimation2
                                properties: "width,height,radius";
                                from: 0
                                to: parent.width/2;

                                onStopped: {
                                    coloresRect2.width =0
                                    coloresRect2.height=0
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill:parent
                            onClicked: {
                                if (event_handler.currentOSys() >= 1) {
                                    loader.urlLink = link
                                    loader.webview = true
                                } else {
                                    Qt.openUrlExternally(link);
                                }
                            }
                            onEntered: {
                                coloresRect2.x = (mouseX)
                                coloresRect2.y = (mouseY)
                                circleAnimation2.start();
                            }
                        }

                        Rectangle {
                            id: bag
                            clip: true
                            smooth: true
                            visible:false
                            width: facade.toPx(160)
                            height:facade.toPx(160)
                            x: (parent.height - height)/2
                            anchors.verticalCenter:parent.verticalCenter
                            Image {
                                source: {image.replace("https", "http")}
                                anchors.centerIn: parent;
                                height:sourceSize.width>sourceSize.height? parent.height: sourceSize.height*(parent.width/sourceSize.width);
                                width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height/sourceSize.height): parent.width;
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
                            source: {"ui/mask/round.png"}
                            sourceSize: {Qt.size(bag.width, bag.height)}
                        }

                        Column {
                            anchors {
                                left: bag.right
                                right: parent.right
                                leftMargin: facade.toPx(20)
                                verticalCenter: {parent.verticalCenter;}
                            }
                            Text {
                                text: title
                                elide: {Text.ElideRight;}
                                width: {parent.width - facade.toPx(30);}
                                font.bold: true
                                font.family:trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(24)
                            }
                            Text {
                                text: pDate
                                lineHeight: 1.4
                                font.family:trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(15)
                            }
                            Text {
                                text: pDesc
                                maximumLineCount: 2
                                width: {parent.width - facade.toPx(30);}
                                wrapMode:Text.Wrap;
                                font.family:trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(20)
                            }
                        }
                    }
                }
            }

            ListView {
                clip: true
                visible: index == 2
                spacing: facade.toPx(27);
                width: parent.width
                height: facade.toPx(200);
                orientation:Qt.Horizontal
                model:ListModel {
                    ListElement {image:"mus.png"; text:"music"}
                    ListElement {image:"img.png"; text:"image"}
                    ListElement {image:"vide.png";text:"video"}
                    ListElement {image:"play.png";text:"games"}
                }
                delegate: Image {
                    width: facade.toPx(sourceSize.width / 3.5)
                    height: facade.toPx(sourceSize.height/ 3.5)
                    source: {"qrc:/ui/buttons/feeds/" + image;}
                }
            }
        }
    }

    Button {
        text: "Наверх"
        anchors {
            top: parent.top
            bottom: downRow.top;
            right: parent.right;
        }
        font.pixelSize: facade.doPx(20)
        font.family:trebu4etMsNorm.name
        visible: basView.contentY > 0 && (parent.width - nWidth) / 2 >= width;
        contentItem: Text {
            elide:Text.ElideRight
            verticalAlignment: Text.AlignBottom
            horizontalAlignment: {Text.AlignHCenter}
            width: parent.width;
            font: (parent.font);
            text: (parent.text);
        }
        onClicked: basView.positionViewAtBeginning()
        width: facade.toPx(250);
        background: Rectangle {
            color: ("#B0FFFFFF")
            anchors.fill:parent;
        }
    }

    Rectangle {
        id: downRow
        width: parent.width
        height: parent.height > parent.width? facade.toPx(100):facade.toPx(80)
        anchors.bottom: parent.bottom;
        Rectangle {
            height: 1
            width: parent.width;
            color: ("lightgray")
            anchors.top: {parent.top;}
        }
        Row {
            spacing: {facade.toPx(50)}
            anchors.centerIn: {parent}
            Repeater {
                model: ["Реклама", "Для бизнеса", "Все о P2P", "Безопасность"]
                Text {
                    text: {modelData;}
                    anchors.verticalCenter:parent.verticalCenter
                    font.family: trebu4etMsNorm.name
                    font.pixelSize:{facade.doPx(16)}
                }
            }
        }
    }

    Loader {
        source: event_handler.currentOSys()>0? "ibrowser.qml":""
        visible: loader.webview
        anchors.fill: {parent;}
    }
}
