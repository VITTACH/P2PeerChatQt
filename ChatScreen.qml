import QtQml 2.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle

Drawer {
    edge: Qt.RightEdge
    width: parent.width
    height: parent.height

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
            if (historics !== "") {
                loader.chats = JSON.parse(historics);
            }
        }

        if (typeof loader.chats[i] == "undefined") {return;}

        for(j = 0; j <loader.chats[i].message.length; j++) {
            buferText.text = loader.chats[i].message[j].text
            var objct = loader.chats[i].message[j];
            appendMessage(objct.text,-objct.flag,objct.time)
        }

        chatScrenList.positionViewAtEnd()
    }

    function checkMessage(flag) {
        if (textField.text.length >= 1) {
            var text= buferText.text = textField.text;
            var obj = {text:text, flag:flag,time:new Date()}
            var nd = blankeDrawer.cindex;
            loader.chats[nd].message.push(obj)
            var c=JSON.stringify(loader.chats)
            event_handler.saveSet("chats", c);
            appendMessage(text,flag,obj.time);
            chatScrenList.positionViewAtEnd();
            textField.text=""
        }
    }

    function relative(str) {
        var s = (+ new Date()-Date.parse(str))/1e3, m= s/60,
        h = m/60, d = h/24, w = d/7, y = d/365.242, M= y*12;

       function approx(num) {
           return num<5? 'few':Math.round(num)
       }

       return s <= 1? 'just now' : m < 1 ?approx(s)+' s ago'
            : m <= 1? 'minute ago': h < 1?approx(m)+' m ago'
            : h <= 1? 'hour ago' : d < 1 ?approx(h)+' h ago'
            : d <= 1? 'yesterday' : w < 1?approx(d)+' d ago'
            : w <= 1? 'last week' : M < 1?approx(w)+' w ago'
            : M <= 1? 'last month': y < 1?approx(M)+' m ago'
            : y <= 1? 'a year ago': approx(y) + ' years ago'
    }

    Rectangle {
        anchors.fill: {parent} color:loader.chat1Color
    }

    Connections {
        target: event_handler;
        onReciving: {
            var i
            if(response!="") {
                var obj = JSON.parse(response)
                for (i=0; i<loader.chats.length;i++) {
                    if (obj.phone === loader.chats[i].phone)
                        break;
                }
                buferText.text = (obj.message)
                var object = {text:buferText.text, flag:1, time: new Date()}
                loader.chats[i].message.push((object))
                event_handler.saveSet("chats", JSON.stringify(loader.chats))
                if(i == blankeDrawer.getCurPeerInd()){
                    appendMessage(buferText.text, 1,object.time)
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
                    var currentIndex = (blankeDrawer.cindex)
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

    Component.onCompleted: {loadChatsHistory(); partnersHead.page = (-1.0);}

    function parseToJSON(message, phone,ip) {
        return JSON.stringify({message: message, phone:phone})
    }

    function appendMessage(newTextMessage, flag, times) {
        var sp, cflag;
        flag = Math.abs(cflag = flag)
        chatModel.append({
            falg:flag,
            mySpacing: sp = (chatModel.count > 0 ? ((chatModel.get(chatModel.count - 1).textColor == "#535353" && flag == 2) || (chatModel.get(chatModel.count - 1).textColor == "#545454" && flag == 1)? facade.toPx(30): facade.toPx(0)): facade.toPx(20)),
            someText: newTextMessage,
            lineColor: Math.random(),
            timeStamp: String(times),
            textColor: (flag === 2)? ("#545454"): ("#535353"),
            backgroundColor:flag==2? "#E0F4F4F4": "#E0D1D1D1",
            image: ""
        });
        if (cflag === 2) {
            event_handler.sendMsgs(parseToJSON(newTextMessage,loader.tel,0))
        }
    }

    Connections {target: blankeDrawer; onCindexChanged: loadChatsHistory();}

    TextArea {
        id: buferText;
        wrapMode: TextEdit.Wrap
        width: {75/100*parent.width}
        visible: false
        font {
            pixelSize: {facade.doPx(28);}
            family: {trebu4etMsNorm.name}
        }
    }

    ListView {
        anchors {
            top: parent.top
            bottom: textArea.top
            topMargin: partnerHeader.height + facade.toPx(10);
            bottomMargin: {
                var tex=Math.max(facade.toPx(99),input?parent.height*0.43:0)
                if (textArea.height >0) {
                    tex=0
                }
                facade.toPx(40) + (tex)
            }
        }
        width: parent.width
        displayMarginEnd: (height/2)
        displayMarginBeginning: height/2;
        model: ListModel {id: chatModel;}

        id:chatScrenList
        MouseArea {
            anchors.fill:parent
            propagateComposedEvents: true
            visible: event_handler.currentOSys()
            onClicked: {
                hideKeyboard(mouse);
                mouse.accepted = !(true);
            }
        }

        delegate: Rectangle {
            color:"transparent"
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
                    x:facade.toPx(40)
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

                    Item {
                        id:parentText
                        height:textarea.height
                        property var spacing:facade.toPx(40)

                        TextArea {
                            id: textarea
                            text: someText;
                            padding: facade.toPx(14)
                            wrapMode: TextEdit.Wrap;
                            font.family: trebu4etMsNorm.name
                            font.pixelSize: facade.doPx(28);
                            width: baseItem.width-2*baseItem.x-staMessage.width-parent.spacing

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
                                                parent.color=loader.chat4Color
                                                baseRect.color = ("#60FFFFFF")
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
                                        baseRect.color = ("#60FFFFFF")
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
                                    } else {staMessage.width}
                                }
                                height: width
                                radius: width/2
                                color: Qt.hsva(lineColor, 0.41, 0.84);
                                Rectangle {
                                    height: width
                                    radius: width/2
                                    width: parent.width / 2.2
                                    anchors.centerIn: parent;
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

    DropShadow {
        radius: 10
        samples: 15
        color:"#90000000"
        source: textArea;
        anchors.fill: {textArea;}
    }
    Column {
        clip: true
        id: textArea
        width: parent.width
        anchors {
            bottom: parent.bottom
            bottomMargin: input? parent.height*0.43: 0;
        }
        Item {
            width: {parent.width}
            height:textField.memHeight
            Item {
                anchors.fill: {parent}
                Flickable {
                    TextArea.flickable : TextArea {
                        id: textField
                        property variant memHeight;
                        property bool pressCtrl: false;
                        property bool pressEntr: false;
                        placeholderText: {
                            if (event_handler.currentOSys() <= 0) "Ctrl+Enter Для Отправки..."
                            else qsTr("Ваше Сообщение")
                        }
                        wrapMode: TextEdit.Wrap
                        verticalAlignment: {(Text.AlignVCenter);}
                        background: Rectangle {color:"#CFFEFEFE"}
                        Keys.onReturnPressed: {pressCtrl = !(false); event.accepted = (false)}
                        Keys.onPressed: if (event.key === Qt.Key_Control) {pressEntr = !false}
                        rightPadding:sendButton.width+leftPadding
                        font.family:trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(28)
                        Keys.onReleased: {
                            if (event.key === Qt.Key_Control || event.key === Qt.Key_Return) {
                                if (pressCtrl == true && pressEntr == true) {checkMessage(2);}
                            } else if (event.key ==Qt.Key_Back) {
                                hideKeyboard(event)
                            }
                            pressCtrl = pressEntr=false
                        }
                        leftPadding:facade.toPx(40)
                        MouseArea {
                            id: pressedArea
                            width: parent.width-sendButton.width;
                            height: parent.height
                            visible:event_handler.currentOSys()>0
                            onClicked: {
                                visible = !(input=true)
                                chatScrenList.positionViewAtEnd()
                                textField.focus = true;
                            }
                        }
                    }
                    flickableDirection: {Flickable.VerticalFlick}
                    width: parent.width
                    height: {
                        if (textField.lineCount == 1) {
                            textField.memHeight = facade.toPx(99)
                        } else if (textField.lineCount < 6) {
                            textField.memHeight = textField.implicitHeight
                        } else {
                            textField.memHeight
                        }
                    }
                }
            }

            Button {
                id: sendButton
                anchors.right: {parent.right}
                background: Image {
                    width: facade.toPx(sourceSize.width);
                    height:facade.toPx(sourceSize.height)
                    source: {"ui/buttons/sendButton.png"}
                    anchors {
                        bottom: parent.bottom
                        bottomMargin: {
                            if (textField.lineCount <= 1)
                                (parent.height-height)/2;
                            else facade.toPx(22)
                        }
                    }
                }
                onClicked:{
                    if (event_handler.currentOSys() >= 1)
                        hideKeyboard(0)
                    checkMessage(2)
                }
                width: background.width + facade.toPx(20)
                height:{parent.height;}
            }
        }
    }

    property variant select
    property variant input;

    P2PStyle.HeaderSplash {id: partnersHead}

    P2PStyle.ChatMenuList {id: chatMenuList}

    function setInfo(messag,photos,status) {
        partnersHead.stat = status
        partnersHead.phot = photos
        partnersHead.text = messag
    }

    function hideKeyboard(event) {
        pressedArea.visible= true;
        if (event !== 0) event.accepted=true
        textField.focus = false
        Qt.inputMethod.hide()
        loader.focus =true
        input = false
    }
}