import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle
import QtQml 2.0
import QtQuick 2.7

Rectangle {
    id: rootChat

    TextArea {
        id: buferText;
        wrapMode: {TextEdit.Wrap;}
        width: 3*rootChat.width/4;
        visible: false
        font {
            pixelSize: {facade.doPx((26))}
            family: {trebu4etMsNorm.name;}
        }
    }

    function hideKeyboard(event) {
        pressedArea.visible= true;
        if (event !== 0) {
            event.accepted = true;
        }
        screenTextFieldPost.focus = false;
        Qt.inputMethod.hide()
        loader.focus= true
        input = false
    }

    Connections {
        target: menuDrawer
        onCindexChanged:loadChatsHistory()
    }

    function loadChatsHistory() {
        var firstLaunch = true;
        for (var j = 0; j<loader.chats.length; j++) {
            if (loader.chats[j].message.length > 0) {
                firstLaunch= false
                break;
            }
        }

        if (firstLaunch) {
            var historics = event_handler.loadValue("chats")
            if (historics != "") {
                loader.chats = JSON.parse(historics);
            }
        }
        select = [];
        busyIndicator.visible=true
        chatModel.clear();
        var i = menuDrawer.cindex;
        for (j = 0; j<loader.chats[i].message.length; j++) {
            buferText.text = loader.chats[i].message[j].text
            appendMessage(loader.chats[i].message[j].text, (loader.chats[i].message[j].flag), loader.chats[i].message[j].time)
        }
        busyIndicator.visible=!busyIndicator.visible;
    }

    function checkMessage(flag) {
        if ((screenTextFieldPost.text.length) >= 1) {
            buferText.text = screenTextFieldPost.text
            var time= new Date().toLocaleTimeString(Qt.locale(), Locale.LongFormat)
            loader.chats[menuDrawer.cindex].message.push({text: buferText.text,flag: flag,time: time})
            event_handler.saveSet("chats", JSON.stringify(loader.chats))

            appendMessage(buferText.text, flag, time)
            chatScreenList.positionViewAtEnd()
            screenTextFieldPost.text = "";
        }
    }

    Connections {
        target: event_handler;
        onReciving: {
            var i
            if(response!="") {
                var obj = JSON.parse(response)
                for (i=0; i<loader.chats.length;i++) {
                if(obj.phone==loader.chats[i].phone)
                    break
                }
                var time=new Date().toLocaleString(Qt.locale(), Locale.ShortFormat)
                loader.chats[i].message.push({text: buferText.text = (obj.message),flag:1,time: time})
                event_handler.saveSet("chats", JSON.stringify(loader.chats))
                if (i == menuDrawer.getCurPeerInd()) {
                    appendMessage((buferText.text), 1, time)
                    chatScreenList.positionViewAtEnd()
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
                event_handler.saveSet("chats", JSON.stringify(loader.chats))
                for(var i=1; i<chatModel.count; i++)
                    chatModel.setProperty(i, "mySpacing",
                            (chatModel.get(i-1).textColor == "#000000"&&chatModel.get(i).textColor=="#960f133d")||
                            (chatModel.get(i).textColor == "#000000"&&chatModel.get(i-1).textColor=="#960f133d") ?
                                facade.toPx(60): facade.toPx(30))
                contextDialog.menu = 1;
                contextDialog.action=0;
                select=[];
            }
            if(contextDialog.action==3)
            event_handler.copyText(chatModel.get(select[select.length-1]).someText)
            if(contextDialog.action==8) {
                loader.chats[menuDrawer.cindex].message=[]
                event_handler.saveSet("chats", JSON.stringify(loader.chats))
                chatModel.clear()
                select=[];
            }
        }
    }

    function parseToJSON(message, phone, ip) {
        var JSONobj
        return JSON.stringify(JSONobj = {message: message, phone:phone,/*ip:ip*/});
    }

    function appendMessage(newmessage, flag, timestamp) {
        chatModel.append({
            falg: flag,
            myheight: buferText.contentHeight,
            mySpacing: (chatModel.count >= 1 ?
                          ((chatModel.get(chatModel.count - 1).textColor == "#000000" && flag === 0)||
                           (chatModel.get(chatModel.count - 1).textColor == "#960f133d" && flag == 1)?
                               facade.toPx(60): facade.toPx(30)): facade.toPx(20)),
            someText: newmessage,
            timeStamp: timestamp,
            textColor: (flag == 0)? "#960f133d":"#000000",
            backgroundColor:(flag==0)?"#ECECEC":"#DBEEFC",
            image: flag === 0? "ui/chat/leFtMessage.png": "ui/chat/rightMessag.png"
        });
        if(flag == 0) event_handler.sendMsgs(parseToJSON(newmessage,loader.tel,0));
    }

    property bool input

    Component.onCompleted: loadChatsHistory()

    ListView {
        id: chatScreenList;
        width: parent.width
        anchors {
            top: parent.top
            bottom: flickTextArea.top
            bottomMargin: facade.toPx(40)
            topMargin:partnerHeader.height+facade.toPx(10)
        }
        boundsBehavior:Flickable.StopAtBounds
        MouseArea {
            anchors.fill: {(parent);}
            propagateComposedEvents: {(true)}
            onClicked: {
                hideKeyboard(mouse); mouse.accepted=false;
            }
            visible: event_handler.currentOSys()==1||event_handler.currentOSys()==2
        }

        displayMarginBeginning: {(rootChat.height/2);}

        model: ListModel {id:chatModel}
        delegate: Item {
            width: parent.width
            height: facade.toPx(65) - myheight >= 0? mySpacing+facade.toPx(65): mySpacing+facade.doPx(26)+myheight
            Column {
                width: {(parent.width)}
                anchors.bottom: {parent.bottom}
                Text {
                    color: {textColor;}
                    anchors {
                        right: {(parent.right)}
                        rightMargin: {facade.toPx(20)}
                    }
                    font.family: {trebu4etMsNorm.name}
                    font.pixelSize: {facade.doPx(16);}
                    text: timeStamp? timeStamp: "NaN";
                }
                Rectangle {
                    id: baseRect
                    x: facade.toPx(30);
                    width: parent.width
                    color:"transparent"
                    radius: facade.toPx(25)
                    height: {parentText.height}
                    Image {
                        source:{image;}
                        width: {facade.toPx(sourceSize.width * (1.2))}
                        height:{facade.toPx(sourceSize.width * (1.2))}
                        y: parentText.y + parentText.height - (height)
                        x: parentText.x === 0? parentText.x - width/2: (parentText.x + parentText.width - width/2)
                    }
                    Row {
                        id: parentText;
                        spacing:facade.toPx(20)
                        x:falg*(parent.parent.width/4-facade.toPx(60))
                        TextArea {
                            text: someText;
                            readOnly: true;
                            leftPadding: {baseRect.radius}
                            rightPadding: facade.toPx(25);

                            background: Rectangle {
                                color:backgroundColor
                                radius: parent.leftPadding

                                Item {
                                    clip: true;
                                    height: parent.height;
                                    width:parent.width-2*parent.radius
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    Rectangle {
                                        width: 0
                                        height: 0
                                        id: coloresRect;
                                        color: "#FFF3E0"

                                        transform: Translate {
                                            x: -coloresRect.width / 2;
                                            y: -coloresRect.height/ 2;
                                        }
                                    }
                                }

                                PropertyAnimation {
                                    duration: 500
                                    target: coloresRect;
                                    id: circleAnimation;
                                    properties:("width,height,radius")
                                    from: 0
                                    to: parent.width* 3;

                                    onStopped: {
                                        coloresRect.width  = 0;
                                        coloresRect.height = 0;
                                    }
                                }

                                MouseArea {
                                    anchors.fill: {parent}
                                    onClicked: {
                                        var p= 0
                                        if (select.length>0) {
                                            p=select.indexOf(index)
                                            if (p >= 0)
                                                select.splice(p, 1)
                                            else {
                                                contextDialog.menu = 0
                                                parent.color="#FFE9BF"
                                                select.push(index);
                                                return
                                            }
                                        }
                                        baseRect.color = "transparent"
                                        parent.color = backgroundColor
                                        if (select.length === 0) {
                                            contextDialog.menu = 1;
                                        }
                                    }
                                    onPressAndHold: {
                                        select.push(index)
                                        contextDialog.menu = 0;
                                        parent.color ="#FFE9BF"
                                        baseRect.color = "#FFF3E0";
                                        coloresRect.x = mouseX;
                                        coloresRect.y = mouseY;
                                        circleAnimation.start()
                                    }
                                }
                            }

                            verticalAlignment:Text.AlignVCenter
                            color:textColor

                            wrapMode: {TextEdit.Wrap}
                            width: {parent.parent.width * 3/4;}
                            height:(facade.toPx(65) - myheight >= 0)? facade.toPx(65): myheight + facade.doPx(26);

                            font.family: {trebu4etMsNorm.name;}
                            font.pixelSize: {facade.doPx((26))}
                        }
                        Image {
                            smooth: true
                            source: ("/ui/chat/unreadMsgs.png")
                            height: facade.toPx(sourceSize.height)
                            width:facade.toPx(sourceSize.width)
                        }
                    }
                }
            }
        }
    }

    /*
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: flickTextArea.top;
        }
        radius: facade.toPx(25)
        MouseArea {
            visible: {event_handler.currentOSys() === 1 || event_handler.currentOSys() === 2}
            anchors.fill:parent
            onClicked: hideKeyboard(mouse)
            propagateComposedEvents: true;
        }
    }
    */

    DropShadow {
        radius: 30
        samples: 40
        anchors.fill:flickTextArea
        source: flickTextArea
        color: "#80000000"
    }
    Row {
        clip:true
        id: flickTextArea;
        spacing: {facade.toPx(20)}
        anchors {
            bottomMargin: input?parent.height * 0.45: facade.toPx(10)
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom;
        }

        Flickable {
            TextArea.flickable:TextArea{
                id: screenTextFieldPost;
                wrapMode: TextEdit.Wrap;

                property bool pressCtrl: false;
                property bool pressEntr: false;

                background: Rectangle {}
                font.pixelSize: facade.doPx(26)
                font.family:trebu4etMsNorm.name
                verticalAlignment: Text.AlignVCenter;

                placeholderText: event_handler.currentOSys() === 0? ("Ctrl+Enter для отправки..."): "Написать...";

                leftPadding: (facade.toPx(25));
                rightPadding:(facade.toPx(25));

                Keys.onReturnPressed: {
                    pressCtrl = true;
                    event.accepted = false;
                }
                Keys.onPressed: {
                    if (event.key ==Qt.Key_Control) {
                        pressEntr =true
                    }
                }
                Keys.onReleased: {
                    if (event.key == Qt.Key_Control
                     || event.key == Qt.Key_Return) {
                        if (pressCtrl && pressEntr) {
                            checkMessage(0)
                        }
                    }
                    else if(event.key==Qt.Key_Back) {
                        hideKeyboard(event)
                    }

                    pressCtrl = false
                    pressEntr = false
                }

                MouseArea {
                    id: pressedArea;
                    anchors.fill:parent
                    visible: event_handler.currentOSys()==1 || event_handler.currentOSys()==2
                    onClicked: {
                        input = true
                        visible = false
                        screenTextFieldPost.focus=true;
                    }
                }
            }

            width: rootChat.width-chatScreenButton.width-facade.toPx(50);
            height: (screenTextFieldPost.lineCount < 5)? facade.toPx(90)+
                    (screenTextFieldPost.lineCount - 1)* facade.doPx(34):
                     facade.toPx(90)+4*facade.doPx(34);
            flickableDirection:Flickable.VerticalFlick;
        }
        Button {
            contentItem: Text {
                elide:Text.ElideRight
                color:parent.down? "#0f133d": "#7680B1"
                verticalAlignment: {Text.AlignVCenter;}
                horizontalAlignment:{Text.AlignHCenter}
            }
            Image {
            id: buttonImage
            source:"ui/buttons/sendButton.png"
            height:facade.toPx(sourceSize.height* 1.5);
            width: facade.toPx(sourceSize.width * 1.5);
            }
            onClicked: {
                checkMessage(0)
                if (event_handler.currentOSys() === 1 || event_handler.currentOSys() === 2) {
                    hideKeyboard(0)
                }
            }
            background: Rectangle {opacity: 0}
            width: buttonImage.width;
            height:buttonImage.height
            id:chatScreenButton
        }
    }
    anchors.fill: (parent);
    property var select: []
}
