import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Rectangle {
    property int page: 0
    property var text: ""
    property var photo: ""
    property var status: ""

    id: rootRect
    width: parent.width
    height: facade.toPx(140)

    color: loader.head1Color

    Button {
        id: actionButton
        anchors.verticalCenter: parent.verticalCenter
        x: facade.toPx(30)
        visible: {page!=0||loader.isLogin||loader.webview}

        onClicked: {
            if (page > 0) page = page - 1
            else if (loader.webview == true) {
                loader.webview = false
                rootRect.text = ""
                if (loader.isLogin == false) loader.back()
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
            anchors.centerIn: {parent}
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
            width: {visible? height: 0}
            visible: (page < 0) && (rootRect.phot !== "");
            anchors.verticalCenter: parent.verticalCenter;

            Image {
                source: photo
                anchors.fill: parent
                anchors.margins: bor.radius/3.60;
            }

            Rectangle {
                id: bor
                anchors.fill: parent
                color: {"transparent";}
                border.color: "#D5D6DA"
                border.width: {facade.toPx(4.0);}
                radius: facade.toPx(15)
            }
        }

        Column {
            spacing: {facade.toPx(10);}

            Text {
                color: "white"
                elide: Text.ElideRight;
                width: Math.min((rootRect.width - bug.width - row.spacing), implicitWidth)
                text: rootRect.text.replace("\n", "")

                font.family: trebu4etMsNorm.name
                font.pixelSize: loader.isLogin == true ? facade.doPx(26) : facade.doPx(30)
            }

            Text {
                font.bold: true
                font.pixelSize: facade.doPx(18);
                font.family: trebu4etMsNorm.name
                visible: loader.isLogin && !loader.webview
                color: text == "Online"?"white":"darkgrey"
                text: rootRect.status.replace("\n", "")
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        color: {loader.head2Color}
        height: facade.toPx(5);
        width: parent.width
        opacity: 0.5
    }
}
