import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Drawer {
    id: drawer
    property int workout
    height:parent.height
    width:0.75*parent.width
    background: Rectangle {color: "transparent";}
    
    function getPeersModel() {return usersModel;}

    Connections {
        onOpened: {
        usersModel.clear();
        getMePeers();
        }
        target:drawer
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
                        usersModel.append({
                            target: obj[i].name,
                            port: obj[i].port,
                            ip: obj[i].ip,
                            image1: "",
                            image2: ""
                        });
                    }
                }
            }
        } request.setRequestHeader('Content-Type' , 'application/x-www-form-urlencoded');
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

            model:  ListModel {
                id: usersModel;
                    ListElement {
                        image1: ""
                        image2: ""
                        target: ""
                        port: ""
                        ip: ""
                    }
                    /*
                    ListElement {
                        image1: "qrc:/ui/bars/icons/configDBlue.png";
                        image2: "qrc:/ui/bars/icons/configWhite.png";
                        target: "Настройки"
                    }
                    */
                }
            delegate: Rectangle {
                width: parent.width
                height: facade.toPx(100)
                color: ListView.isCurrentItem? "#00FFFFFF": "#FFFFFF"
                MouseArea {
                    id: navMouseArea
                    anchors.fill: parent
                    propagateComposedEvents: true
                    onExited: {
                        listView.currentIndex=-1;
                    }
                    onEntered: {
                        if(index != 0) {
                            listView.currentIndex = index
                        }
                    }

                    onClicked: {
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
                Row {
                    spacing: facade.toPx(25)
                    anchors{
                        fill: parent
                        leftMargin: facade.toPx(20)
                    }
                    Image {
                        source: navMouseArea.pressed==true || listView.currentIndex == index? image2: image1
                        anchors.verticalCenter: parent.verticalCenter;
                    }
                    Text {
                        text: target
                        wrapMode: Text.Wrap;
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(24);
                        width: (index != 0)? (0.75 * drawer.width): 0;
                        anchors.verticalCenter: parent.verticalCenter;
                        color: navMouseArea.pressed || listView.currentIndex == index? "#FFFFFF": "#10387F";
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
}
