import QtQml 2.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle

Rectangle {
    property bool input;
    property var select;
    anchors.fill:parent;

    color: loader.chat1Color
    Connections {
        target: blankeDrawer
        onCindexChanged: loadChatsHistory()
    }

    function relative(str) {
        var s = (+ new Date() - Date.parse(str))/1e3,
        m = s / 60,
        h = m / 60,
        d = h / 24,
        w = d / 7,
        y = d / 365.242199,
        M = y * 12;

      function approx(num) {
          return num < 5? ('a few'): Math.round(num);
      };

      return s <= 1? 'just now' : m < 1 ? approx(s)+' s ago'
           : m <= 1? 'minute ago': h < 1? approx(m)+' m ago'
           : h <= 1? 'hour ago' : d < 1 ? approx(h)+' h ago'
           : d <= 1? 'yesterday' : w < 1? approx(d)+' d ago'
           : w <= 1? 'last week' : M < 1? approx(w)+' w ago'
           : M <= 1? 'last month': y < 1? approx(M)+' m ago'
           : y <= 1? 'a year ago': approx(y) + ' years ago'
    }

    function loadChatsHistory() {
        select = [];
        chatModel.clear()
        var firstLaunch = true;
        var i = blankeDrawer.cindex
        for (var j = 0; j<loader.chats.length; j++) {
            if (loader.chats[j].message.length > 0) {
                firstLaunch = false
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
    }

    function checkMessage(flag) {
        if (screenTextFieldPost.text.length >= 1) {
        var text= buferText.text = screenTextFieldPost.text
        var obj = {text:text, flag: flag, time: new Date()}
        loader.chats[blankeDrawer.cindex].message.push(obj)
        var c=JSON.stringify(loader.chats)
        event_handler.saveSet("chats", c);
        appendMessage(text,flag,obj.time);
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
                if (i == blankeDrawer.getCurPeerInd()){
                    appendMessage(buferText.text,1,object.time)
                    chatScrenList.positionViewAtEnd();
                }
            }
        }
    }

    Connections {
        target: chatMenuList;
        onActionChanged: {
            if (chatMenuList.action == (8)) {
                select=[];
                chatModel.clear()
                chatMenuList.action=0;
                var currentInd = blankeDrawer.cindex
                loader.chats[currentInd].message=[];
                event_handler.saveSet("chats", JSON.stringify(loader.chats))
            }
            if (chatMenuList.action == (3)) {
                event_handler.copyText(chatModel.get(select[select.length-1]).someText)
            } else if (chatMenuList.action == (1)) {
                select.sort();
                for(var i=0; i<select.length; i++) {
                    chatModel.remove(select[i] - i);
                    var currentIndex = blankeDrawer.cindex;
                    loader.chats[currentIndex].message.splice(select[i]-i,1)
                }
                event_handler.saveSet("chats", JSON.stringify(loader.chats))
                for(var i=1; i<chatModel.count; i++)
                chatModel.setProperty(i,"mySpacing",(chatModel.get(i-1).textColor=="#000000"&&chatModel.get(i).textColor=="#960f133d")||(chatModel.get(i).textColor=="#000000"&&chatModel.get(i-1).textColor=="#960f133d")? facade.toPx(30): facade.toPx(0));
                chatMenuList.menu = 1;
                chatMenuList.action=0;
                select=[];
            }
        }
    }

    Component.onCompleted: loadChatsHistory();

    function parseToJSON(message, phone, ip) {
        var JSONobj
        return JSON.stringify(JSONobj = {message: message, phone:phone,/*ip:ip*/});
    }

    function appendMessage(newmessage, flag , timestamp) {
        var sp, cflag;
        flag = Math.abs(cflag = flag)
        chatModel.append({
            falg:flag,
            mySpacing: sp = (chatModel.count > 0 ? ((chatModel.get(chatModel.count - 1).textColor == "#FFFFFF" && flag == 2) || (chatModel.get(chatModel.count - 1).textColor == "#545454" && flag == 1)? facade.toPx(30): facade.toPx(0)): facade.toPx(20)),
            someText: newmessage,
            lineColor: Math.random(),
            timeStamp: String(timestamp),
            textColor: (flag === 2)? "#545454": "#FFFFFF",
            backgroundColor:flag==2? "#F4F4F4": "#D1D1D1",
            image: sp == facade.toPx(0)? "": (flag == 2? "ui/chat/leFtMessage.png": "ui/chat/rightMessag.png")
        });
        if (cflag ==2) event_handler.sendMsgs(parseToJSON(newmessage,loader.tel,0))
    }

    function hideKeyboard(event) {
        pressedArea.visible= true;
        if(event!=0)event.accepted = true
        screenTextFieldPost.focus = false
        Qt.inputMethod.hide()
        loader.focus = (true)
        input=false;
    }

    TextArea {
        id: buferText;
        wrapMode: TextEdit.Wrap
        width: {75/100*parent.width}
        visible: false
        font {
            pixelSize: {facade.doPx(23);}
            family: {trebu4etMsNorm.name}
        }
    }

    ListView {
        anchors {
            top: parent.top
            bottom:flickTextArea.top
            bottomMargin: facade.toPx(40)
            topMargin:partnerHeader.height+facade.toPx(10)
        }
        width: parent.width
        displayMarginEnd: (height/2)
        displayMarginBeginning: height/2;
        model: ListModel {id: chatModel;}

        id:chatScrenList
        MouseArea {
            anchors.fill: {(parent)}
            propagateComposedEvents: true
            onClicked: {
                hideKeyboard(mouse);
                mouse.accepted = !(true);
            }
            visible: event_handler.currentOSys() == 1 || event_handler.currentOSys() == 2;
        }

        delegate: Rectangle {
            color: "transparent"
            width: parent.width
            height: {basedColumn.implicitHeight}

            id: baseRect
            Column {
                id: basedColumn
                width: parent.width;
                Item {
                    width: (parent.width)
                    height: {timeText.height + mySpacing}
                    Rectangle {
                        height: {parent.height;}
                        width: {routeLine.width}
                        x:routeLine.x+baseItem.x
                        visible: (index >= 1) == true && (chatModel.get(index).mySpacing == 0)
                        color: Qt.hsva(index>0? chatModel.get(index-1).lineColor: 0,0.37,0.84)
                    }
                    Text {
                        id: timeText
                        text:relative(timeStamp)
                        font.pixelSize: {facade.doPx(16)}
                        font.family: trebu4etMsNorm.name;
                        anchors {
                            bottom:parent.bottom
                            bottomMargin: facade.toPx(2);
                        }
                        x: textarea.width-width;
                        color:"gray"
                    }
                }

                Item {
                    id: baseItem
                    width: parent.width;
                    height: {parentText.height;}
                    Image {
                        source: {image;}
                        smooth: {false;}
                        width: {facade.toPx(sourceSize.width * (1.0))}
                        height:{facade.toPx(sourceSize.width * (1.0))}
                        y: parentText.y + parentText.height - (height)
                        x: {
                            var xpos = -width/2;
                            if (Math.abs(falg - 2) !== 0)
                                xpos+= (textarea.width + parentText.x)
                            return xpos;
                        }
                    }

                    Rectangle {
                        id: routeLine
                        color: Qt.hsva(lineColor, 0.37,0.84)
                        x: (Math.abs(falg-2)==0? staMessage.x:0) -width/2 + staMessage.width/2
                        visible: index<chatModel.count-1&&chatModel.get(index+1).mySpacing==0;
                        width: {facade.toPx(4);}
                        height: {parent.height;}
                    }
                    x:facade.toPx(40)
                    Item {
                        id:parentText
                        height: textarea.height;
                        property var spacing:facade.toPx(40)
                        TextArea {
                            id:textarea
                            padding: facade.toPx(14)
                            wrapMode: TextEdit.Wrap;
                            width: baseItem.width-2*baseItem.x-staMessage.width-parent.spacing
                            font.family: trebu4etMsNorm.name
                            font.pixelSize: facade.doPx(23);
                            text: someText;

                            color:textColor
                            readOnly: true;
                            background: Rectangle {
                                color: {backgroundColor}
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
                                        color:loader.chat3Color

                                        transform: Translate {
                                            x: -coloresRect.width /(2)
                                            y: -coloresRect.height/(2)
                                        }
                                    }
                                }

                                PropertyAnimation {
                                    duration: 500
                                    id: circleAnimation;
                                    target: coloresRect;
                                    properties:("width,height,radius")
                                    from: 0
                                    to: (parent.width*3)

                                    onStopped: {
                                        coloresRect.width  = 0;
                                        coloresRect.height = 0;
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        var p= 0
                                        if(select.length > 0) {
                                            p = select.indexOf(index);
                                            if(p >= 0) {
                                                select.splice(p,1)
                                            } else {
                                                chatMenuList.menu = 0;
                                                parent.color = loader.chat4Color
                                                baseRect.color="white"
                                                select.push(index)
                                                return
                                            }
                                        }
                                        baseRect.color = "transparent"
                                        parent.color = backgroundColor
                                        if (select.length === 0) {
                                            chatMenuList.menu = 1
                                        }
                                    }
                                    onPressAndHold: {
                                        if (select.indexOf(index)<0) {
                                            select.push(index);
                                        }
                                        chatMenuList.menu =0
                                        parent.color=loader.chat4Color
                                        baseRect.color = "#FFFFFF"
                                        coloresRect.x = ((mouseX))
                                        coloresRect.y = ((mouseY))
                                        circleAnimation.start()
                                    }
                                }
                            }
                        }
                        x: (Math.abs(falg - 2) * (2 * baseItem.x))

                        DropShadow {
                            radius: 10
                            samples: 15
                            color: "#DD000000"
                            source: staMessage
                            anchors.fill:staMessage
                        }
                        Item {
                            id: staMessage
                            width: facade.toPx(31);
                            height:facade.toPx(31);
                            x: Math.abs(falg-2)==0? textarea.width + parent.spacing: -parent.x
                            Rectangle {
                                anchors.horizontalCenter: {
                                    parent.horizontalCenter
                                }
                                width: {
                                    if (index < chatModel.count - 1) {
                                        parent.width - facade.toPx(9);
                                    } else {(parent.width)}
                                }
                                height: width
                                radius: width/2
                                color: Qt.hsva(lineColor, 0.41, 0.84);
                                Rectangle {
                                    height: width
                                    radius: width/2
                                    width: parent.width/2.2
                                    anchors.centerIn: {parent;}
                                    border.color: {loader.chat2Color;}
                                    border.width: 3
                                    visible:index == chatModel.count-1
                                }
                            }
                        }
                    }
                }
            }
        }
        boundsBehavior: {(Flickable.StopAtBounds);}
    }

    Column {
        clip: true
        id: flickTextArea
        width: parent.width
        anchors {
            bottom: parent.bottom
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
                    leftPadding:facade.toPx(25)
                    wrapMode: {(TextEdit.Wrap)}
                    placeholderText: {
                        if (event_handler.currentOSys() <= 0) "CTRL+ENTER ДЛЯ ОТПРАВКИ..."
                        else {qsTr("СООБЩЕНИЕ...")}
                    }
                    background: Rectangle {color:"#CFFEFEFE"}
                    Keys.onReturnPressed: {pressCtrl = !(false); event.accepted = (false)}
                    Keys.onPressed: if (event.key === Qt.Key_Control) {pressEntr = !false}
                    rightPadding: messageButton.width + facade.toPx(20)
                    font {
                        pixelSize: facade.doPx(24);
                        family:trebu4etMsNorm.name;
                    }
                    Keys.onReleased: {
                        if (event.key === Qt.Key_Control || event.key === Qt.Key_Return) {
                            if (pressCtrl == true && pressEntr == true) {checkMessage(2);}
                        } else if (event.key ==Qt.Key_Back) {
                            hideKeyboard(event)
                        }
                        pressCtrl = (false);
                        pressEntr = (false);
                    }
                    MouseArea {
                        id: pressedArea
                        width: {
                            parent.width-messageButton.width;
                        }
                        height: parent.height
                        visible:event_handler.currentOSys()>0
                        onClicked: {
                            chatScrenList.positionViewAtEnd()
                            screenTextFieldPost.focus = true;
                            visible = (false)
                            input =true
                        }
                    }
                }
                flickableDirection: {Flickable.VerticalFlick}
                width: parent.width
                height: {
                    if (screenTextFieldPost.lineCount == 1) {
                        screenTextFieldPost.memHeight =facade.toPx(85)
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
                    verticalCenter: {
                        screenTextFieldPost.lineCount==1? parent.verticalCenter: undefined
                    }
                }
                background: Image {
                    anchors.verticalCenter: {
                        parent.verticalCenter
                    }
                    width: facade.toPx(sourceSize.width);
                    height:facade.toPx(sourceSize.height)
                    source: {"ui/buttons/sendButton.png"}
                }
                onClicked: {
                    if (event_handler.currentOSys() >= 1)
                        hideKeyboard(0)
                    checkMessage(2)
                }
                width: background.width + facade.toPx(20)
                height:{parent.height;}
            }
        }
    }
}
