import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Column {
    id: header
    width: parent.width

    property var text: ""
    property var photo: ""
    property var status: ""

    property int page: -1
    property int payload: 0

    Rectangle {
        width: parent.width
        height: facade.toPx(140)
        color: loader.headBackgroundColor;

        Button {
            id: button
            x: facade.toPx(30)
            width: facade.toPx(100)
            height: width
            anchors {
                verticalCenter: parent.verticalCenter
            }

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

    function addPage(pageName) {
        pageModel.append({target: pageName})
    }

    Rectangle {
        width: parent.width
        height: facade.toPx(80)
        color: loader.headBackgroundColor
        visible: page >= 0;

        ListView {
            anchors.fill: parent
            orientation: Qt.Horizontal
            model: ListModel {id: pageModel}

            delegate: Item {
                height: parent.height;
                width: content.implicitWidth+facade.toPx(100)

                Text {
                    id: content;
                    font.family:trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(16)
                    font.capitalization: {Font.AllUppercase;}
                    anchors.centerIn: parent
                    text: target
                }

                Rectangle {
                    visible: {index == page}
                    anchors.bottom: {parent.bottom}
                    height: facade.toPx(4)
                    width: parent.width
                }
            }
        }
    }
}
