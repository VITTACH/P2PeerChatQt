import QtQuick 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle
import QtQuick.XmlListModel 2.0

Rectangle {
    id: rootPage;
    color: loader.feedColor

    property var nWidth;
    property int curInd: 0;
    property bool find: true;
    property int oldContentY: 0
    property int newsCardHgt: 0

    Component.onCompleted: blankeDrawer.open()

    ListView {
        id: basView
        width: parent.width
        spacing:facade.toPx(20)
        anchors {
            top: parent.top
            bottom: downRow.top
            topMargin: facade.toPx(40)
        }

        model: ListModel {
            id: feedsModel
            ListElement {activiti: 0;}
            ListElement {activiti: 1;}
            ListElement {activiti: 0;}
        }
        boundsBehavior : {
            (contentY <= 0) ? Flickable.StopAtBounds: Flickable.DragAndOvershootBounds
        }

        delegate: Column {
            anchors.horizontalCenter: parent.horizontalCenter
            width: nWidth = Math.min(0.9*parent.width, facade.toPx(900))
            Component.onCompleted: if (index == 1) {restorePref.start()}
            function findPeer(phone) {
                for (var i = 0; i < humanModel.count; i+=1) {
                    if (humanModel.get(i).phone == (phone)) {
                        return i;
                    }
                }
                return -1;
            }

            function filterList(param) {
                var succesFind = (false)
                for (var i = 0; i < humanModel.count; i ++) {
                    var name = " " + humanModel.get(i).login + humanModel.get(i).famil
                    if (name.toLowerCase().search(param)>0) {
                        humanModel.setProperty(i, ("activity"), 1)
                        if (!succesFind) {listView.currentIndex=i}
                        succesFind =true
                    } else {
                        humanModel.setProperty(i, ("activity"), 0)
                    }
                }
                if (succesFind ==true) {
                    feedsModel.setProperty(0, "activiti", 1);
                } else {
                    feedsModel.setProperty(0, "activiti", 0);
                }
                listView.positionViewAtBeginning()
            }

            function getMePeers(param) {
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
                                        image: "https://randomuser.me/portraits/men/" + Math.floor(100*Math.random()) + ".jpg",
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
                            filterList(param)
                        }
                    }
                }
                var contype = 'Content-Type'
                request.setRequestHeader(contype, 'application/x-www-form-urlencoded')
                request.send("READ=4")
            }

            Timer {
                id: restorePref
                interval: 1000;
                onTriggered: {restoreFromPref()}
            }

            function restoreFromPref() {
                if (xmlmodel.count > 0) {
                    var RssCache = [];
                    for (var i = 0; i < xmlmodel.count; i+= 1) {
                        var obj= {enable: true, link: xmlmodel.get(i).link, title: xmlmodel.get(i).title, image: xmlmodel.get(i).image, pDate: xmlmodel.get(i).pDate, pDesc: xmlmodel.get(i).pDesc}
                        RssCache.push(obj)
                        for (var j = 0; j < rssView.model.count; j++) {
                            if (rssView.model.get(j).title == obj.title) break
                        }
                        if (j == rssView.model.count)rssView.model.append(obj)
                    }
                    event_handler.saveSet(("rss"), JSON.stringify((RssCache)))
                } else {
                    var rssNews = event_handler.loadValue("rss");
                    if (rssNews !== "") {
                        var rssOld = JSON.parse(rssNews);
                        for (var i = 0; i <rssOld.length; i+=1) {
                            rssView.model.append({enable: (true), link: (rssOld[i].link), title: (rssOld[i].title), image: (rssOld[i].image), pDate: (rssOld[i].pDate), pDesc: (rssOld[i].pDesc)});
                        }
                    }
                }
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
                            if(find) {inerText.clear(); getMePeers("");}
                        }
                        background:Image {
                            id: innerImage
                            width: {facade.toPx(sourceSize.width /1.3);}
                            height:{facade.toPx(sourceSize.height/1.3);}
                            anchors.verticalCenter:parent.verticalCenter
                            source: "qrc:/ui/icons/" + (find? "searchIconWhite": "DeleteIconWhite") + ".png"
                        }
                    }
                    Connections {
                        target: blankeDrawer
                        onPositionChanged: if((blankeDrawer.position === 1) == true) {inerText.focus = false}
                    }
                    TextField {
                        id: inerText
                        color: "#C0C8D0"
                        width: parent.parent.width - inerImage.width - (parent.spacing) - (facade.toPx(30));

                        rightPadding: parent.parent.radius;
                        onAccepted: getMePeers(text.toLowerCase());
                        onTextChanged: if (event_handler.currentOSys() != 1 && event_handler.currentOSys() != 2) getMePeers(text.toLowerCase())
                        placeholderText: qsTr("Найти новых друзей")
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
                        if (humanModel.get(i).activity==1 && visible ==true) {
                            cunter++;
                        }
                    }
                    if (cunter>4) cunter=4;
                    counter=cunter;
                    cunter*facade.toPx(124)
                }
                visible: index==0&&activiti
                ListView {
                    id: listView
                    spacing: 1
                    anchors.fill:parent
                    snapMode: ListView.SnapToItem;
                    boundsBehavior: Flickable.StopAtBounds;

                    property var friend

                    model:ListModel{id:humanModel}
                    delegate: Item {
                        id: baseItem
                        visible: activity
                        width: parent.width
                        height: {
                            if (activity) {
                                facade.toPx(20)+Math.max(bug.height,fo.height)
                            } else 0
                        }

                        Rectangle {
                            clip: true
                            id: delegaRect
                            width: parent.width
                            height: parent.height;
                            color: (baseItem.ListView.isCurrentItem)? (loader.isOnline == true? loader.feed1Color: loader.menu4Color): "white";

                            Rectangle {
                                width: 0
                                height: 0
                                id: coloresRect
                                color: (baseItem.ListView.isCurrentItem)? (loader.isOnline? loader.feed2Color: "darkgray"): (loader.menu9Color)

                                transform: Translate {
                                    x:-coloresRect.width /2
                                    y:-coloresRect.height/2
                                }
                            }

                            PropertyAnimation {
                                duration: 500
                                target: coloresRect;
                                id: circleAnimation;
                                properties:("width, height, radius");
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
                                onExited: {(circleAnimation.stop());}
                                onPressed: {
                                    coloresRect.x = mouseX;
                                    coloresRect.y = mouseY;
                                    circleAnimation.start()
                                }
                                onClicked: {
                                    listView.friend = phone
                                    defaultDialog.show(qsTr("Отправить заявку в друзья для <strong>") + login + " " + famil + "</strong>?", 2);
                                }
                            }

                            Connections {
                                target: defaultDialog
                                onChooseChanged: {
                                    if (listView.memIndex != index) {
                                        var objct = JSON.parse((loader.frienList))
                                        if (defaultDialog.choose== false && listView.friend!=null) {
                                            if (objct === null) {objct = [];}
                                            var objs = objct.push(listView.friend)
                                            loader.frienList=JSON.stringify(objct)
                                            loader.addFriend(listView.friend)
                                            defaultDialog.choose=true
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: bug
                                clip: true
                                smooth: true
                                x:facade.toPx(30)
                                width: facade.toPx(100)
                                height:facade.toPx(100)
                                anchors.verticalCenter: parent.verticalCenter;
                                Image {
                                    source: image
                                    anchors.centerIn: parent
                                    height:sourceSize.width>sourceSize.height? parent.height: sourceSize.height*(parent.width/sourceSize.width)
                                    width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height/sourceSize.height): parent.width
                                }
                            }

                            Column {
                                id: fo
                                anchors {
                                    left: bug.right
                                    right: parent.right
                                    leftMargin: facade.toPx(30)
                                }
                                Text {
                                    text: (login + " " + famil)
                                    color: listView.currentIndex== index? "#FFFFFFFF": "#FF000000";
                                    font.family:trebu4etMsNorm.name
                                    font.pixelSize: facade.doPx(30)
                                }
                                Text {
                                    text: "ip: " + ip + ", port: " + port
                                    color: listView.currentIndex== index? "#FFFFFFFF": "#FF808080";
                                    font.family:trebu4etMsNorm.name
                                    font.pixelSize: facade.doPx(20)
                                }
                            }
                        }
                    }
                }
                LinearGradient {
                    width: parent.width
                    height: facade.toPx(5)
                    end:  Qt.point(0, height)
                    visible: parent.counter > 2
                    anchors.bottom: parent.bottom
                    start:Qt.point(0, 0)
                    gradient: Gradient {
                        GradientStop {position: (0.00); color: ("#00000000");}
                        GradientStop {position: (1.00); color: ("#40000000");}
                    }
                }
            }

            XmlListModel {
                id: xmlmodel
                query: {"/rss/channel/item";}
                XmlRole {name: "link"; query: "link/string()"}
                XmlRole {name: "title"; query: "title/string()";}
                XmlRole {name: "pDate"; query:"pubDate/string()"}
                XmlRole {name: "pDesc"; query: "description/string()"}
                XmlRole {name: "image"; query: "media:content/@url/string()";}
                source:"http://rss.nytimes.com/services/xml/rss/nyt/World.xml"
                namespaceDeclarations: "declare namespace media=\"http://search.yahoo.com/mrss/\";"
                onStatusChanged: {
                    partnerHeader.load(progress)
                    if ((status == XmlListModel.Ready) && (rssRect.visible)) {
                        if (!loader.isNews) {
                            restorePref.start();
                            loader.isNews = true
                        } else restoreFromPref()
                    }
                }
            }

            Rectangle {
                id: rssRect;
                visible: index==1
                color: "transparent"
                width: {parent.width;}
                height: if (visible == true) 4*facade.toPx(200);
                DropShadow {
                    radius: 8
                    samples: 18
                    source: {rssView;}
                    color: "#50000000"
                    anchors.fill: {rssView;}
                }
                ListView {
                    id: rssView
                    clip: true
                    width: parent.width
                    height: parent.height;
                    spacing: facade.toPx(20)
                    model: ListModel {id: rssmodel;}
                    snapMode: {ListView.SnapToItem;}
                    onContentYChanged: {
                        var p = newsCardHgt+spacing;
                        curInd = Math.floor((contentY - 1) / p);
                        if (contentY > oldContentY&&curInd>=0) {
                            rssmodel.get(curInd).enable = false;
                        } else if (curInd >= -1) {
                            rssmodel.get(curInd+1).enable = true
                        }
                        oldContentY = contentY;
                    }
                    boundsBehavior: {
                        if (contentY < 1) Flickable.StopAtBounds
                        else Flickable.DragAndOvershootBounds
                    }

                    delegate: Rectangle {
                        visible: enable
                        width: parent.width;
                        radius: facade.toPx(10)
                        Item {
                            clip: true
                            anchors.fill:parent
                            anchors.margins: parent.radius
                            Rectangle {
                                id:coloresRect2
                                color:loader.feedColor
                                transform: Translate {
                                    x: -coloresRect2.width /2.0;
                                    y: -coloresRect2.height/2.0;
                                }
                            }
                        }

                        Rectangle {
                            id: bag;
                            clip: true
                            smooth: true
                            width: facade.toPx(160)
                            height:facade.toPx(160)
                            anchors.verticalCenter:parent.verticalCenter
                            Image {
                                source: {image.replace("https", "http")}
                                anchors.centerIn: {parent}
                                height:sourceSize.width > sourceSize.height? parent.height: sourceSize.height*(parent.width / sourceSize.width)
                                width: sourceSize.width > sourceSize.height? sourceSize.width*(parent.height / sourceSize.height): parent.width
                            }
                            x: (parent.height - height)/2;
                        }
                        Image {
                            id: misk
                            smooth: true;
                            visible:false
                            source: {"ui/mask/round.png";}
                            sourceSize: {Qt.size(bag.width, bag.height)}
                        }

                        MouseArea {
                            anchors.fill: {parent;}
                            onClicked: {
                                if (chatScreen.position>0)return
                                loader.urlLink = link;
                                if (event_handler.currentOSys() > (0)) {
                                    loader.webview = true;
                                    partnerHeader.text = (title)
                                } else {
                                    Qt.openUrlExternally(loader.urlLink)
                                }
                            }
                            onPressed: {
                                coloresRect2.x = (mouseX);
                                coloresRect2.y = (mouseY);
                                circleAnimation2.start()
                            }
                        }

                        PropertyAnimation {
                            id: circleAnimation2
                            target: coloresRect2
                            properties: {"width,height,radius";}
                            from: 0
                            duration: 500
                            to: parent.width * 2
                            onStopped: {
                                coloresRect2.width = 0;
                                coloresRect2.height= 0;
                            }
                        }

                        height: {
                            newsCardHgt=rssView.height/4-rssView.spacing
                        }

                        Column {
                            anchors {
                                left: bag.right
                                right: parent.right
                                leftMargin:facade.toPx(20)
                                verticalCenter: {parent.verticalCenter;}
                            }
                            Text {
                                text: title
                                elide: {(Text.ElideRight)}
                                width: {parent.width - facade.toPx(30);}
                                font.bold: true
                                font.family: trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(24);
                            }
                            Text {
                                text: pDate
                                lineHeight: 1.4
                                width: {parent.width - facade.toPx(30);}
                                font.family: trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(15);
                            }
                            Text {
                                text: pDesc
                                maximumLineCount: 2
                                width: {parent.width - facade.toPx(30);}
                                wrapMode:Text.Wrap;
                                font.family: trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(20);
                            }
                        }
                    }
                }
            }

            ListView {
                clip: true
                width: contentWidth
                x: (parent.width - width)/2.0
                height: facade.toPx(160);
                spacing: facade.toPx(27);
                orientation:Qt.Horizontal
                visible: index==2
                model:ListModel {
                    ListElement {image:"qrc:/ui/buttons/feeds/mus.png";}
                    ListElement {image:"qrc:/ui/buttons/feeds/img.png";}
                    ListElement {image:"qrc:/ui/buttons/feeds/vide.png"}
                    ListElement {image:"qrc:/ui/buttons/feeds/play.png"}
                }
                delegate: Image {
                    width: facade.toPx(sourceSize.width/3.55)
                    height: facade.toPx(sourceSize.height/3.55);
                    source: image

                    PropertyAnimation {
                        duration: 1000
                        target: colorSquare;
                        id: squareAnimation;
                        properties: {("width, height, radius");}
                        from: 0
                        to: (parent.width*3)
                        onStopped: colorSquare.width = colorSquare.height = 0;
                    }

                    Item {
                        clip: true
                        anchors.fill: parent
                        anchors.margins: facade.toPx(10)
                        Rectangle {
                            width: 0
                            height:0
                            opacity: (0.27)
                            id: colorSquare
                            color:loader.menu9Color
                            transform: Translate {
                                x:-colorSquare.width/2;y:-colorSquare.height/2
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: {
                            colorSquare.x = colorSquare.y=mouseY
                            squareAnimation.start()
                        }
                        onExited: squareAnimation.stop()
                    }
                }
            }
        }
    }

    Button {
        text:qsTr("Наверх")
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

    P2PStyle.BlankeDrawer {id: blankeDrawer}

    ChatScreen {id: chatScreen}
}
