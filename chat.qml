import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle

Item {
    id: rootChat

    property var select:[]
    property bool input:false
    TextArea {
        id: buferText;
        visible: false
        wrapMode: {TextEdit.Wrap;}
        width: 3*rootChat.width/4;
        font {
        pixelSize: facade.doPx(26)
        family:trebu4etMsNorm.name
        }
    }

    function checkMessage(flag) {
        if (screenTextFieldPost.text.length >= 1) {
            buferText.text=screenTextFieldPost.text
            loader.chats[menuDrawer.cindex].message.push({text: buferText.text , flag: flag});

            appendMessage(buferText.text,flag)
            chatScreenList.positionViewAtEnd()
            screenTextFieldPost.text = "";
        }
    }

    Timer {
        running: true
        interval: 100
        onTriggered:{
            if(menuDrawer.getPeersCount()>0) {
            partnerHeader.phot = menuDrawer.getPeersModel(0,"image")
            partnerHeader.stat = menuDrawer.getPeersModel(0, "port") == 0? "Offline": "Online"
            partnerHeader.text = menuDrawer.getPeersModel(0, "login") + " " + menuDrawer.getPeersModel(0, "famil")
            }
            else start()
        }
    }

    Connections {
        target: menuDrawer
        onCindexChanged: {
            select = [];
            busyIndicator.visible=true
            chatModel.clear();
            var i = menuDrawer.cindex;
            for (var j=0; j < loader.chats[i].message.length; j++) {
                buferText.text = loader.chats[i].message[j].text;
                appendMessage(loader.chats[i].message[j].text,loader.chats[i].message[j].flag)
            }
            busyIndicator.visible=!busyIndicator.visible;
        }
    }

    Connections {
        target: event_handler;
        onReciving: {
            var i
            if(response!="") {
                var obj = JSON.parse(response)
                for (i=0; i < loader.chats.length; i++) {
                    if (obj.phone==loader.chats[i].phone)
                        break;
                }
                loader.chats[i].message.push({text: buferText.text = (obj.message) , flag: 1})
                if ( i === menuDrawer.getCurPeerInd() ) {
                    appendMessage(obj.message, 1)
                    chatScreenList.positionViewAtEnd();
                }
            }
        }
    }

    Connections {
        target: contextDialog;
        onActionChanged: {
            if(contextDialog.action==1)
            {
                select.sort();
                for(var i=0; i<select.length; i++) {
                    chatModel.remove(select[i] - i);
                    loader.chats[menuDrawer.cindex].message.splice(select[i] - i,1)
                }
                for(var i=1; i<chatModel.count; i++)
                    chatModel.setProperty(i, "mySpacing",
                            (chatModel.get(i-1).textColor == "#000000"&&chatModel.get(i).textColor == "#960f133d")||
                            (chatModel.get(i).textColor == "#000000"&&chatModel.get(i-1).textColor == "#960f133d") ?
                                facade.toPx(50): facade.toPx(20))
                contextDialog.menu = 1;
                contextDialog.action=0;
                select=[];
            }
            if(contextDialog.action==3)
            event_handler.copyText(chatModel.get(select[select.length-1]).someText)
            if(contextDialog.action==8) {
                loader.chats[menuDrawer.cindex].message=[]
                chatModel.clear()
                select=[];
            }
        }
    }

    function parseToJSON(message, phone, ip) {
        var JSONobj
        return JSON.stringify(JSONobj = {message: message, phone:phone,/*ip:ip*/});
    }

    function appendMessage(newmessage, flag) {
        chatModel.append({
            someText: newmessage,
            myheight: buferText.contentHeight,
            mySpacing: (chatModel.count > 0?
                          ((chatModel.get(chatModel.count - 1).textColor == "#000000" && flag === 0)||
                           (chatModel.get(chatModel.count - 1).textColor == "#960f133d" && flag == 1)?
                               facade.toPx(50): facade.toPx(20)): facade.toPx(20)),
            textColor: (flag == 0)? "#960f133d":"#000000",
            backgroundColor:(flag==0)?"#ECECEC":"#DBEEFC",
            HorizonPosition: facade.toPx(30)+flag*(parent.width/4-facade.toPx(60)),
            image: flag === 0? "ui/chat/leFtMessage.png": "ui/chat/rightMessag.png"
        });
        if(flag == 0) event_handler.sendMsgs(parseToJSON(newmessage,loader.tel,0));
    }

    Component.onCompleted:menuDrawer.getMePeers()

    ListView {
        id: chatScreenList

        width:parent.width
        anchors {
            top:parent.top
            bottom:flickTextArea.top
            topMargin:partnerHeader.height+facade.toPx(10)
        }

        displayMarginBeginning: {parent.height/2}

        model: ListModel {
            id: chatModel;
        }
        delegate: Item {
            height: (facade.toPx(65) - myheight>= 0)?
                     mySpacing + facade.toPx(65):
                     mySpacing + facade.doPx(26)+ myheight
            Image {
                source: image
                anchors.bottom: parent.bottom
                width: facade.toPx(sourceSize.width * 1.2)
                height:facade.toPx(sourceSize.width * 1.2)
                y: parentText.y + parentText.height-height
                x: (parentText.x == facade.toPx(30))?
                        parentText.x - width/2:
                            parentText.x +parentText.width - width/2
            }
            DropShadow {
                radius: 30
                samples: 30
                anchors {
                    fill:parentText
                }
                color: "#80000000";
                source: parentText;
            }
            TextArea {
                id: parentText
                text: someText
                readOnly: true
                leftPadding: facade.toPx(25);
                rightPadding:facade.toPx(25);

                background: Rectangle {
                    color: backgroundColor
                    radius: parentText.leftPadding;

                    MouseArea {
                    anchors.fill: {parent}
                    onClicked: {
                        var p= 0
                        if (select.length > 0) {
                            p=select.indexOf(index)
                            if (p >= 0)
                            select.splice(p,1)
                            else {
                            select.push(index)
                            contextDialog.menu = 0;
                            parent.color ="#FFDC86"
                            return
                            }
                        }
                        parent.color=backgroundColor
                        if (select.length < 1)
                            contextDialog.menu = 1;
                        }
                        onPressAndHold: {
                            select.push(index)
                            contextDialog.menu = 0;
                            parent.color ="#FFDC86"
                        }
                    }
                }

                wrapMode: {TextEdit.Wrap;}
                width: 3*rootChat.width/4;
                height: (facade.toPx(65)- myheight >= 0)?
                         facade.toPx(65): myheight + facade.doPx(26)

                font {
                family:trebu4etMsNorm.name
                pixelSize: facade.doPx(26)
                }

                verticalAlignment: Text.AlignVCenter
                anchors.bottom: {
                    parent.bottom
                }
                color: textColor;
                x:HorizonPosition
            }
        }
    }

    Rectangle {
        anchors {
            top:flickTextArea.top
            bottom:parent.bottom;
            right:parent.right
            left:parent.left
        }
        radius:facade.toPx(25)
    }

    DropShadow {
        radius: 40
        samples: 40
        anchors {
            fill:flickTextArea
        }
        color: "#80000000";
        source: flickTextArea;
    }
    Row {
        clip:true
        id: flickTextArea;
        spacing: facade.toPx(20);
        anchors {
            bottomMargin: input?rootChat.height*0.45:facade.toPx(25)
            horizontalCenter: parent.horizontalCenter
            bottom:parent.bottom;
        }

        Flickable {
            width: rootChat.width-chatScreenButton.width-facade.toPx(50);
            height: (screenTextFieldPost.lineCount < 5)? facade.toPx(70)+
                    (screenTextFieldPost.lineCount - 1)* facade.doPx(33):
                     facade.toPx(70)+4*facade.doPx(33);

            flickableDirection:Flickable.VerticalFlick;

            TextArea.flickable:TextArea
            {
                property bool pressCtrl
                property bool pressEntr
                id: screenTextFieldPost
                wrapMode: TextEdit.Wrap
                verticalAlignment: {Text.AlignVCenter;}
                placeholderText: "Написать...";
                leftPadding: (facade.toPx(25));
                rightPadding:(facade.toPx(25));
                font {
                    pixelSize: facade.doPx(26);
                    family: trebu4etMsNorm.name
                }
                background: Rectangle {
                    border {
                        color:"#C8C8C8"
                        width:2
                    }
                }
                Keys.onReturnPressed: {
                    pressCtrl = true;
                    event.accepted = false;
                }
                Keys.onPressed: {
                    if (event.key == Qt.Key_Control)
                        pressEntr =true
                }
                Keys.onReleased: {
                    if (event.key == Qt.Key_Control
                     || event.key == Qt.Key_Return) {
                        if (pressCtrl && pressEntr) {
                            checkMessage(0)
                        }
                    }
                    pressCtrl = false
                    pressEntr = false
                }
            }
        }
        Button {
            contentItem: Text {
                elide:Text.ElideRight
                color:parent.down? "#0f133d": "#7680B1"
                verticalAlignment: {Text.AlignVCenter;}
                horizontalAlignment:Text.AlignHCenter;
            }
            Image {
            id: buttonImage
            source:"ui/buttons/sendButton.png"
            height:facade.toPx(sourceSize.height* 1.5);
            width: facade.toPx(sourceSize.width * 1.5);
            }
            background: Rectangle {opacity: 0}
            onClicked:checkMessage(0)
            width: buttonImage.width;
            height:buttonImage.height
            id:chatScreenButton
        }
    }
}
