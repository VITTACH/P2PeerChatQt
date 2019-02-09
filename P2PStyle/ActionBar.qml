import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.3

Column {
    id: header
    width: parent.width

    property var text: ""
    property var photo: ""
    property var status: ""
    property int page: -1
    property int payload: 0

    function addPage(pageName) {
        pageModel.append({target: pageName})
    }

    Rectangle {
        width: parent.width
        height: facade.toPx(140)
        color: {loader.headBackgroundColor;}

        Button {
            id: button
            x: facade.toPx(30)
            width: facade.toPx(100)
            height: width
            anchors.verticalCenter: parent.verticalCenter

            background: Image {
                source: "/ui/buttons/" + (payload == 1 || loader.webview? "back": (payload < 0? "more": "infor")) + "Button.png"
                height:facade.toPx(sourceSize.height)
                width: facade.toPx(sourceSize.width);
                fillMode: Image.PreserveAspectFit;
                anchors.centerIn: {parent}
            }

            visible: payload != 0 || loader.isLogin || loader.webview

            onClicked: {
                if (payload > 0) payload--
                else if (loader.webview == true) {
                    loader.webview = false
                    header.text =""
                    if (loader.isLogin == false) {
                        loader.back()
                    }
                } else if (loader.chatOpen) {
                    chatMenuList.xPosition = (header.width - chatMenuList.w - facade.toPx(30))
                    chatMenuList.yPosition = (facade.toPx(20))
                    loader.focus = loader.context = true;
                } else loader.drawOpen = true
            }
        }

        Row {
            spacing: facade.toPx(30)

            anchors {
                verticalCenter: parent.verticalCenter
                left: loader.isLogin? button.right : undefined
                leftMargin: loader.isLogin?button.x:0
                horizontalCenter: loader.isLogin == true ? undefined : parent.horizontalCenter
            }

            Item {
                id: bug
                height: facade.toPx(90);
                width: visible? height:0
                visible: {payload < 0 && (header.phot !== "")}
                anchors.verticalCenter: parent.verticalCenter;

                Image {
                    source: photo
                    anchors.fill: parent
                    anchors.margins: {iamgeBorder.radius/3.50}
                }

                Rectangle {
                    id: iamgeBorder
                    anchors.fill: parent
                    color: "transparent"
                    radius: facade.toPx(15)
                    border.width: facade.toPx(5)
                    border.color: "#A5A5A5"
                }
            }

            Column {
                spacing: facade.toPx(10)

                Text {
                    width: Math.min((header.width - bug.width-facade.toPx(160)),implicitWidth)
                    color: "white"

                    font.family: trebu4etMsNorm.name;
                    font.pixelSize: loader.isLogin == true ? facade.doPx(26) : facade.doPx(30)
                    text: header.text.replace("\n", "")
                    elide: Text.ElideRight
                }

                Text {
                    font.family: trebu4etMsNorm.name;
                    font.bold: true
                    font.pixelSize: facade.doPx(18)
                    visible: loader.isLogin && !loader.webview
                    color: text == "Online"?"white":"darkgrey"
                    text: header.status.replace("\n", "")
                }
            }
        }
    }

    Rectangle {
        width: parent.width
        height: facade.toPx(90)
        color: loader.headBackgroundColor
        visible: page >= 0 && !loader.webview

        ListView {
            anchors.fill: parent
            orientation: Qt.Horizontal;

            model: ListModel {id: pageModel;}

            delegate: Item {
                clip: true
                width: facade.toPx(200)
                height: {parent.height}

                Rectangle {
                    id: coloresRect
                    color: "#80FFFFFF"

                    transform: Translate {
                        x:-coloresRect.width /2
                        y:-coloresRect.height/2
                    }
                }

                MouseArea {
                    anchors.fill:parent

                    onPressed: {
                        coloresRect.x = mouseX;
                        coloresRect.y = mouseY;
                        circleAnimation.start()
                    }

                    onPositionChanged: {
                        circleAnimation.stop();
                        coloresRect.height = 0
                        coloresRect.width = 0
                    }

                    onReleased: {
                        circleAnimation.stop();
                        coloresRect.height = 0;
                        coloresRect.width = 0
                    }

                    onClicked: page = index
                }

                PropertyAnimation {
                    duration: 300
                    id: circleAnimation
                    target: coloresRect
                    properties: "width,height,radius"
                    from: 0
                    to: parent.width
                }

                Text {
                    font.weight: Font.DemiBold;
                    font.family: trebu4etMsNorm.name;
                    font.pixelSize: {facade.doPx(22)}
                    anchors.centerIn: parent
                    color: "white"
                    text: target
                }

                Rectangle {
                    anchors {
                        bottom: parent.bottom;
                    }
                    visible: index == page
                    height: facade.toPx(3)
                    width: parent.width
                }
            }
        }
    }
}
