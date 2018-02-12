import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    id: rootItem
    width: parent.width
    height: facade.toPx(150);

    DropShadow {
        radius: 15
        samples: 16
        verticalOffset: 10;
        color: "#60000000";
        source: (headRect);
        visible: headRect.visible;
        anchors.fill: {(headRect)}
    }
    Rectangle {
        id: headRect
        width: parent.width
        height: {facade.toPx(140)}
        visible:{loader.source!= "qrc:/qrscaner.qml"}
        color: {
            if (loader.source == "qrc:/loginanDregister.qml")
                loader.menu1Color;
            else loader.head1Color
        }

        Item {
            id: inerItem
            Row {
                spacing: facade.toPx(30);
                anchors {
                    verticalCenter:parent.verticalCenter
                    left: (loader.isLogin)? parent.left:undefined
                    centerIn: (loader.isLogin)? undefined: parent
                    leftMargin: loader.isLogin? facade.toPx(20):0
                    horizontalCenter: loader.isLogin? undefined: parent.horizontalCenter
                }

                Item {
                    width: bug.width
                    height: parent.height
                    visible: (loader.source == "qrc:/chat.qml") && (rootItem.phot != "")

                    DropShadow {
                        radius: 15
                        samples: 15
                        source: big
                        opacity: 0.56;
                        color: "black"
                        anchors.fill: big
                    }
                    OpacityMask {
                        id: big
                        source: bug
                        maskSource: mask;
                        anchors.fill: bug
                    }
                    Rectangle {
                        id: bug
                        clip: true
                        smooth: true
                        visible: false
                        width: facade.toPx(80)
                        height:facade.toPx(80)
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                        Image {
                            source: phot;
                            anchors.centerIn: {(parent)}
                            height:sourceSize.width>sourceSize.height? parent.height: sourceSize.height*(parent.width/sourceSize.width);
                            width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height/sourceSize.height): parent.width;
                        }
                    }

                    Image {
                        id: mask
                        smooth: true;
                        visible:false
                        source: "qrc:/ui/mask/round.png"
                        sourceSize: Qt.size(bug.width,bug.height)
                    }
                }

                Column {
                    Text {
                        color: "white"
                        elide: Text.ElideRight
                        width: {
                            var margin= loader.source=="qrc:/chat.qml"?facade.toPx(90):0
                            Math.min(inerItem.width - bug.width - margin, implicitWidth)
                        }
                        text:  {rootItem.text.replace("\n" , "")}

                        font.pixelSize: loader.isLogin? facade.doPx(28): facade.doPx(34)
                        font.family: trebu4etMsNorm.name
                    }
                    Text {
                        text: str

                        font.bold: true
                        font.pixelSize: facade.doPx(20);
                        font.family: trebu4etMsNorm.name

                        visible: loader.isLogin && !loader.webview
                        color: str == "Online"? "white":"darkgrey"
                        property string str: {
                            return rootItem.stat.replace("\n", "")
                        }
                    }
                }
            }
            height: parent.height
            anchors.left: page != 0 || loader.isLogin? hambrgrButton.right: parent.left;
            anchors.right:page != 0 || loader.isLogin? hamMoreButton.left: parent.right;
        }

        Button {
            id: hambrgrButton;
            height:parent.height
            width: facade.toPx(140)
            onClicked: {
                if (page == 1) {page -= 1}
                else if (loader.source == "qrc:/chat.qml")
                    loader.back()
                else if (loader.webview) {
                    loader.webview = false
                } else blankeDrawer.open()
                loader.focus=true
            }

            visible: page!=0 || loader.isLogin? true:false
            anchors.verticalCenter: parent.verticalCenter;

            background: Image {
                id: hambrgrButtonImage;
                fillMode: {(Image.PreserveAspectFit)}
                source: "qrc:/ui/buttons/" + (page == 1 || loader.source == "qrc:/chat.qml" || loader.webview ? "back" : "infor") + "Button.png"
                anchors.centerIn:parent
                height:facade.toPx(sourceSize.height* 1.2)
                width: facade.toPx(sourceSize.width * 1.2)
            }
        }

        Canvas {
            id: canva
            height: parent.height
            anchors.right: {parent.right;}
            visible: loader.source == "qrc:/chat.qml"
            width: {hamMoreButton.width + facade.toPx(20)}
            Connections {
                target: {loader;}
                onIsOnlineChanged: {canva.requestPaint();}
            }

            onPaint: {
                var cntx =getContext("2d")
                cntx.reset()
                cntx.fillStyle = loader.head1Color
                cntx.beginPath();
                cntx.moveTo(0,height)
                cntx.lineTo(width, height)
                cntx.lineTo(width, 0)
                cntx.lineTo(0, 0)
                cntx.closePath();
                cntx.fill();

                cntx.fillStyle = loader.isOnline? loader.head2Color: loader.head1Color
                cntx.beginPath();
                cntx.moveTo(0,height)
                cntx.lineTo(6,height)
                cntx.lineTo(6,0);
                cntx.lineTo(0,0);
                cntx.closePath();
                cntx.fill();
            }
        }

        Rectangle {
            id: headerLine
            width: parent.width
            height:facade.toPx(5)
            color: {
                if (loader.source != "qrc:/loginanDregister.qml")
                    loader.head2Color;
                else loader.head3Color
            }
            anchors {
                bottom: parent.bottom;
            }
            Connections {
                target: rootItem;
                onWidthChanged: {
                    if (!(headerLine.width > 0&&headerLine.width < facade.toPx(90))) {
                        headerLine.width = rootItem.width;
                    }
                }
            }
        }

        Button {
            id: hamMoreButton
            height: parent.height;
            width:facade.toPx(100)
            visible:loader.source == "qrc:/chat.qml";
            x:parent.width - width - facade.toPx(10);
            anchors.verticalCenter:(parent.verticalCenter)

            onClicked: {
                loader.focus = loader.context = true;
                chatMenuList.xPosition = rootItem.width-chatMenuList.w-facade.toPx(20)
                chatMenuList.yPosition = (facade.toPx(20))
            }

            background: Image {
                anchors.centerIn: {parent}
                source: ("qrc:/ui/buttons/moreButton.png")
                height:facade.toPx(sourceSize.height* 1.2)
                width: facade.toPx(sourceSize.width * 1.2)
                fillMode: Image.PreserveAspectFit;
            }
        }
    }

    function load(value) {
        headerLine.width = value * rootItem.width;
    }

    property string stat
    property string phot
    property string text
    property int page
}
