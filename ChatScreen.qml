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

    function setInfo(messag, photos, status) {
        partnersHead.stat = status
        partnersHead.phot = photos
        partnersHead.text = messag
    }

    function checkMessage(flag, selectImage) {
        if (textField.text.length >= 1) {
            var text= buferText.text = textField.text;
            var obj = {text: text, flag: flag, time:new Date(), imgs:selectImage}
            var nd = blankeDrawer.cindex;
            textField.text=""
            if (typeof loader.chats[nd] == "undefined")
                loader.chats.push({phone: nd, message: []});
            loader.chats[nd].message.push(obj)
            var c=JSON.stringify(loader.chats)
            event_handler.saveSet("chats", c);
            appendMessage(text, flag, obj.time, selectImage)
            chatScrenList.positionViewAtEnd();
            selectedImage=[];
        }
    }

    property var select
    property real yPosition:0
    property var selectedImage:[]

    function loadChatsHistory() {
        select = [];
        chatModel.clear()
        var firstLaunch = true;
        var i = blankeDrawer.cindex
        for (var j = 0; j <loader.chats.length; j++) {
            if (loader.chats[j].message.length >= 1) {
                firstLaunch = false
                break;
            }
        }

        if (firstLaunch == true) {
            var hist =event_handler.loadValue("chats")
            if (hist !== "") loader.chats = JSON.parse(hist)
        }

        if (typeof loader.chats[i] == "undefined") {return;}

        for (j = 0; j<loader.chats[i].message.length; j++) {
            buferText.text = loader.chats[i].message[j].text
            var obj=loader.chats[i].message[j]
            var image = obj.imgs;
            console.log(image)
            appendMessage(obj.text,-obj.flag,obj.time,image)
        }

        chatScrenList.positionViewAtEnd()
    }

    function parseToJSON(message, phone, ip) {
        return JSON.stringify({message:message,phone:phone})
    }

    Connections {
        target: loader
        onContextChanged: {
            if (!loader.context && yPosition > 0) {chatMenuList.menu=1;select=[]}
        }
    }

    Connections {
        target: event_handler;
        onReciving: {
            if (response != "") {
                var i, obj = JSON.parse(response);
                for (i=0; i<loader.chats.length;i++) {
                    if (obj.phone === loader.chats[i - 0].phone) {
                        break;
                    }
                }
                buferText.text = (obj.message)
                var object = {text : buferText.text, flag : 1, time : new Date()}
                loader.chats[i].message.push((object))
                event_handler.saveSet("chats", JSON.stringify(loader.chats))
                if(i == blankeDrawer.getCurPeerInd()){
                    appendMessage(buferText.text,1,object.time,"")
                    chatScrenList.positionViewAtEnd();
                }
            }
        }
    }

    Connections {
        target:chatMenuList
        onPayloadChanged: {
            if (chatMenuList.payload === 8) {
                select = [];
                chatModel.clear()
                chatMenuList.payload = 0;
                var currentInd = blankeDrawer.cindex
                loader.chats[currentInd].message=[];
                event_handler.saveSet(qsTr("chats"),JSON.stringify(loader.chats))
            }
            if (chatMenuList.payload === 3) {
                var text = chatModel.get(select[(select.length) - (1)]).someText;
                event_handler.copyText(text);
            } else if (chatMenuList.payload === 1) {
                select.sort();
                for(var i=0; i<select.length; i++) {
                    chatModel.remove(select[i] - i);
                    var currentIndex = (blankeDrawer.cindex)
                    loader.chats[(currentIndex)].message.splice(select[i] - i, 1)
                }
                event_handler.saveSet("chats", JSON.stringify(loader.chats))
                for(var i=1; i<chatModel.count; i++)
                chatModel.setProperty(i,"mySpacing",(chatModel.get(i-1).textColor=="#000000"&&chatModel.get(i).textColor=="#960f133d")||(chatModel.get(i).textColor=="#000000"&&chatModel.get(i-1).textColor=="#960f133d")? facade.toPx(30): facade.toPx(0));
                chatMenuList.menu = 1;
                chatMenuList.payload = 0;
                select = [];
            }
            loader.context = false
        }
    }

    Connections {
        target: chatScreen;
        onPositionChanged: {
            if (!loader.isLogin) {
                position = 0
            } else if (position == 1) {
                loader.chatOpen = true;
            } else if (position == 0) {
                loader.chatOpen = false
            }
        }
    }

    Connections {target: blankeDrawer; onCindexChanged: loadChatsHistory();}

    Component.onCompleted: {loadChatsHistory(); partnersHead.page = (-1.0);}

    function appendMessage(message, flag, times, selected) {
        var sp, cflag;
        flag = Math.abs(cflag = flag)
        chatModel.append({
            falg:flag,
            mySpacing: sp = (chatModel.count > 0 ? ((chatModel.get(chatModel.count - 1).textColor == "#535353" && flag == 2) || (chatModel.get(chatModel.count - 1).textColor == "#545454" && flag == 1)? facade.toPx(30): facade.toPx(0)): facade.toPx(20)),
            someText: message,
            lineColor: Math.random(),
            timeStamp: String(times),
            textColor: (flag === 2)?("#545454"):("#535353"),
            backgroundColor:flag==2?"#FFFFFFFF":"#CAEFFFDE",
            images: selected
        });
        if (cflag == 2) event_handler.sendMsgs(parseToJSON(message,loader.tel,0))
    }

    function relative(str) {
       var s = (+ new Date() - Date.parse(str))/1e3, m= s/60, h = m/60, d = h/24,
       w = d/7, y = d/365.242, M= y*12;
       function approx(num) {return num < 5? qsTr('Несколько'): Math.round(num);}
       return s <= 1? qsTr('только что')  : m<1? approx(s) + qsTr(' сек. назад')
            : m <= 1? qsTr('минуту назад'): h<1? approx(m) + qsTr(' минут назад')
            : h <= 1? qsTr('час назад')   : d<1? approx(h) + qsTr(' часов назад')
            : d <= 1? qsTr('вчера')       : w<1? approx(d) + qsTr(' суток назад')
            : w <= 1? qsTr('неделю назад'): M<1? approx(w)+qsTr(' неделей назад')
            : M <= 1? qsTr('месяц назад') : y<1? approx(M)+qsTr(' месяцев назад')
            : y <= 1? qsTr('года назад')  : approx(y) + qsTr(' год(а) назад')
    }

    FastBlur {
        radius: 30
        opacity: 0.750;
        source: {beckground;}
        anchors.fill: beckground
    }
    Image {
        id: beckground;
        anchors.fill: parent;
        source: "http://pipsum.com/"+width+"x"+height+".jpg"
        visible: false;
    }
    ColorAnimate {
        opacity: 0.52
        anchors.fill: parent;
        Component.onCompleted: {setColors([60,60,60], 100);}
    }

    Flickable {
        id: flickable
        anchors.fill: parent;
        anchors.bottomMargin: keyboardRect.visible ? keyboardRect.height : 0
        flickableDirection: {Flickable.VerticalFlick}
        boundsBehavior: Flickable.StopAtBounds

        ListView {
            id: chatScrenList
            width: parent.width;
            displayMarginEnd: height / 2
            displayMarginBeginning: height / 2
            model: ListModel {id: chatModel;}

            delegate:Item {
                width: {parent.width;}
                height: {basedColumn.implicitHeight;}

                Rectangle {
                    id: baseRect
                    color: "#00000000"
                    anchors.fill: parent
                    Column {
                        id: basedColumn;
                        width: parent.width;
                        Item {
                            width: parent.width
                            height: timeText.height + mySpacing + (mySpacing == 0? facade.toPx(10): 0)

                            DropShadow {
                                radius: 5
                                samples: (10);
                                color:"#80000000"
                                source: timeText;
                                anchors.fill: {timeText}
                            }

                            Rectangle {
                                height:parent.height
                                width: {routeLine.width}
                                x:routeLine.x+baseItem.x
                                visible: (index >= 1) == true && (chatModel.get(index).mySpacing == 0)
                                color: Qt.hsva(index>0? chatModel.get(index-1).lineColor: 0,0.40,0.94)
                            }

                            Text {
                                id: timeText;
                                text:relative(timeStamp)
                                color: {backgroundColor}
                                font.family: trebu4etMsNorm.name
                                font.pixelSize: facade.doPx(18);
                                x: textarea.width - implicitWidth + baseItem.x;
                                anchors {
                                    bottom:parent.bottom
                                    bottomMargin: facade.toPx(2)
                                }
                            }
                        }

                        Item {
                            id: baseItem
                            x: parent.width/18
                            width:parent.width
                            height: {parentText.height;}
                            Rectangle {
                                id: routeLine;
                                color: Qt.hsva(lineColor, 0.40, 0.94)
                                x: (Math.abs(falg - 2) == 0? message.x: 0) - width/2 + message.width/2
                                visible: index<chatModel.count-1&&chatModel.get(index+1).mySpacing==0;
                                width: {facade.toPx(4);}
                                height: {parent.height;}
                            }

                            Item {
                                id: parentText
                                height: textarea.height;
                                property var spacing: facade.toPx(40)
                                x:Math.abs(falg-2)?textarea.width-msCloud.width+message.width+spacing:0

                                Rectangle {
                                    id:msCloud
                                    border.width: 3.0
                                    border.color: "#C6D1D7";
                                    property var lightColor;
                                    property var darksColor;

                                    color: backgroundColor
                                    radius: {facade.toPx(8)}
                                    width: textarea.contentWidth
                                    height: textarea.height;

                                    Component.onCompleted: {
                                        lightColor = Qt.rgba(color.r - 0.06, color.g - 0.04,color.b, 1)
                                        darksColor = Qt.rgba(color.r - 0.13, color.g - 0.10,color.b, 1)
                                    }

                                    PropertyAnimation {
                                        duration: 500
                                        id: circleAnimation;
                                        target: coloresRect;
                                        properties: ("width,height,radius")
                                        from: 0
                                        to: parent.width * 3

                                        onStopped: {
                                            coloresRect.width = 0;
                                            coloresRect.height= 0;
                                        }
                                    }
                                    Item {
                                        clip: true;
                                        anchors.centerIn: {parent}
                                        width: parent.width-2*parent.radius
                                        height: {parent.height-2*parent.border.width}
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

                                Column {
                                    id: textarea
                                    width: baseItem.width -2*baseItem.x -message.width -parent.spacing;

                                    property var contentWidth: {
                                        var content = attachList.contentWidth + 2 * attachList.x;
                                        content < width?Math.max(msgarea.implicitWidth, content):width;
                                    }

                                    ListView {
                                        clip: true;
                                        id: attachList
                                        model: JSON.parse(chatModel.get(index).images)
                                        x: {msgarea.padding}
                                        width: parent.width-2*x
                                        height: (typeof model !== "undefined") && model.length > 0? facade.toPx(250): 0;
                                        spacing: {facade.toPx(5);}
                                        orientation:Qt.Horizontal;

                                        delegate: Item {
                                            y: attachList.x
                                            width: parent.height-y
                                            height:parent.height-y
                                            clip: true
                                            Image {
                                                source: modelData;
                                                height: {
                                                    sourceSize.width>sourceSize.height?parent.height:sourceSize.height*(parent.width/sourceSize.width)
                                                }
                                                width: {
                                                    sourceSize.width>sourceSize.height?sourceSize.width*(parent.height/sourceSize.height):parent.width
                                                }
                                                anchors.centerIn: {parent;}
                                                MouseArea {
                                                    anchors.fill: {parent;}
                                                }
                                            }
                                        }
                                    }

                                    TextArea {
                                        id: msgarea
                                        text: someText;
                                        color: {textColor}
                                        width: {parent.width}
                                        padding: facade.toPx(14)
                                        wrapMode: {TextEdit.Wrap;}
                                        font.pixelSize: facade.doPx(30)
                                        font.family:trebu4etMsNorm.name

                                        MouseArea {
                                            anchors.fill: parent
                                            acceptedButtons: Qt.LeftButton|Qt.RightButton;
                                            onPressAndHold: {
                                                coloresRect.x = mouseX;
                                                coloresRect.y = mouseY;
                                                msCloud.color = msCloud.darksColor
                                                baseRect.color = loader.chat3Color
                                                if (select.indexOf(index) <= -1) {
                                                    select.push(index);
                                                }
                                                chatMenuList.menu = (0)
                                                circleAnimation.start()
                                                yPosition = 0
                                            }
                                            onClicked: {
                                                baseRect.color = "#00000000"
                                                msCloud.color = (backgroundColor)
                                                if (select.length > 0) {
                                                    yPosition = 0
                                                    var position = select.indexOf(index)
                                                    if (position >= 0) {
                                                        select.splice(position,1)
                                                    } else {
                                                        chatMenuList.menu=0;
                                                        msCloud.color = msCloud.darksColor
                                                        baseRect.color = loader.chat3Color
                                                        select.push(index)
                                                        return
                                                    }
                                                } else if (select.length === 0) {
                                                    chatMenuList.menu=1
                                                } else if(mouse.button== Qt.RightButton) {
                                                    var posx = mouse.x
                                                    if (width- mouse.x < chatMenuList.w) {
                                                        posx = (width) - chatMenuList.w;
                                                    }
                                                    chatMenuList.xPosition = posx
                                                    chatMenuList.yPosition = (yPosition)
                                                    coloresRect.x =mouseX;
                                                    coloresRect.y =mouseY;
                                                    circleAnimation.restart()
                                                    chatMenuList.menu = 0;
                                                    loader.context = true;
                                                    select.push(index);
                                                    return
                                                }
                                            }
                                        }
                                    }
                                }

                                DropShadow {
                                    radius: 10
                                    samples: 15
                                    color: "#DD000000"
                                    source: message
                                    anchors.fill: {message}
                                    visible:message.visible
                                }
                                Item {
                                    id: message
                                    width: facade.toPx(36);
                                    height: facade.toPx(36)
                                    visible: {
                                        var vis = index == chatModel.count - 1;
                                        if (!vis)
                                        vis|=!chatModel.get(index+1).mySpacing;
                                        return vis
                                    }
                                    x: Math.abs(falg-2) == 0? msgarea.width + parent.spacing: -parent.x
                                    Rectangle {
                                        height: width
                                        radius: width/2
                                        anchors.horizontalCenter: {
                                            parent.horizontalCenter
                                        }
                                        width: {
                                            if (index <= chatModel.count - 2) {
                                                (parent.width - facade.toPx(9))
                                            } else {message.width;}
                                        }
                                        color: {Qt.hsva(lineColor, 0.45, 0.86)}
                                        Rectangle {
                                            height: width
                                            radius: width/2
                                            width: parent.width/2.2
                                            anchors.centerIn:parent
                                            border.color: {(loader.chat2Color)}
                                            border.width: 3
                                            visible:index == chatModel.count-1;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            anchors {
                top: parent.top
                bottom:area.top
                topMargin: {partnerHeader.height + 1*facade.toPx(10)}
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
            source: area
            color: "#90000000";
            anchors.fill: area;
        }

        PropertyAnimation {
            id: attachMove;
            target: attach;
            from: {(attach.move) ? 0 : facade.toPx(380);}
            to: {(attach.move) ? facade.toPx(380) : (0);}
            property: "height";
            duration: 300
        }
        Column {
            id: area
            clip: true;
            width: parent.width
            anchors.bottom: parent.bottom
            Rectangle {
                id: attach
                color: "#90FFFFFF";
                width: parent.width
                property bool move: false
                Connections {
                    target: attach;
                    onMoveChanged: {
                        attach.move ? camera2.start() : camera2.stop();
                        // chatScreen.interactive = !attach.move
                        attachMove.restart()
                    }
                }

                Row {
                    id: imgRow;
                    x: facade.toPx(20)
                    spacing: facade.toPx(10)
                    height: parent.height-x;
                    anchors.verticalCenter : {(parent.verticalCenter);}

                    Rectangle {
                        id: cam
                        color: "black"
                        width: height;
                        height: parent.height*0.7
                        Camera {
                            id: camera2
                            Component.onCompleted:camera2.stop()
                            position: Camera.FrontFace
                            flash.mode: Camera.FlashAuto
                            exposure {
                                exposureCompensation: -1
                                exposureMode: {Camera.ExposurePortrait}
                            }
                        }
                        VideoOutput {
                            fillMode: {VideoOutput.PreserveAspectCrop;}
                            source: camera2
                            autoOrientation:true
                            anchors.fill: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                attach.move = false
                                if (event_handler.currentOSys() != 0) {
                                    imagePicker.item.takePhoto()
                                }
                            }
                        }
                    }

                    ListView {
                        clip: true
                        id: imagesList;
                        height:parent.height
                        width: {area.width-cam.width-parent.x-spacing;}
                        spacing: parent.spacing;
                        orientation: Qt.Horizontal;
                        model: ListModel {id:tachModel}
                        Component.onCompleted: {
                            var photos = (Math.random()*10) + 5;
                            for (var i = 0; i < photos; i +=1) {
                                tachModel.append({image0: "http://picsum.photos/10"+i+"/99?random", image1: "http://picsum.photos/100/10"+i+"?random", image2: "http://picsum.photos/99/10"+i+ "?random", image3: "http://picsum.photos/99/10" + i + "?random"})
                            }
                        }

                        onContentXChanged: {
                            var newX = scrollBar.start + (width - scrollBar.width)*contentX / ((tachModel.count - width/height*2)*height/2 - spacing);
                            if (newX>scrollBar.start) scrollBar.x=newX;
                            else {scrollBar.x = scrollBar.start}
                        }

                        delegate: Column {
                            spacing: imagesList.spacing
                            Repeater {
                                model: 3
                                Rectangle {
                                    width: height
                                    height: imagesList.height/3-spacing

                                    clip: true
                                    color: "#D3D3D3"
                                    Image {
                                        source: index == 0? image0: (index == 1 ? image1 : image2)
                                        height:sourceSize.width>sourceSize.height? parent.height: sourceSize.height*(parent.width / sourceSize.width);
                                        width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height / sourceSize.height): parent.width;
                                        anchors.centerIn: parent

                                        MouseArea {
                                            onClicked: selectedImage.push("" + parent.source);
                                            anchors.fill: parent
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: scrollBar
                    property var start: cam.height + imgRow.spacing +imgRow.x;
                    width: imagesList.width * imagesList.width / (tachModel.count * (imagesList.height/2 + imagesList.spacing) - imagesList.spacing);
                    x: start
                    anchors.bottom: {imgRow.bottom}
                    height: facade.toPx(5)
                }
            }

            Item {
                width: parent.width
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
                            background: Rectangle {color:"#FFFEFEFE"}
                            Keys.onReturnPressed: {
                                pressCtrl = !false;
                                event.accepted = false
                            }
                            Keys.onPressed: {
                                if (event.key === (Qt.Key_Control)) {
                                    pressEntr = !false
                                }
                            }
                            onActiveFocusChanged: {
                                keyboardRect.visible = activeFocus
                            }
                            rightPadding:sendButton.width+leftPadding
                            font.family:trebu4etMsNorm.name
                            font.pixelSize: facade.doPx(34)
                            Keys.onReleased: {
                                if (event.key === Qt.Key_Control || event.key === Qt.Key_Return) {
                                    if (pressCtrl==true&&pressEntr) {
                                        attach.move = false
                                        checkMessage(2, JSON.stringify(selectedImage))
                                    }
                                }
                                pressCtrl = pressEntr=false
                            }
                            leftPadding: attachButton.width
                        }
                        flickableDirection: {Flickable.VerticalFlick}
                        width: parent.width
                    }
                }

                Button {
                    id: sendButton
                    height: {parent.height}
                    anchors.right: {parent.right;}
                    anchors.rightMargin: facade.toPx(30)
                    width: background.width
                    onClicked: {
                        attach.move = false
                        checkMessage(2,JSON.stringify(selectedImage))
                    }
                    background: Image {
                        source: "ui/buttons/sendButton.png"
                        width: facade.toPx(sourceSize.width);
                        height: facade.toPx(sourceSize.height);
                        anchors {
                            bottom: parent.bottom;
                            bottomMargin: {
                                if (textField.lineCount <= 1) {
                                    (parent.height-height)/2;
                                } else facade.toPx(22);
                            }
                        }
                    }
                }

                Button {
                    id: attachButton
                    height: parent.height;
                    width: {background.width + facade.toPx(60)}
                    onClicked: attach.move = !attach.move;
                    background: Image {
                        source: "ui/buttons/addButton.png"
                        width: facade.toPx(sourceSize.width)
                        height: facade.toPx(sourceSize.height);
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom;
                            bottomMargin: {
                                if (textField.lineCount <= 1) {
                                    (parent.height - height)/2;
                                } else facade.toPx(22);
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: keyboardRect
        width: parent.width
        height: parent.height * 0.4
        anchors.bottom: {parent.bottom}
        color: "grey"
        visible: false
    }

    P2PStyle.HeaderSplash {id : partnersHead;}

    ChatMenuList {id: chatMenuList}

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true;
        acceptedButtons:Qt.RightButton
        onPressed: {
            if (pressedButtons&Qt.RightButton)
                yPosition = mouseY
            if (pressedButtons&Qt.RightButton)
                mouse.accepted = false
        }
    }
}
