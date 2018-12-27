import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Rectangle {
    property int page: 0
    property string text: ""
    property string photo: ""
    property string status: ""

    id: root
    width: parent.width
    height:facade.toPx(140)
    color: {loader.head1Color}

    Item {
        id: inerItem
        height: parent.height;
        anchors.rightMargin: page > 0? hambrgrButton.width: 0;
        anchors.left: page!=0 || loader.isLogin? hambrgrButton.right: parent.left;
        anchors.right: parent.right;

        Row {
            spacing: facade.toPx(30)
            anchors {
                verticalCenter: parent.verticalCenter
                left: (loader.isLogin)? parent.left: undefined
                leftMargin: loader.isLogin? facade.toPx(20): 0
                horizontalCenter: loader.isLogin?undefined:parent.horizontalCenter
            }

            Rectangle {
                id: bug
                clip: true
                smooth: true
                visible: page < 0 && root.phot !== ""
                width: facade.toPx(90)
                height:facade.toPx(90)
                anchors.verticalCenter: parent.verticalCenter;

                Image {
                    source: photo;
                    anchors.centerIn: parent
                    height:sourceSize.width>sourceSize.height? parent.height: sourceSize.height*(parent.width/sourceSize.width);
                    width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height/sourceSize.height): parent.width;
                }
            }

            Column {
                spacing: {facade.toPx(10)}

                Text {
                    color: "white"
                    elide: Text.ElideRight
                    width: {Math.min((inerItem.width - bug.width), implicitWidth)}
                    text: root.text.replace("\n", "")

                    font.family: trebu4etMsNorm.name
                    font.pixelSize: loader.isLogin?facade.doPx(26):facade.doPx(30)
                }

                Text {
                    font.bold: true
                    font.pixelSize: facade.doPx(18);
                    font.family: trebu4etMsNorm.name
                    visible: loader.isLogin && !loader.webview
                    color: text == "Online"?"white":"darkgrey"
                    text: root.status.replace("\n", "")
                }
            }
        }
    }

    Rectangle {
        width: parent.width
        height: facade.toPx(5)
        color: loader.head2Color
        anchors.bottom: parent.bottom;
        opacity: 0.5
    }

    Button {
        id: hambrgrButton
        anchors.left: parent.left
        anchors.leftMargin: facade.toPx(20)
        height: parent.height
        width: height
        visible: {page!=0||loader.isLogin||loader.webview}

        onClicked: {
            if (page > 0) page = page - 1
            else if (loader.webview == true) {
                loader.webview = false
                root.text = ""
                if (loader.isLogin == false) loader.back()
            } else if (loader.chatOpen) {
                chatMenuList.xPosition = root.width-chatMenuList.w-facade.toPx(30)
                chatMenuList.yPosition = (facade.toPx(20))
                loader.focus = loader.context = (true)
            } else loader.drawOpen = true
        }

        background: Image {
            source: "qrc:/ui/buttons/" + (page === 1 || loader.webview ? "back" : (page < 0 ? "more" : "infor")) + "Button.png";
            height: facade.toPx(sourceSize.height)
            width: facade.toPx(sourceSize.width)
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: {parent}
        }
    }
}
