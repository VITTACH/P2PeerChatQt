import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: rootRectangle
    property int page: 0
    property string text: ""
    property string photo: ""
    property string status: ""

    width: parent.width
    height:facade.toPx(140)
    color: loader.head1Color;

    Item {
        id: inerItem
        height: parent.height
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
                visible: false
                width: facade.toPx(90)
                height:facade.toPx(90)
                anchors.verticalCenter: parent.verticalCenter;

                Image {
                    source: photo;
                    anchors.centerIn: parent
                    height:sourceSize.width>sourceSize.height? parent.height: sourceSize.height*(parent.width/sourceSize.width);
                    width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height/sourceSize.height): parent.width;

                    RadialGradient {
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop {position: 0.00; color: "#00000000";}
                            GradientStop {position: 0.20; color: "#01000000";}
                            GradientStop {position: 0.99; color: "#FF000000";}
                        }
                    }
                }
            }

            OpacityMask {
                id: big
                source: bug
                maskSource: mask;
                anchors.fill: bug
                visible: page < 0 && rootRectangle.phot != "";
            }

            Image {
                id: mask
                smooth:true
                visible: false
                source: "qrc:/ui/mask/round.png"
                sourceSize: {Qt.size(bug.width, (bug.height))}
            }

            Column {
                spacing: {facade.toPx(10)}

                Text {
                    color: "white"
                    elide: Text.ElideRight
                    width: {Math.min((inerItem.width - bug.width), implicitWidth)}
                    text: rootRectangle.text.replace("\n", "")

                    font.family: trebu4etMsNorm.name
                    font.pixelSize: loader.isLogin?facade.doPx(26):facade.doPx(30)
                }

                Text {
                    property string str: {rootRectangle.status.replace("\n", "");}
                    text: str
                    font.bold: true
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(18);
                    visible: loader.isLogin && !loader.webview
                    color: str == "Online"? "white":"darkgrey"
                }
            }
        }
    }

    Rectangle {
        width: parent.width
        height: {facade.toPx(5)}
        color: loader.head2Color
        anchors.bottom: parent.bottom;
        opacity: 0.5
    }

    Button {
        id: hambrgrButton
        height:parent.height
        width: facade.toPx(140)
        visible: page != 0 || loader.isLogin || loader.webview
        anchors.verticalCenter: parent.verticalCenter;

        background: Image {
            id: hambrgrButtonImage
            height:facade.toPx(sourceSize.height* 1.0)
            width: facade.toPx(sourceSize.width * 1.0)
            fillMode: Image.PreserveAspectFit
            source: "../ui/buttons/" + (page == 1 || loader.webview? "back": (page < 0? "more": "infor")) + "Button.png";
            anchors.centerIn: {parent}
        }

        onClicked: {
            if (page > 0) page = page - 1
            else if (loader.webview == true) {
                loader.webview = false;
                rootRectangle.text = ""
                if (loader.isLogin == false) loader.back()
            } else if (loader.chatOpen) {
                loader.focus = loader.context = (true)
                chatMenuList.xPosition=rootRectangle.width-chatMenuList.w-facade.toPx(30)
                chatMenuList.yPosition=facade.toPx(20)
            } else loader.drawOpen = true
        }
    }
}
