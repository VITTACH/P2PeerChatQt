import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle
import QtQml 2.0
import QtQuick 2.7

Rectangle {
    id: rootChat
    property var input
    property int pageWidth
    property var select:[]

    anchors.fill: (parent)

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
        target: basicMenuDrawer
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
        busyCircle.visible = true
        chatModel.clear();
        var i = basicMenuDrawer.cindex;
        if (i < loader.chats.length)
        for (j = 0; j<loader.chats[i].message.length; j++) {
            buferText.text = loader.chats[i].message[j].text
            appendMessage(loader.chats[i].message[j].text, (loader.chats[i].message[j].flag), loader.chats[i].message[j].time)
        }
        busyCircle.visible=false;
    }

    function checkMessage(flag) {
        if ((screenTextFieldPost.text.length) >= 1) {
            buferText.text = screenTextFieldPost.text
            var time= new Date().toLocaleTimeString(Qt.locale(), Locale.LongFormat)
            var i = basicMenuDrawer.cindex
            loader.chats[i].message.push({text:buferText.text,flag:flag,time:time})
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
                if (i == basicMenuDrawer.getCurPeerInd()) {
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
                    var currentIndex = basicMenuDrawer.cindex;
                    loader.chats[currentIndex].message.splice(select[i]-i,1)
                }
                event_handler.saveSet("chats", JSON.stringify(loader.chats))
                for(var i=1; i<chatModel.count; i++)
                chatModel.setProperty(i,"mySpacing",(chatModel.get(i-1).textColor=="#000000"&&chatModel.get(i).textColor=="#960f133d")||(chatModel.get(i).textColor=="#000000"&&chatModel.get(i-1).textColor=="#960f133d")? facade.toPx(60): facade.toPx(30));
                contextDialog.menu = 1;
                contextDialog.action=0;
                select=[];
            }
            if(contextDialog.action==3)
            event_handler.copyText(chatModel.get(select[select.length-1]).someText)
            if(contextDialog.action==8) {
                loader.chats[basicMenuDrawer.cindex].message=[]
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

    function appendMessage(newmessage, flag , timestamp) {
        var sp;
        chatModel.append({
            falg: flag,
            mySpacing:sp = (chatModel.count>0 ? ((chatModel.get(chatModel.count - 1).textColor == "#000000" && flag == 0) || (chatModel.get(chatModel.count - 1).textColor == "#960f133d" && flag == 1)? facade.toPx(60): facade.toPx(30)): facade.toPx(20)),
            someText: newmessage,
            timeStamp: timestamp,
            textColor: (flag == 0)? "#960f133d":"#000000",
            backgroundColor:flag == 0?"#ECECEC":"#DBEEFC",
            image: flag == 0? (sp == facade.toPx(30)?"":"ui/chat/leFtMessage.png"): (sp == facade.toPx(30)? "": "ui/chat/rightMessag.png")
        });
        if(flag == 0) event_handler.sendMsgs(parseToJSON(newmessage,loader.tel,0));
    }

    Component.onCompleted: loadChatsHistory();

    ListView {
        id: chatScreenList;
        width: parent.width
        anchors {
            top: parent.top
            bottom:flickTextArea.top
            bottomMargin: facade.toPx(40)
            topMargin:partnerHeader.height+facade.toPx(10)
        }
        MouseArea {
            anchors.fill: {(parent)}
            propagateComposedEvents: true
            onClicked: {
                hideKeyboard(mouse); mouse.accepted=false;
            }
            visible: event_handler.currentOSys()==1||event_handler.currentOSys()==2
        }

        boundsBehavior: Flickable.StopAtBounds
        displayMarginBeginning: rootChat.height/2;

        model: ListModel {id: chatModel;}
        delegate: Column {
            width: parent.width
            Text {
                color: {(textColor)}
                anchors {
                    right: {parent.right}
                    rightMargin: {facade.toPx(20)}
                }
                font.family: {trebu4etMsNorm.name}
                font.pixelSize: {facade.doPx(16);}
                text: timeStamp? timeStamp: "NaN";
            }
            Rectangle {
                id: baseRect
                x: facade.toPx(30)
                width: parent.width;
                color: "transparent"
                radius: facade.toPx((20))
                height: parentText.height
                Image {
                    source:{image;}
                    width: {facade.toPx(sourceSize.width * (1.2))}
                    height:{facade.toPx(sourceSize.width * (1.2))}
                    y: parentText.y + parentText.height - (height)
                    x: parentText.x === 0? parentText.x - width/2: (parentText.x + parentText.width - width/2)
                }
                Row {
                    id: parentText;
                    spacing: facade.toPx(20)
                    x:falg*(parent.parent.width/4-facade.toPx(60))
                    TextArea {
                        text: someText;
                        readOnly: true;
                        padding:baseRect.radius

                        background: Rectangle {
                            color: backgroundColor
                            radius: {parent.padding}

                            Item {
                                clip: true;
                                height:parent.height
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
                                    if(select.length > 0) {
                                        p=select.indexOf(index)
                                        if (p >= 0) {
                                            select.splice(p, 1)
                                        } else {
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
                                    if(select.indexOf(index)<0)
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

                        color:textColor
                        wrapMode: {TextEdit.Wrap}
                        width: {parent.parent.width * 3/4;}

                        font.family: {trebu4etMsNorm.name;}
                        font.pixelSize: {facade.doPx((26))}
                    }
                    Image {
                        smooth: true
                        source: ("/ui/chat/unreadMsgs.png")
                        height: facade.toPx(sourceSize.height);
                        width:facade.toPx(sourceSize.width)
                    }
                }
            }
        }
    }

    DropShadow {
        radius: 30
        samples:40
        color: "#80000000"
        source: flickTextArea
        anchors.fill: flickTextArea;
    }
    Column {
        clip:true
        id: flickTextArea
        width: parent.width
        anchors {
            bottom: {parent.bottom;}
            bottomMargin: input==true? parent.height*0.43: 0
        }
        Row {
            spacing: facade.toPx(20)
            anchors.horizontalCenter:parent.horizontalCenter
            Flickable {
                TextArea.flickable:TextArea{
                    id: screenTextFieldPost;
                    property var memHeight
                    property bool pressCtrl: false;
                    property bool pressEntr: false;
                    padding: facade.toPx(25)
                    wrapMode: TextEdit.Wrap;
                    placeholderText: {
                        if (event_handler.currentOSys() < 1) "Ctrl+Enter для отправки..."
                        else {"Написать..."}
                    }
                    background: Rectangle {color:"#A0FFFFFF"}
                    Keys.onReturnPressed: {pressCtrl = !false; event.accepted = (false);}
                    Keys.onPressed: if (event.key === Qt.Key_Control) pressEntr = !false;
                    font {
                        pixelSize: facade.doPx(26);
                        family:trebu4etMsNorm.name;
                    }
                    Keys.onReleased: {
                        if (event.key == Qt.Key_Control || event.key === Qt.Key_Return) {
                            if (pressCtrl == true && pressEntr == true) {checkMessage(0)}
                        } else if(event.key==Qt.Key_Back) hideKeyboard(event)
                        pressCtrl = (false);
                        pressEntr = (false);
                    }
                    MouseArea {
                        id: pressedArea
                        anchors.fill: parent
                        visible:event_handler.currentOSys()>0
                        onClicked: {
                            input = true;
                            visible = false;
                            screenTextFieldPost.focus = true;
                        }
                    }
                }
                flickableDirection: {Flickable.VerticalFlick}
                width: rootChat.width-chatScreenButton.width-facade.toPx(50);
                height: {
                    if (screenTextFieldPost.lineCount <= 1) {facade.toPx(96)}
                    else if (screenTextFieldPost.lineCount<6)
                        screenTextFieldPost.memHeight=screenTextFieldPost.contentHeight
                    else screenTextFieldPost.memHeight
                }
            }
            Button {
                onClicked: {
                    checkMessage(0)
                    if (event_handler.currentOSys() >= 1) {(hideKeyboard(0))}
                }
                background: Image {
                    id:buttonImage;
                    source:"ui/buttons/sendButton.png"
                    height:facade.toPx(sourceSize.height*1.5)
                    width: facade.toPx(sourceSize.width *1.5)
                }
                anchors {
                    bottomMargin: facade.toPx(20)
                    bottom: parent.bottom;
                }
                width: {buttonImage.width}
                height: buttonImage.height
                id:chatScreenButton
            }
        }

        Rectangle {
            width: parent.width
            height:facade.toPx(90)
            ListView {
                x: facade.toPx(30)
                width: parent.width-x
                height: parent.height-x
                spacing: {facade.toPx(20)}
                orientation: Qt.Horizontal
                anchors.verticalCenter: parent.verticalCenter
                model:ListModel {
                    id:stickModel
                    ListElement {
                        image: "ui/buttons/social/fb.png"; target1: "Реклама"
                    }
                    ListElement {
                        image: "ui/buttons/social/gp.png"; target1: "Партнер"
                    }
                    ListElement {
                        image: "ui/buttons/social/tw.png"; target1: "Общайся"
                    }
                    ListElement {
                        image: "ui/buttons/social/vk.png"; target1: "Новости"
                    }
                }
                delegate: Image {
                    source: image
                    width: pageWidth = facade.toPx(sourceSize.width/3.0)
                    height:facade.toPx(sourceSize.height/3.0)
                }
            }
        }
    }
}
