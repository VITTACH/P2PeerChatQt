import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Drawer {
    id: drawer
    property int workout:0;
    height: {parent.height}
    width:0.75*parent.width
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

        ListView {
            id: listView
            anchors.fill: parent
            boundsBehavior:Flickable.StopAtBounds

            Component.onCompleted: {usersModel.clear();}

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
                height: {facade.toPx(20) + Math.max(bug.height, info.implicitHeight);}
                color: ListView.isCurrentItem? "#FFFFFF": "#40FFFFFF"

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
                    anchors.fill: bug
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
                        height:sourceSize.width>sourceSize.height? parent.height:sourceSize.height * (parent.width/sourceSize.width)
                        width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height/sourceSize.height): parent.width;
                    }
                }

                Image {
                    id: mask
                    smooth: true
                    visible: false
                    source: "qrc:/ui/mask/round.png"
                    sourceSize: {Qt.size(bug.width, bug.height);}
                }

                Text {
                    id: info
                    lineHeight: 1.2
                    wrapMode: Text.Wrap
                    width: parent.width-facade.toPx(60)-bug.width
                    anchors {
                        left: bug.right
                        leftMargin: facade.toPx(20)
                    }
                    font.family:trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(24)
                    text: {famil + " " + login + "<br>" + phone;}
                    anchors.verticalCenter: parent.verticalCenter
                    color: navMouseArea.pressed || listView.currentIndex == index? "#10387F": "#FFFFFF";
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
