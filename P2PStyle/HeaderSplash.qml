import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: rootRect
    width: parent.width;
    height: facade.toPx(140)
    color: loader.headBackgroundColor;

    property int page: 0
    property var text: ""
    property var photo: ""
    property var status: ""

    Button {
        id: actionButton
        x: facade.toPx(30)
        anchors.verticalCenter: parent.verticalCenter
        width: facade.toPx(100)
        height: width
        visible: page!=0 ||loader.isLogin ||loader.webview

        onClicked: {
            if (page > 0) page = page - 1
            else if (loader.webview == true) {
                loader.webview = false
                rootRect.text =""
                if (loader.isLogin == false) {
                    loader.back()
                }
            } else if (loader.chatOpen) {
                chatMenuList.xPosition = rootRect.width - chatMenuList.w - facade.toPx(30)
                chatMenuList.yPosition = (facade.toPx(20))
                loader.focus = loader.context = true;
            } else loader.drawOpen = true
        }

        background: Image {
            source: "qrc:/ui/buttons/" + (page == 1 || loader.webview ? "back" : (page < 0 ? "more" : "infor")) + "Button.png"
            height:facade.toPx(sourceSize.height)
            width: facade.toPx(sourceSize.width);
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
        }
    }

    Row {
        id: row
        spacing: facade.toPx(30)
        anchors {
            verticalCenter: parent.verticalCenter
            left: loader.isLogin == true ? actionButton.right : undefined
            leftMargin: loader.isLogin? actionButton.x: 0;
            horizontalCenter: loader.isLogin == true ? undefined : parent.horizontalCenter
        }

        Item {
            id: bug
            height: facade.toPx(90);
            width: visible? height:0
            visible: (page < 0) && (rootRect.phot !== "");
            anchors.verticalCenter: parent.verticalCenter;

            Image {
                source: photo
                anchors.fill: parent
                anchors.margins: bor.radius/3.50;
            }

            Rectangle {
                id: bor
                radius: facade.toPx(15)
                anchors.fill: parent
                border.width: facade.toPx(5)
                border.color: "#A5A5A5"
                color: "transparent"
            }
        }

        Column {
            spacing: facade.toPx(10)

            Text {
                width: Math.min((rootRect.width-bug.width-facade.toPx(160)),implicitWidth)
                color: "white"

                font.family: trebu4etMsNorm.name;
                font.pixelSize: loader.isLogin == true ? facade.doPx(26) : facade.doPx(30)
                text: rootRect.text.replace("\n", "")
                elide: Text.ElideRight
            }

            Text {
                font.family: trebu4etMsNorm.name;
                font.bold: true
                font.pixelSize: facade.doPx(18)
                visible: loader.isLogin && !loader.webview
                color: text == "Online"?"white":"darkgrey"
                text: rootRect.status.replace("\n", "")
            }
        }
    }

    Rectangle {
        opacity: 0.5
        anchors.bottom: parent.bottom
        color: loader.head2Color
        height: facade.toPx(5)
        width: parent.width
    }
}
