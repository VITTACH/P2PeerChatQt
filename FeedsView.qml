import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import QtQuick.XmlListModel 2.0
import QtQuick 2.0

Rectangle {
    id: baseRect
    color: loader.mainBackgroundColor
    Component.onCompleted: mainDrawer.open()

    property int nWidth: 0
    property bool find: true
    property int oldContentY: 0

    ListView {
        id: basView
        width: parent.width
        spacing: facade.toPx(15)
        anchors {
            top: parent.top
            bottom: downRow.top;
            bottomMargin: facade.toPx(10)
            topMargin: partnerHeader.height + facade.toPx(10)
        }

        boundsBehavior : {
            contentY <= 0 ? Flickable.StopAtBounds : Flickable.DragAndOvershootBounds;
        }

        model: ListModel {
            id: feedsModel
            ListElement {}
            ListElement {}
        }

        delegate: Column {
            x: facade.toPx(15)
            width: nWidth = Math.min(parent.width - facade.toPx(80), facade.toPx(800))

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
                        if (!succesFind) listView.currentIndex = i
                        succesFind =true
                    } else {
                        humanModel.setProperty(i, ("activity"), 0)
                    }
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

            function rssLoadingAndSaving() {
                if (xmlmodel.count > 0) {
                    var RsCache = []
                    for (var i = 0; i < xmlmodel.count; i+= 1) {
                        var obj= {enable: true, link: xmlmodel.get(i).link, title: xmlmodel.get(i).title, image: xmlmodel.get(i).image, pDate: xmlmodel.get(i).pDate, pDesc: xmlmodel.get(i).pDesc}
                        RsCache.push(obj)
                        for (var j = 0; j < rssView.model.count; j++) {
                            if (rssView.model.get(j).title == obj.title)
                                break
                        }
                        if (j == rssView.model.count)
                            rssView.model.append(obj)
                    }
                    event_handler.saveSettings("rss",JSON.stringify(RsCache))
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

            Item {
                visible: index == 0
                property int countCard: 4

                Component.onCompleted: {
                    xmlmodel.source = "http://rss.nytimes.com/services/xml/rss/nyt/World.xml"
                }

                XmlListModel {
                    id: xmlmodel
                    query: {"/rss/channel/item";}
                    XmlRole {name: "link"; query: "link/string()"}
                    XmlRole {name: "title"; query: "title/string()"}
                    XmlRole {name: "pDate"; query: "pubDate/string()"}
                    XmlRole {name: "pDesc";query:"description/string()"}
                    XmlRole {name: "image"; query: "media:content/@url/string()";}
                    namespaceDeclarations: "declare namespace media=\"http://search.yahoo.com/mrss/\";"
                    onStatusChanged: {
                        if ((status == XmlListModel.Ready || status == XmlListModel.Error)) {
                            rssLoadingAndSaving()
                        }
                    }
                }

                DropShadow {
                    samples:18
                    radius: facade.toPx(15);
                    anchors.fill: {rssView;}
                    source: {rssView;}
                    color: "#50000000"
                }
                ListView {
                    id: rssView
                    clip: visible;
                    width: parent.width
                    height: parent.height
                    spacing: facade.toPx(20)
                    model: ListModel{id:rssmodel}
                    snapMode: ListView.SnapToItem
                    boundsBehavior: {
                        if(contentY<1) Flickable.StopAtBounds
                        else Flickable.DragAndOvershootBounds
                    }

                    delegate: Rectangle {
                        visible: enable
                        width: parent.width;
                        radius: facade.toPx(10)
                        height: Math.max(facade.toPx(260), description.height)
                        color: loader.newsBackgroundColor;

                        Item {
                            clip: true
                            anchors.fill: parent;
                            anchors.margins: {parent.radius;}

                            Rectangle {
                                id: coloresRect2;
                                color: loader.feed4Color
                                transform: Translate {
                                    x: -coloresRect2.width /2
                                    y: -coloresRect2.height/2
                                }
                            }
                        }

                        Rectangle {
                            id: bag;
                            clip: true
                            smooth: true
                            x: facade.toPx(10)
                            width: facade.toPx(200)
                            height:width
                            y: x
                            Image {
                                source: typeof image!="undefined"?image.replace("ps","p"):""
                                anchors.centerIn: parent
                                height:sourceSize.width > sourceSize.height? parent.height: sourceSize.height*(parent.width / sourceSize.width)
                                width: sourceSize.width > sourceSize.height? sourceSize.width*(parent.height / sourceSize.height): parent.width
                            }
                        }

                        Image {
                            smooth: true
                            visible: false
                            source: "ui/mask/round.png";
                            sourceSize: {Qt.size(bag.width, bag.height)}
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (chatScreen.position > 0) return
                                loader.urlLink = link;
                                if (event_handler.currentOSys() > (0)) {
                                    loader.webview = true;
                                    partnerHeader.text = (title)
                                } else {
                                    Qt.openUrlExternally(loader.urlLink)
                                }
                            }
                            onPressed: {
                                coloresRect2.x = mouseX;
                                coloresRect2.y = mouseY;
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
                                coloresRect2.width = (0)
                                coloresRect2.height = 0;
                            }
                        }

                        Column {
                            id: description
                            anchors {
                                left: bag.right
                                right: parent.right;
                                topMargin:facade.toPx(5)
                                leftMargin: facade.toPx(20)
                                top: parent.top
                            }

                            Text {
                                text: title
                                color: loader.newsHeadColor
                                elide: Text.ElideRight
                                width: {parent.width - facade.toPx(30);}
                                font.bold: true
                                font.family: trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(22);
                            }

                            Text {
                                text: pDate
                                color: loader.newsDateColor
                                lineHeight: 1.4
                                width: {parent.width - facade.toPx(30);}
                                font.family: trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(15);
                            }

                            Text {
                                text: pDesc
                                color: loader.newsDescColor
                                maximumLineCount: 4
                                width: {parent.width - facade.toPx(30);}
                                wrapMode: Text.Wrap
                                font.family: trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(20);
                            }
                        }
                    }
                }

                width: parent.width
                height: {
                    var cardHeight = facade.toPx(210);
                    var count = Math.floor((baseRect.height - partnerHeader.height - (feedsModel.count - 1) * basView.spacing) / cardHeight)
                    if (count < 4) count = 4
                    countCard = count
                    if (event_handler.currentOSys() > 0) {
                        if (Screen.orientation ==Qt.LandscapeOrientation) {
                            countCard = 2 * countCard
                        }
                    }
                    return countCard*cardHeight-rssView.spacing;
                }
            }

            Rectangle {
                clip: true
                visible: index == 1
                width: parent.width
                height: facade.toPx(160)
                radius: facade.toPx(10);

                color: loader.pageBackgroundColor

                ListView {
                    width: parent.width - facade.toPx(50)
                    height: parent.height - facade.toPx(16)
                    spacing: (width - pages.count * facade.toPx(144)) / (pages.count - 1)
                    orientation: Qt.Horizontal
                    anchors.centerIn: {parent}

                    model:ListModel {
                        id: pages
                        ListElement { image: "/ui/buttons/feeds/mus.png"; }
                        ListElement { image: "/ui/buttons/feeds/img.png"; }
                        ListElement { image: "/ui/buttons/feeds/vide.png" }
                        ListElement { image: "/ui/buttons/feeds/play.png" }
                    }

                    delegate: Item {
                        width: img.width
                        height: img.height

                        DropShadow {
                            samples: 18
                            source: img
                            color: "#50000000"
                            radius: 12
                            anchors.fill: img;
                        }
                        Image {
                            id: img
                            width: facade.toPx(sourceSize.width / 3.55)
                            height: {facade.toPx(sourceSize.height / 3.55)}
                            anchors.centerIn: parent
                            source: image
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: downRow
        width: parent.width
        height: facade.toPx(80);
        anchors.bottom: parent.bottom
        color: loader.menu9Color

        Item {
            clip: true
            width: nWidth
            height:parent.height
            x: facade.toPx(10)

            ListView {
                id: bottomNav;
                property var buttonWidth: facade.toPx(140)
                anchors.horizontalCenter: parent.horizontalCenter

                orientation: Qt.Horizontal
                spacing: facade.toPx(50)
                height: parent.height
                width: (buttonWidth+spacing)*model.count-spacing;

                model: ListModel {
                    ListElement { message: "Новости" }
                    ListElement { message: "Партнерам" }
                    ListElement { message: "Поделись"; }
                    ListElement { message: "Все о P2P" }
                }

                delegate: Item {
                    anchors.verticalCenter: parent.verticalCenter
                    width: bottomNav.buttonWidth

                    Text {
                        text: message
                        anchors.centerIn: parent
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(16);
                    }
                }
            }
        }
    }

    Loader {
        source: event_handler.currentOSys()>0?"WebService.qml":""
        visible: loader.webview
        anchors {
            fill: parent
            topMargin: partnerHeader.height
        }
    }
}
