import QtQml 2.0
import QtQuick 2.7
import QtMultimedia 5.7
import QtQuick.Dialogs 1.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle

Drawer {
    edge: Qt.RightEdge
    width: parent.width;
    height: parent.height;

    Connections {
        target: event_handler;
        onReciving: {
            var i
            if(response!="") {
                var obj = JSON.parse(response)
                for (i=0; i<loader.chats.length;i++) {
                    if (obj.phone == loader.chats[i - 0].phone) {
                        break;
                    }
                }
                buferText.text = (obj.message)
                var object = {text:buferText.text, flag:1, time: new Date()}
                loader.chats[i].message.push((object))
                event_handler.saveSet("chats", JSON.stringify(loader.chats))
                if(i == blankeDrawer.getCurPeerInd()){
                    appendMessage(buferText.text, 1, object.time)
                    chatScrenList.positionViewAtEnd();
                }
            }
        }
    }

    Connections {
        target: loader
        onContextChanged: {
            if(!loader.context&&yPosition>0) {chatMenuList.menu=1;select=[]}
        }
    }

    property real yPosition
    property variant select
    property variant input;

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
                var text = chatModel.get(select[select.length-  1]).someText
                event_handler.copyText(text);
            } else if (chatMenuList.action == (1)) {
                console.log(chatMenuList.action)
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
            loader.context = false
        }
    }

    Connections {target: blankeDrawer; onCindexChanged: loadChatsHistory();}

    Component.onCompleted: {loadChatsHistory(); partnersHead.page = (-1.0);}

    Connections {
        target:chatScreen;
        onPositionChanged: {
            if(loader.isLogin==false)
                position = 0
        }
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
            textColor: (flag === 2)?("#545454"):("#535353"),
            backgroundColor:flag==2?"#CAFFFFFF":"#CAEFFFDE",
            image: ""
        });
        if (cflag === 2) {
            event_handler.sendMsgs(parseToJSON(newTextMessage,loader.tel,0))
        }
    }

    function hideKeyboard(event) {
        pressedArea.visible= true;
        if (event !== 0)
            event.accepted = true;
        textField.focus = false
        Qt.inputMethod.hide()
        loader.focus = true
        input = false
    }

    function parseToJSON(message, phone, ip) {
        return JSON.stringify({message:message,phone:phone})
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

    function setInfo(messag, photos, status) {
        partnersHead.stat = status
        partnersHead.phot = photos
        partnersHead.text = messag
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
       var s = (+ new Date() - Date.parse(str))/1e3, m= s/60, h = m/60, d = h/24,
       w = d/7, y = d/365.242, M= y*12;
       function approx(num) {return num < 5? qsTr('Несколько'): Math.round(num);}
       return s <= 1? qsTr('Только что')  : m<1? approx(s) + qsTr(' сек. назад')
            : m <= 1? qsTr('минуту назад'): h<1? approx(m) + qsTr(' минут назад')
            : h <= 1? qsTr('час назад')   : d<1? approx(h) + qsTr(' часов назад')
            : d <= 1? qsTr('вчера')       : w<1? approx(d) + qsTr(' суток назад')
            : w <= 1? qsTr('неделю назад'): M<1? approx(w)+qsTr(' неделей назад')
            : M <= 1? qsTr('месяц назад') : y<1? approx(M)+qsTr(' месяцев назад')
            : y <= 1? qsTr('года назад')  : approx(y) + qsTr(' год(а) назад')
    }

    Image {
        anchors.fill:parent
        source: ("http://picsum.photos/" + width + "/" + height + "?random&blur")
    }

    P2PStyle.ColorAnimate {
        opacity: 0.62
        anchors.fill: {parent}
        Component.onCompleted: {
            setColors([[48,99,137],[219,208,169],[84,116,153],[171,189,147]],200)
        }
    }

    TextArea {
        id: buferText;
        wrapMode: TextEdit.Wrap;
        width: 0.75*parent.width
        visible: false
        font {
            pixelSize: {facade.doPx(30)}
            family: trebu4etMsNorm.name;
        }
    }

    ListView {
        id: chatScrenList
        width: parent.width;
        displayMarginEnd: height/2
        displayMarginBeginning: height/2
        model: ListModel {id: chatModel}

        delegate:Item {
            Rectangle {
                id: baseRect
                color: "#00000000"
                Column {
                    id: basedColumn;
                    width: parent.width;
                    Item {
                        width: parent.width
                        height: timeText.height + mySpacing + (mySpacing == 0? facade.toPx(10): 0)

                        DropShadow {
                            radius: 5
                            samples: 10;
                            color: "#80000000";
                            source: {timeText;}
                            anchors.fill: {timeText}
                        }
                        Text {
                            id: timeText;
                            text:relative(timeStamp)
                            font.family: trebu4etMsNorm.name
                            font.pixelSize: facade.doPx(18);
                            x: textarea.width - implicitWidth + baseItem.x
                            anchors {
                                bottom:parent.bottom
                                bottomMargin: facade.toPx(2)
                            }
                            color: {backgroundColor}
                        }

                        Rectangle {
                            height: parent.height
                            width: {routeLine.width}
                            x:routeLine.x+baseItem.x
                            visible: (index >= 1) == true && (chatModel.get(index).mySpacing == 0)
                            color: Qt.hsva(index>0? chatModel.get(index-1).lineColor: 0,0.40,0.94)
                        }
                    }

                    Item {
                        id: baseItem
                        x: parent.width/18
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
                                if (Math.abs(falg - 2) != (0)) {
                                    xpos+= (textarea.width + parentText.x)
                                }
                                return xpos;
                            }
                        }

                        Rectangle {
                            id: routeLine;
                            color: Qt.hsva(lineColor, 0.40, 0.94)
                            x: (Math.abs(falg-2)==0? staMessage.x:0) -width/2 + staMessage.width/2
                            visible: index<chatModel.count-1&&chatModel.get(index+1).mySpacing==0;
                            width: {facade.toPx(4);}
                            height: {parent.height;}
                        }

                        Item {
                            id: parentText
                            height: textarea.height;
                            property var spacing: facade.toPx(40)
                            x: Math.abs(falg-2)===1? textarea.width-msCloud.width: 0

                            TextArea {
                                id: textarea
                                text: someText;
                                padding:facade.toPx(14)
                                wrapMode: TextEdit.Wrap
                                font.family: trebu4etMsNorm.name;
                                font.pixelSize: {facade.doPx(30)}
                                width: {
                                    baseItem.width-2*baseItem.x-staMessage.width-x-parent.spacing;
                                }

                                color: textColor;
                                readOnly: !false;
                                background: Rectangle {
                                    id: msCloud
                                    border.width: 4.0
                                    border.color:"#C6D1D7"
                                    color: backgroundColor
                                    width: textarea.implicitWidth
                                    radius: {parent.padding}
                                    property var lightColor;
                                    property var darksColor;
                                    Component.onCompleted: {
                                        lightColor = Qt.rgba(color.r-0.06,color.g-0.04,color.b, 1)
                                        darksColor = Qt.rgba(color.r-0.13,color.g-0.10,color.b, 1)
                                    }

                                    PropertyAnimation {
                                        duration: 500
                                        id: circleAnimation;
                                        target: coloresRect;
                                        properties:("width,height,radius");
                                        from: 0

                                        onStopped: {coloresRect.width  = 0; coloresRect.height =0}
                                        to: (parent.width*3)
                                    }

                                    Item {
                                        clip: true;
                                        anchors.centerIn: parent
                                        width: parent.width-2*parent.radius
                                        height: parent.height-2*parent.border.width;
                                        Rectangle {
                                            width: 0
                                            height: 0
                                            id: coloresRect;
                                            color: parent.parent.lightColor

                                            transform: Translate {
                                                x: -coloresRect.width /(2);
                                                y: -coloresRect.height/(2);
                                            }
                                        }
                                    }
                                }
                            }

                            DropShadow {
                                radius: 10
                                samples: 15
                                color: "#DD000000"
                                source: staMessage
                                anchors.fill: staMessage
                                visible: staMessage.visible
                            }
                            Item {
                                id: staMessage
                                width: facade.toPx(36);
                                height: facade.toPx(36);
                                visible: {
                                    var vis = index == chatModel.count - 1;
                                    if (!vis)
                                    vis|=!chatModel.get(index+1).mySpacing;
                                    vis|=chatModel.get(index).mySpacing==0;
                                    return vis
                                }
                                x: {
                                    if (Math.abs(falg- 2) == 0)
                                        (textarea.width + (parent.spacing))
                                    else -parent.x
                                }
                                Rectangle {
                                    height: width
                                    radius: width/2
                                    width: {
                                        if (index < chatModel.count - 1) {
                                            (parent.width - facade.toPx(9))
                                        } else {staMessage.width}
                                    }
                                    color: {Qt.hsva(lineColor, 0.45, 0.86)}
                                    anchors.horizontalCenter:parent.horizontalCenter
                                    Rectangle {
                                        height: width
                                        radius: width/2
                                        width: parent.width / 2.2
                                        anchors.centerIn: parent;
                                        border.color: {(loader.chat2Color)}
                                        border.width: 3
                                        visible:index == chatModel.count-1;
                                    }
                                }
                            }
                        }
                    }
                }
                anchors.fill: parent
            }

            MouseArea {
                anchors.fill: parent
                onPressAndHold: {
                    coloresRect.x = mouseX;
                    coloresRect.y = mouseY;
                    msCloud.color= msCloud.darksColor
                    baseRect.color= loader.chat3Color
                    if (select.indexOf(index) <=-1) {
                        select.push(index);
                    }
                    chatMenuList.menu = (0)
                    circleAnimation.start()
                    yPosition = 0
                }

                acceptedButtons:Qt.LeftButton|Qt.RightButton
                onClicked: {
                    baseRect.color = ("#00000000")
                    msCloud.color = backgroundColor;
                    if (select.length> 0) {
                        yPosition = 0
                        var position = select.indexOf(index)
                        if (position >= 0) {
                            select.splice(position,1)
                        } else {
                            chatMenuList.menu = 0;
                            msCloud.color=msCloud.darksColor
                            baseRect.color=loader.chat3Color
                            select.push(index)
                            return
                        }
                    }else if(mouse.button==Qt.RightButton) {
                        var posx = mouse.x
                        if (width- mouse.x<chatMenuList.w)
                            posx = width - chatMenuList.w;
                        chatMenuList.xPosition = posx
                        chatMenuList.yPosition = yPosition
                        coloresRect.x = mouseX
                        coloresRect.y = mouseY
                        circleAnimation.restart();
                        chatMenuList.menu = 0;
                        loader.context = true
                        select.push(index)
                        return
                    }
                    if(select.length==0) chatMenuList.menu=1
                }
            }
            height: basedColumn.height
            width: parent.width;
        }
        MouseArea {
            anchors.fill: {parent}
            propagateComposedEvents: true
            // visible: event_handler.currentOSys() > 0;
            onClicked: {
                hideKeyboard(mouse);mouse.accepted = !(true)
            }
        }
        anchors {
            top: parent.top
            bottom: textArea.top
            topMargin: partnerHeader.height+facade.toPx(10);
            bottomMargin: {
                var curHeight = input? parent.height*0.43:0;
                var tex=Math.max(facade.toPx(110),curHeight)
                if (textArea.height >0) {
                    tex = 0
                } facade.toPx(40) + (tex)
            }
        }
    }

    FileDialog {
        id:fileDialog
        folder: shortcuts.home
        title: "Выберите изображение"
        nameFilters:["Изображения (*.jpg *.png)","Все файлы (*)"]
        onAccepted: {
            loader.avatarPath=fileUrl
            event_handler.sendAvatar(decodeURIComponent(fileUrl))
        }
    }

    DropShadow {
        radius: 10
        samples: 15
        color: "#90000000";
        source: {textArea;}
        anchors.fill: {textArea;}
    }
    Column {
        clip: true
        id: textArea
        width: parent.width
        anchors {
            bottom: parent.bottom
            bottomMargin:input?parent.height*0.43:0
        }

        Rectangle {
            id: attachment
            height: facade.toPx(150);
            width: attachModel.count*(height + attachList.spacing)
            visible: false
            Connections {
                target:textArea
                onHeightChanged: chatScrenList.positionViewAtEnd()
            }

            ListView {
                id: attachList;
                anchors.fill:parent
                anchors.leftMargin: facade.toPx(20)
                spacing: facade.toPx(10)
                orientation: {Qt.Horizontal}
                model:ListModel {
                    id: attachModel
                    ListElement {image: "";}
                }
                delegate: Rectangle {
                    width: height
                    color: index == 0? "#404040": "#D3D3D3"
                    height: (parent.height) - facade.toPx(20);
                    anchors.verticalCenter:parent.verticalCenter
                    Camera {
                        id: camera
                        flash.mode:Camera.FlashAuto

                        exposure {
                            exposureCompensation:-1
                            exposureMode:Camera.ExposurePortrait
                        }
                    }
                    VideoOutput {
                        fillMode: VideoOutput.PreserveAspectCrop
                        focus: visible
                        source: camera
                        orientation: -90
                        anchors.fill: parent
                        visible: index == 0;
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            attachment.visible = false
                            if (index == 0){
                                imagePicker.item.takePhoto()
                            } else {
                                if (event_handler.currentOSys()==0) {
                                    fileDialog.open();
                                } else {imagePicker.item.pickImage()}
                            }
                        }
                    }
                }
            }
        }
        Item {
            width: {parent.width}
            height:textField.memHeight
            Item {
                anchors.fill: {parent}
                Flickable {
                    height: {
                        if (textField.lineCount == 1) {
                            textField.memHeight =facade.toPx(110)
                        } else if (textField.lineCount < 6) {
                            textField.memHeight =textField.implicitHeight;
                        } else {
                            textField.memHeight
                        }
                    }
                    TextArea.flickable : TextArea {
                        id: textField
                        property variant memHeight;
                        property bool pressCtrl: false;
                        property bool pressEntr: false;
                        placeholderText: {
                            if (event_handler.currentOSys() <= 0)
                                qsTr("Ctrl+Enter Для Отправки..")
                            else qsTr("Ваше Сообщение")
                        }
                        wrapMode: TextEdit.Wrap
                        verticalAlignment: {(Text.AlignVCenter);}
                        background: Rectangle {color:"#CFFEFEFE"}
                        Keys.onReturnPressed: {
                            pressCtrl = !false;
                            event.accepted = false
                        }
                        Keys.onPressed: {
                            if (event.key === (Qt.Key_Control)) {
                                pressEntr = !false
                            }
                        }
                        rightPadding:sendButton.width+leftPadding
                        font.family:trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(34)
                        Keys.onReleased: {
                            if (event.key === Qt.Key_Control || event.key === Qt.Key_Return) {
                                if (pressCtrl==true && pressEntr)
                                    checkMessage(2)
                            } else if (event.key ==Qt.Key_Back) {
                                hideKeyboard(event)
                            }
                            pressCtrl = pressEntr=false
                        }
                        leftPadding: attachButton.width
                        MouseArea {
                            id: pressedArea
                            width: parent.width-sendButton.width;
                            height: parent.height
                            // visible:event_handler.currentOSys()>0
                            onClicked: {
                                visible = !(input=true)
                                chatScrenList.positionViewAtEnd()
                                textField.forceActiveFocus()
                            }
                        }
                    }
                    flickableDirection: {Flickable.VerticalFlick}
                    width: parent.width
                }
            }

            Button {
                id: attachButton
                background: Image {
                    source: "ui/buttons/addButton.png"
                    width: facade.toPx(sourceSize.width / 11*10);
                    height: facade.toPx(sourceSize.height/11*10);
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: {
                            if (textField.lineCount <= 1)
                                (parent.height-height)/2;
                            else facade.toPx(22)
                        }
                    }
                }
                onClicked: attachment.visible=!attachment.visible
                width: background.width + facade.toPx(60)
                height: parent.height;
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

    P2PStyle.HeaderSplash {id: partnersHead;}

    P2PStyle.ChatMenuList {id: chatMenuList;}

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true;
        acceptedButtons:Qt.RightButton
        onPressed: {
            if(pressedButtons&Qt.RightButton)
                yPosition = mouseY
            if(pressedButtons&Qt.RightButton)
                mouse.accepted = false
        }
    }
}
