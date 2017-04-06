import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Drawer {
    id: drawer
    property int workout:0;
    height: {parent.height}
    width: Math.min(facade.toPx(625), 0.75 * parent.width)
    background: Rectangle {color: "transparent";}
    
    function getPeersModel() {return usersModel;}

    Connections {
        target: drawer
        onOpened:getMePeers();
    }

    function findPeer(phone) {
        for(var i = 0; i<usersModel.count; i++) {
            if (usersModel.get(i).phone == phone)
                return i;
        }
        return -1;
    }

    function getMePeers() {
        var request=new XMLHttpRequest()
        request.open('POST',"http://www.hoppernet.hol.es")
        request.onreadystatechange = function() {
            if (request.readyState == XMLHttpRequest.DONE)
            {
                if (request.status && request.status==200)
                {
                var obj = JSON.parse(request.responseText)
                    for (var i = 0; i < obj.length; i++) {
                        var index = findPeer(obj[i].name);
                        if(usersModel.count==0 || index<0)
                            usersModel.append({
                                image: "http://lorempixel.com/200/200/sports",
                                famil: obj[i].family,
                                login: obj[i].login,
                                phone: obj[i].name,
                                port: obj[i].port,
                                ip: obj[i].ip
                            });
                        else {
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
                position: 0.0; color: "#CE326EB7"
            }
            GradientStop {
                position: 1.0; color: "#CE0FBFFF"
            }
        }

        Column {
            id: profile
            y: facade.toPx(25)
            spacing: facade.toPx(10)
            anchors.horizontalCenter: parent.horizontalCenter
            Row {
                id: firstRow
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: facade.toPx(30)/Math.max(facade.toPx(625) - drawer.width, 1);
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: usersModel.count
                        color: "white"
                        font.bold: true
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(46);
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
                    width: facade.toPx(250)
                    height:facade.toPx(250)
                    background: Rectangle {
                        radius: width * 0.5
                        color: "transparent"
                        border {
                          width: 1
                          color: "#40FFFFFF"
                        }
                    }

                    onClicked: {
                        drawer.close()
                        loader.avatar = true
                    }

                    Rectangle {
                        id: bag
                        clip: true
                        smooth: true
                        visible: false
                        width: {parent.width - facade.toPx(50.0)}
                        height: {parent.height - facade.toPx(50)}
                        anchors {
                            verticalCenter: parent.verticalCenter
                            horizontalCenter: (parent.horizontalCenter);
                        }
                        Image {
                            source:"qrc:/ui/profiles/default/Human.png";
                            height:sourceSize.width>sourceSize.height? parent.height: sourceSize.height*(parent.width/sourceSize.width)
                            width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height/sourceSize.height): parent.width
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
                        sourceSize: Qt.size(bag.width,bag.height)
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: "0"
                        color: "white"
                        font.bold: true
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(46);
                        anchors.horizontalCenter:parent.horizontalCenter
                    }
                    Text {
                        text: "Баланс"
                        color: "white"
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(24);
                        anchors.horizontalCenter:parent.horizontalCenter
                    }
                }
            }

            Row {
                width: firstRow.width
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    elide: Text.ElideRight
                    color: "white"
                    font.bold: true
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(28);
                    width: parent.width - scope1.implicitWidth - scope2.implicitWidth - image1.width
                    text: "Гоман Леонид Алексеевич";
                }
                Text {
                    id: scope1
                    text: " ( "
                    color: "#FFFFFF"
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(28);
                }
                Image {
                    id: image1
                    source:"qrc:/ui/profiles/lin.png"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    id: scope2
                    text: " 0 )"
                    color: "#FFFFFF"
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(28);
                }
            }
        }

        ListView {
            id: listView
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom

                top: profile.bottom
                topMargin: facade.toPx(50)
            }
            boundsBehavior: {Flickable.StopAtBounds}

            Component.onCompleted:usersModel.clear()

            model:  ListModel {
                id: usersModel;
                    ListElement {
                        image: ""
                        famil: ""
                        login: ""
                        phone: ""
                        port: ""
                        ip: ""
                    }
                }
            delegate: Rectangle {
                width: parent.width
                color: ListView.isCurrentItem==true? "white":"#40FFFFFF"
                height: facade.toPx(20)+Math.max(bug.height,info.height)

                MouseArea {
                    id: navMouseArea
                    anchors.fill:parent
                    propagateComposedEvents: true
                    /*
                    onExited: {
                        listView.currentIndex=-1;
                    }
                    */
                    onEntered:{
                        if(index!=-1)
                            listView.currentIndex = index
                    }

                    onClicked:{
                        var json = {
                            ip:usersModel.get(index).ip,
                            pt:usersModel.get(index).port
                        }
                        event_handler.sendMsgs(JSON.stringify(json));
                        /*
                        if(index == 0)
                            myswitcher.checked = !myswitcher.checked;
                        else if(index > 0 && index < 2) {
                            drawer.close();
                            listView.currentIndex = index
                        } else listView.currentIndex = -1
                        switch(index){
                        }
                        */
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
                    x: facade.toPx(20)
                    width: facade.toPx(100)
                    height:facade.toPx(100)
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        source: image
                        anchors.centerIn: parent
                        height:sourceSize.width>sourceSize.height? parent.height: sourceSize.height*(parent.width/sourceSize.width)
                        width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height/sourceSize.height): parent.width
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
                    id: info
                    width: parent.width
                    anchors {
                        left: bug.right
                        leftMargin: facade.toPx(20)
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        elide: Text.ElideRight
                        text: famil+" "+login+": "+port
                        font.family:trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(24)
                        width: parent.width-facade.toPx(60)-bug.width
                        color: navMouseArea.pressed || listView.currentIndex == index? "#10387F": "#FFFFFF";
                    }
                    Text {
                        text: phone.substring(0,1)+"("+ phone.substring(1,4)+ ") "+ phone.substring(4,7) + "-" + phone.substring(7)
                        elide: Text.ElideRight
                        font.family:trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(24)
                        width: parent.width-facade.toPx(60)-bug.width
                        color: navMouseArea.pressed || listView.currentIndex == index? "#10387F": "#FFFFFF";
                    }
                }
                /*
                Switch {
                    id: myswitcher
                    height: facade.toPx(80);
                    spacing: facade.toPx(15)
                    visible: index==0 ? 1: 0
                    anchors.verticalCenter: parent.verticalCenter;

                    font {
                        family: trebu4etMsNorm.name
                        pixelSize: facade.doPx(24);
                    }
                    text: checked? qsTr("Online"): qsTr("Offline")

                    indicator: Rectangle {
                        radius:facade.toPx(25)
                        x: parent.leftPadding;
                        y: parent.height/2 - height/2;
                        implicitWidth: facade.toPx(90)
                        implicitHeight:facade.toPx(40)
                        color:parent.checked?"#10387F":"#8610387F"

                        Rectangle {
                            x:parent.parent.checked?
                                  parent.width-width-(parent.height-height)/2: (parent.height-height)/2;
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.parent.height/1.5
                            height:parent.parent.height/1.5
                            radius: width / 2;
                            color: "#76CCCCCC"
                        }
                        Rectangle {
                            radius: width / 2;
                            x: parent.parent.checked?
                                  parent.width-width-(parent.height-height)/2: (parent.height-height)/2;
                            color:myswitcher.down? "#9610387F": (myswitcher.checked? "white": "#337CFD")
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.parent.height/1.8
                            height:parent.parent.height/1.8
                        }
                    }

                    contentItem: Text {
                        leftPadding: (parent.indicator.width + parent.spacing)
                        color: navMouseArea.pressed||listView.currentIndex==index? "#FFFFFF": "#10387F";
                        opacity: enabled == true? 1.0: 0.3;
                        verticalAlignment:Text.AlignVCenter
                        text: parent.text
                        font: parent.font
                    }
                }
                */
            }
        }
    }
}
