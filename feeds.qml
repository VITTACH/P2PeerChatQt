import QtQuick 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import QtQuick.XmlListModel 2.0

Rectangle {
    id: rootPage;
    color: "#FFEDEDED";
    property bool find: true;
    ListView {
        spacing: facade.toPx(40);
        width: Math.min(0.9*parent.width,facade.toPx(900))
        anchors {
        top: parent.top
        bottom: parent.bottom
        topMargin:facade.toPx(40)
        horizontalCenter:parent.horizontalCenter
        }

        boundsBehavior: {Flickable.StopAtBounds}
        model : ListModel {
            id: feedsModel;
            ListElement {activiti: 0}
            ListElement {activiti: 1}
        }

        delegate: Column {
            width:parent.width
            Component.onCompleted: getMePeers();

            function findPeer(phone){
                for (var i = 0; i<humanModel.count; i++) {
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
                        humanModel.setProperty(i, "activity", 1)
                        if (!succesFind)listView.currentIndex=i;
                        succesFind = true
                    }
                    else {
                        humanModel.setProperty(i, "activity", 0)
                    }
                }
                if (succesFind)
                    feedsModel.setProperty(0, "activiti", 1);
                else
                    feedsModel.setProperty(0, "activiti", 0);
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
                request.send("READ=2")
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
                        target: menuDrawer
                        onPositionChanged: if((menuDrawer.position == 1) == true) {inerText.focus = (false)}
                    }
                    TextField {
                        id: inerText
                        color: "#C0C8D0"
                        width: parent.parent.width - inerImage.width - (parent.spacing) - (facade.toPx(30));

                        rightPadding: parent.parent.radius;
                        onAccepted: filterList(text.toLowerCase())
                        onTextChanged: if (event_handler.currentOSys()!=1 && event_handler.currentOSys()!=2) filterList(text.toLowerCase());
                        placeholderText: "Найти друзей";
                        font.bold: true
                        font.pixelSize: facade.doPx(20);
                        font.family: trebu4etMsNorm.name
                        onActiveFocusChanged:find=false;
                        background: Rectangle{opacity:0}
                    }
                }
            }

            Rectangle {
                clip: true
                width: parent.width;
                color: "transparent"
                height: {
                    var counter = 0;
                    for (var i = 0; i<listView.count; i++){
                        if (humanModel.get(i).activity == 1 && visible) {
                            counter++;
                        }
                    }
                    if (counter > 4) {
                        counter = 4;
                    }
                    counter*facade.toPx(125) + counter*listView.spacing
                }
                visible: index==0&&activiti
                ListView {
                    id: listView
                    anchors.fill:parent
                    spacing: facade.toPx(2)
                    snapMode: ListView.SnapToItem;
                    boundsBehavior: Flickable.StopAtBounds;

                    Component.onCompleted:{
                        humanModel.clear();
                    }

                    model:  ListModel {
                        id: humanModel;
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
                    delegate: Item {
                        id: baseItem
                        visible: activity
                        width: parent.width
                        height: activity==1? facade.toPx(20)+Math.max(bug.height,fo.height):0

                        Rectangle {
                            color: "#FF006400"
                            width: parent.height+4
                            height:parent.height-4
                            anchors.right: parent.right;
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                anchors.centerIn: parent
                                width: facade.toPx(sourceSize.width)
                                height: facade.toPx(sourceSize.height)
                                source:"qrc:/ui/buttons/dialerButton.png"
                            }
                        }

                        Rectangle {
                            clip: true
                            id: delegaRect
                            width: parent.width
                            height: parent.height;
                            color: baseItem.ListView.isCurrentItem? (loader.isOnline? "#527392": "#999999"): ("white")

                            Rectangle {
                                width: 0
                                height: 0
                                id: coloresRect
                                color:baseItem.ListView.isCurrentItem?(loader.isOnline?"#6E879E":"darkgray"):"#E5E5E5"

                                transform: Translate {
                                x: -coloresRect.width /2
                                y: -coloresRect.height/2
                                }
                            }

                            PropertyAnimation {
                                duration: 500
                                target: coloresRect;
                                id: circleAnimation;
                                properties:("width, height, radius")
                                from: 0
                                to: delegaRect.width * 3

                                onStopped: {
                                    coloresRect.width =0
                                    coloresRect.height=0
                                }
                            }

                            MouseArea {
                                id: myMouseArea
                                anchors.fill:{parent;}
                                drag.target: {parent;}
                                drag.axis: Drag.XAxis;
                                drag.minimumX:-height;
                                drag.maximumX:0
                                onExited: {
                                    circleAnimation.stop();
                                }
                                onEntered: {
                                    coloresRect.x = mouseX;
                                    coloresRect.y = mouseY;
                                    circleAnimation.start()
                                }
                                onReleased: {
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
                                source: beg
                                color:"#90000000"
                                anchors.fill:beg;
                            }
                            OpacityMask {
                                id: beg
                                source: bug
                                maskSource: mask;
                                anchors.fill:bug;
                            }

                            Rectangle {
                                id: bug
                                clip: true
                                smooth: true
                                visible: false
                                x:facade.toPx(50)
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
                                    font.pixelSize: facade.doPx(24)
                                    width:fo.width-facade.toPx(100)-bug.width
                                    color:listView.currentIndex ==index? "white":"#10387F"
                                }
                                Text {
                                    text:phone.substring(0,1)+"("+phone.substring(1,4)+")-"+phone.substring(4,7)+"-"+phone.substring(7)+":"+port
                                    elide: Text.ElideRight
                                    font.family:trebu4etMsNorm.name
                                    font.pixelSize: facade.doPx(24)
                                    width:fo.width-facade.toPx(100)-bug.width
                                    color:listView.currentIndex ==index? "white":"#10387F"
                                }
                            }
                        }
                    }
                }
            }

            XmlListModel {
                id: xmlmodel
                query: "/rss/channel/item"
                XmlRole {name: "title"; query : "title/string()";}
                XmlRole {name: "pDate"; query: "pubDate/string()"}
                XmlRole {name: "pDesc"; query: "description/string()"}
                XmlRole {name: "image"; query: "media:content/@url/string()";}
                source:"http://rss.nytimes.com/services/xml/rss/nyt/World.xml"
                namespaceDeclarations: "declare namespace media=\"http://search.yahoo.com/mrss/\";"
            }

            Rectangle {
                visible: index
                color: ("transparent")
                width: {parent.width;}
                height:visible?2*facade.toPx(180):0
                DropShadow {
                    radius: 15
                    samples: 15
                    source: rssView
                    color: "#90000000"
                    anchors.fill: rssView
                }
                ListView {
                    clip:true
                    id: rssView
                    model: xmlmodel
                    width: {parent.width}
                    height: parent.height
                    spacing: facade.toPx(20);
                    snapMode: {ListView.SnapToItem}
                    boundsBehavior: Flickable.StopAtBounds;
                    delegate: Rectangle {
                        radius: height/2;
                        width: {parent.width}
                        height: {(rssView.height/2) - (rssView.spacing)}
                        Rectangle {
                            clip: true
                            color: parent.color
                            radius: parent.height/3
                            anchors {
                                fill: parent;
                                leftMargin: parent.radius
                            }
                            Rectangle {
                                width: 0
                                height: 0
                                id: coloresRect2
                                color: "#EDEDED"

                                transform: Translate {
                                x: -coloresRect2.width /2
                                y: -coloresRect2.height/2
                                }
                            }
                            PropertyAnimation {
                                duration: 500
                                target: coloresRect2
                                id: circleAnimation2
                                properties:("width, height, radius")
                                from: 0
                                to: parent.width / 2

                                onStopped: {
                                    coloresRect2.width =0
                                    coloresRect2.height=0
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill:parent
                            onClicked: {Qt.openUrlExternally(image)}
                            onEntered: {
                                coloresRect2.x = mouseX;
                                coloresRect2.y = mouseY;
                                circleAnimation2.start()
                            }
                        }

                        Rectangle {
                            id: bag
                            clip: true
                            smooth: true
                            visible:false
                            width: facade.toPx(130)
                            height:facade.toPx(130)
                            x: (parent.height - height)/2;
                            anchors.verticalCenter:parent.verticalCenter
                            Image {
                                source: {image.replace("https", "http")}
                                anchors.centerIn: {parent}
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
                            source: {"ui/mask/round.png";}
                            sourceSize: {Qt.size(bag.width, bag.height)}
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
                                elide: {Text.ElideRight}
                                width: 2*parent.width/3;
                                font.bold: true
                                font.family:trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(18)
                            }
                            Text {
                                text: pDate
                                font.family:trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(15)
                            }
                            Text {
                                text: pDesc
                                width: (parent.width - facade.toPx(20));
                                wrapMode : {Text.WrapAnywhere;}
                                font.family:trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(15)
                            }
                        }
                    }
                }
            }
        }
    }
}
