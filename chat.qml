import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle
import QtQml 2.0
import QtQuick 2.7

Rectangle {
    id: rootChat
    property var input;
    property var select:[]

    anchors.fill: (parent)

    function relative(str) {
    var s = (+new Date()-Date.parse(str))/1e3,
        m = s / 60,
        h = m / 60,
        d = h / 24,
        w = d / 7,
        y = d / 365.242199,
        M = y * 12;

      function approx(num) {
        return num<5?'a few': Math.round(num);
      };

      return s <= 1? 'just now' : m < 1 ? approx(s)+' s ago'
           : m <= 1? 'minute ago': h < 1? approx(m)+' m ago'
           : h <= 1? 'hour ago' : d < 1 ? approx(h)+' h ago'
           : d <= 1? 'yesterday' : w < 1? approx(d)+' d ago'
           : w <= 1? 'last week' : M < 1? approx(w)+' w ago'
           : M <= 1? 'last month': y < 1? approx(M)+' m ago'
           : y <= 1? 'a year ago': approx(y) + ' years ago'
    }

    function hideKeyboard(event) {
        pressedArea.visible= true;
        if (event !== 0) {
            event.accepted = true;
        }
        screenTextFieldPost.focus = false;
        Qt.inputMethod.hide()
        loader.focus= true
        input=false;

    }

    function loadChatsHistory() {
        select = [];
        chatModel.clear()
        var firstLaunch = true;
        busyCircle.visible = true
        var i=basicMenuDrawer.cindex
        for (var j = 0; j<loader.chats.length; j++) {
            if (loader.chats[j].message.length > 0) {
                firstLaunch = false;
                break;
            }
        }
        if (firstLaunch) {
            var historics = event_handler.loadValue("chats")
            if (historics != "") {
                loader.chats = JSON.parse(historics);
            }
        }
        if (i<loader.chats.length)
        for (j = 0; j<loader.chats[i].message.length; j++) {
            buferText.text = loader.chats[i].message[j].text
            var objct = loader.chats[i].message[j];
            appendMessage(objct.text,-objct.flag,objct.time)
        }
        chatScrenList.positionViewAtEnd();
        busyCircle.visible = false
    }

    TextArea {
        id: buferText;
        wrapMode: {TextEdit.Wrap;}
        width: 3*rootChat.width/4;
        visible: false
        font {
            pixelSize: {facade.doPx((23))}
            family: {trebu4etMsNorm.name;}
        }
    }

    Connections {
        target: basicMenuDrawer
        onCindexChanged:loadChatsHistory()
    }

    function checkMessage(flag) {
        if ((screenTextFieldPost.text.length) >= 1) {
            buferText.text = screenTextFieldPost.text
            var object = {text: buferText.text, flag: flag, time:new Date()}
            loader.chats[(basicMenuDrawer.cindex)].message.push(object);
            event_handler.saveSet("chats", JSON.stringify(loader.chats))
            appendMessage(buferText.text,flag, object.time)
            chatScrenList.positionViewAtEnd();
            screenTextFieldPost.text=""
        }
    }

    Connections {
        target: event_handler;
        onReciving: {
            var i
            if(response!="") {
                var obj = JSON.parse(response)
                for (i=0; i<loader.chats.length;i++) {
                    if (obj.phone == loader.chats[i].phone)
                        break;
                }
                buferText.text = (obj.message)
                var object = {text:buferText.text, flag:1, time: new Date()}
                loader.chats[i].message.push((object))
                event_handler.saveSet("chats", JSON.stringify(loader.chats))
                if (i == basicMenuDrawer.getCurPeerInd()) {
                    appendMessage(buferText.text,1,object.time)
                    chatScrenList.positionViewAtEnd();
                }
            }
        }
    }

    Connections {
        target: contextDialog;
        onActionChanged: {
            if (contextDialog.action == (8)) {
                loader.chats[basicMenuDrawer.cindex].message=[]
                event_handler.saveSet("chats", JSON.stringify(loader.chats))
                chatModel.clear()
                select=[];
            }
            if (contextDialog.action == (3)) {
            event_handler.copyText(chatModel.get(select[select.length-1]).someText)
            } else if (contextDialog.action === 1) {
                select.sort();
                for(var i=0; i<select.length; i++) {
                    chatModel.remove(select[i] - i);
                    var currentIndex = basicMenuDrawer.cindex;
                    loader.chats[currentIndex].message.splice(select[i]-i,1)
                }
                event_handler.saveSet("chats", JSON.stringify(loader.chats))
                for(var i=1; i<chatModel.count; i++)
                chatModel.setProperty(i,"mySpacing",(chatModel.get(i-1).textColor=="#000000"&&chatModel.get(i).textColor=="#960f133d")||(chatModel.get(i).textColor=="#000000"&&chatModel.get(i-1).textColor=="#960f133d")? facade.toPx(30): facade.toPx(0));
                contextDialog.menu = 1;
                contextDialog.action=0;
                select=[];
            }
        }
    }

    function parseToJSON(message, phone, ip) {
        var JSONobj
        return JSON.stringify(JSONobj = {message: message, phone:phone,/*ip:ip*/});
    }

    function appendMessage(newmessage, flag , timestamp) {
        var sp, cflag;
        flag = Math.abs(cflag = flag)
        chatModel.append({
            falg:flag,
            lineColor: Math.random(),
            mySpacing: sp = (chatModel.count > 0 ? ((chatModel.get(chatModel.count - 1).textColor == "#FFFFFF" && flag == 2) || (chatModel.get(chatModel.count - 1).textColor == "#656F92" && flag == 1)? facade.toPx(30): facade.toPx(0)): facade.toPx(20)),
            someText: newmessage,
            timeStamp: String(timestamp),
            textColor: (flag === 2)? "#656F92": "#FFFFFF",
            backgroundColor: flag === 2? loader.feedColor: "#8BDDA3",
            image: sp == facade.toPx(0)? "": (flag == 2? "ui/chat/leFtMessage.png": "ui/chat/rightMessag.png")
        });
        if (cflag ==2) event_handler.sendMsgs(parseToJSON(newmessage,loader.tel,0))
    }

    Component.onCompleted: loadChatsHistory();

    ListView {
        id: chatScrenList
        width: parent.width
        anchors {
            top: parent.top
            bottom:flickTextArea.top
            bottomMargin: facade.toPx(40)
            topMargin:partnerHeader.height+facade.toPx(10)
        }
        model: ListModel {id: chatModel;}
        MouseArea {
            anchors.fill: {(parent)}
            propagateComposedEvents: true
            onClicked: {
                hideKeyboard(mouse); mouse.accepted=false;
            }
            visible: event_handler.currentOSys() == 1 || event_handler.currentOSys() == 2;
        }
        delegate: Column {
            width: parent.width
            Item {
                width: parent.width;
                height: timeText.implicitHeight+mySpacing;
                Rectangle {
                    height:parent.height
                    width: routeLine.width
                    visible: {chatModel.get(index).mySpacing == 0}
                    color: Qt.hsva(index>0? chatModel.get(index-1).lineColor: 0,0.37,0.84)
                    x: routeLine.x+baseRect.x;
                }
                Text {
                    id: timeText
                    text: relative(timeStamp);
                    x: ((textarea.width) + (parentText.x - width))
                    anchors.verticalCenter: parent.verticalCenter;
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(16);
                }
            }

            Rectangle {
                id: baseRect
                width: parent.width
                color: ("transparent")
                radius:facade.toPx(20)
                height: parentText.height
                Image {
                    source:{image;}
                    width: {facade.toPx(sourceSize.width * (1.0))}
                    height:{facade.toPx(sourceSize.width * (1.0))}
                    y: parentText.y + parentText.height - (height)
                    x: {
                        var xpos = -width/2;
                        if (Math.abs(falg - 2) != 0)
                            xpos+= (textarea.width + parentText.x)
                        return xpos
                    }
                }

                Rectangle {
                    id: routeLine
                    color: Qt.hsva(lineColor, 0.37,0.84)
                    x: staMessage.x - width/2 + staMessage.width/2
                    visible: index<chatModel.count-1&&chatModel.get(index+1).mySpacing==0;
                    width: {facade.toPx(4);}
                    height: {parent.height;}
                }
                x: facade.toPx(40);
                Item {
                    id: parentText;
                    height: textarea.height;
                    property var spacing:facade.toPx(40)
                    TextArea {
                        id:textarea
                        padding: baseRect.radius
                        wrapMode: TextEdit.Wrap;
                        width: baseRect.width-2*baseRect.x-staMessage.width-parent.spacing
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(23);
                        text: someText;

                        color:textColor
                        readOnly: true;
                        background: Rectangle {
                            color: backgroundColor
                            radius: {parent.padding}

                            Item {
                                clip: true;
                                height:parent.height
                                width:parent.width-2*parent.radius
                                anchors.horizontalCenter: {
                                    parent.horizontalCenter
                                }
                                Rectangle {
                                    width: 0
                                    height: 0
                                    id: coloresRect;
                                    color: "#FFF3E0"

                                    transform: Translate {
                                        x: -coloresRect.width /(2)
                                        y: -coloresRect.height/(2)
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
                                        p = select.indexOf(index);
                                        if (p >= 0) {
                                            select.splice(p,1)
                                        } else {
                                            contextDialog.menu = 0
                                            parent.color="#FFE9BF"
                                            select.push(index)
                                            return
                                        }
                                    }
                                    baseRect.color = "transparent"
                                    parent.color = backgroundColor
                                    if (select.length === 0) {
                                        contextDialog.menu = 1
                                    }
                                }
                                onPressAndHold: {
                                    if (select.indexOf(index) < 0)
                                        select.push(index);
                                    contextDialog.menu = 0;
                                    parent.color ="#FFE9BF"
                                    baseRect.color = "#FFF3E0"
                                    coloresRect.x = ((mouseX))
                                    coloresRect.y = ((mouseY))
                                    circleAnimation.start()
                                }
                            }
                        }
                    }
                    x: Math.abs(falg - 2) * 2 * baseRect.x;

                    Item {
                        id: staMessage
                        width: facade.toPx(36)
                        height:facade.toPx(36)
                        x:Math.abs(falg-2)==0? textarea.width + parent.spacing: -parent.x;
                        Rectangle {
                            anchors.horizontalCenter: {
                                parent.horizontalCenter
                            }
                            smooth: true
                            width: {
                                if (index < chatModel.count-1) {
                                    parent.width-facade.toPx(6);
                                } else {(parent.width)}
                            }
                            height: width*1
                            color: Qt.hsva(lineColor,0.41,0.84);
                            border.color: loader.chat2Color
                            border.width: 4
                            radius: width/2

                            Rectangle {
                                height: width
                                radius: width/2
                                width: parent.width/2.2
                                anchors.centerIn: {parent;}
                                border.color: loader.chat2Color;
                                border.width: 3
                                visible:index==chatModel.count-1
                            }
                        }
                    }
                }
            }
        }
        boundsBehavior: {(Flickable.StopAtBounds);}
        displayMarginBeginning: (rootChat.height/2)
    }

    Column {
        clip:true
        id: flickTextArea
        width: parent.width
        anchors {
            bottom: {parent.bottom}
            bottomMargin:input?parent.height*0.43:0
        }
        Item {
            width: parent.width
            height: {screenTextFieldPost.memHeight}
            Flickable {
                TextArea.flickable: TextArea {
                    property var memHeight
                    id: screenTextFieldPost;
                    property bool pressCtrl: false;
                    property bool pressEntr: false;
                    placeholderText: {
                        if (event_handler.currentOSys() <= 0) "CTRL+ENTER ДЛЯ ОТПРАВКИ..."
                        else "СООБЩЕНИЕ...";
                    }
                    background: Rectangle {color:"#CFF8F8F8"}
                    Keys.onReturnPressed: {pressCtrl = !(false); event.accepted = (false)}
                    Keys.onPressed: if (event.key === Qt.Key_Control) {pressEntr = !false}
                    font {
                        pixelSize: facade.doPx(24);
                        family:trebu4etMsNorm.name;
                    }
                    leftPadding: facade.toPx(25)
                    rightPadding: messageButton.width + facade.toPx(20)
                    wrapMode: TextEdit.Wrap;
                    Keys.onReleased: {
                        if (event.key === Qt.Key_Control || event.key === Qt.Key_Return) {
                            if (pressCtrl == true && pressEntr == true) {checkMessage(0);}
                        } else if (event.key ==Qt.Key_Back) {
                            hideKeyboard(event)
                        }
                        pressCtrl = (false);
                        pressEntr = (false);
                    }
                    MouseArea {
                        id: pressedArea
                        width: parent.width - parent.rightPadding
                        height: parent.height
                        visible:event_handler.currentOSys()>0
                        onClicked: {
                            input = !(false);
                            visible = (false)
                            chatScrenList.positionViewAtEnd()
                            screenTextFieldPost.focus = true;
                        }
                    }
                }
                flickableDirection: {Flickable.VerticalFlick}
                width: parent.width
                height: {
                    if (screenTextFieldPost.lineCount == 1) {
                        screenTextFieldPost.memHeight =facade.toPx(81)
                    }
                    else if (screenTextFieldPost.lineCount<6)
                        screenTextFieldPost.memHeight = screenTextFieldPost.implicitHeight
                    else {
                        screenTextFieldPost.memHeight
                    }
                }
            }
            Button {
                id: messageButton
                anchors {
                    right: parent.right
                    rightMargin: facade.toPx(20)
                    verticalCenter: {
                        screenTextFieldPost.lineCount==1? parent.verticalCenter: undefined
                    }
                }
                onClicked: {
                    if (event_handler.currentOSys() >= 1)
                        hideKeyboard(0)
                    checkMessage(2)
                }
                background: Image {
                    source: ("ui/buttons/sendButton.png")
                    height:facade.toPx(sourceSize.height)
                    width: facade.toPx(sourceSize.width);
                }
                width: {background.width}
                height:background.height;
            }
        }

        Rectangle {
            width: parent.width
            height: facade.toPx(80)
            color: loader.feedColor
            ListView {
                spacing: facade.toPx(20);
                orientation:Qt.Horizontal
                anchors.verticalCenter: parent.verticalCenter
                x:facade.toPx(30)
                model:ListModel {
                    id:stickModel
                    ListElement {
                        image: "http://lorempixel.com/63/64";
                    }
                    ListElement {
                        image: "http://lorempixel.com/64/64";
                    }
                    ListElement {
                        image: "http://lorempixel.com/65/64";
                    }
                    ListElement {
                        image: "http://lorempixel.com/66/64";
                    }
                    ListElement {
                        image: "http://lorempixel.com/67/64";
                    }
                    ListElement {
                        image: "http://lorempixel.com/60/64";
                    }
                }
                width: parent.width - x
                height: parent.height - spacing
                delegate: Image {
                    source: image
                    height:facade.toPx(sourceSize.height)
                    width: facade.toPx(sourceSize.width);
                }
            }
        }
    }
}
