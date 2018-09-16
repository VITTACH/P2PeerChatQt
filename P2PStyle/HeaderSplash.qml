import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    id: rootItem
    width: parent.width;
    height: facade.toPx(150);

    DropShadow {
        radius: 10
        samples: (16);
        source: headRect;
        color: {"#70000000"}
        anchors.fill: headRect
        visible: headRect.visible
    }
    property string stat: ""
    property string phot: ""
    property string text: ""
    property int page: 0

    function load(value) {headerLine.width = value*rootItem.width}

    Rectangle {
        id: headRect
        width: parent.width;
        height: facade.toPx(140);
        color: loader.head1Color;
        visible: loader.source!="qrc:/qrscaner.qml"&&loader.source!="qrc:/webview.qml"

        Item {
            id: inerItem
            height: parent.height
            anchors.left: page!=0 || loader.isLogin? hambrgrButton.right: parent.left;
            anchors.right: {parent.right}
            anchors.rightMargin: page > 0 ? hambrgrButton.width: 0

            Row {
                spacing: facade.toPx(30);
                anchors {
                    verticalCenter: parent.verticalCenter;
                    left: (loader.isLogin)? parent.left: undefined
                    centerIn: (loader.isLogin)? undefined: parent;
                    leftMargin: loader.isLogin? facade.toPx(20):0;
                    horizontalCenter: loader.isLogin?undefined:parent.horizontalCenter
                }

                Item {
                    width: bug.width
                    height: parent.height
                    visible: {page < 0 && (rootItem.phot !== "");}

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
                        width: facade.toPx(90)
                        height:facade.toPx(90)
                        anchors {
                            verticalCenter: parent.verticalCenter;
                        }
                        Image {
                            source: phot;
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

                    Image {
                        id: mask
                        smooth:true
                        visible: false
                        source: "qrc:/ui/mask/round.png"
                        sourceSize: Qt.size(bug.width, bug.height)
                    }
                }

                Column {
                    spacing: {facade.toPx(10)}
                    Text {
                        color: "white"
                        elide: Text.ElideRight
                        width: {Math.min((inerItem.width - bug.width), implicitWidth)}
                        text: {rootItem.text.replace("\n", (""));}

                        font.family: trebu4etMsNorm.name
                        font.pixelSize: loader.isLogin?facade.doPx(28):facade.doPx(34)
                    }
                    Text {
                        text: str
                        font.bold: true
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(20);
                        visible: loader.isLogin && !loader.webview
                        color: str == "Online"? "white":"darkgrey"
                        property string str: {return rootItem.stat.replace("\n", "");}
                    }
                }
            }
        }

        Button {
            id: hambrgrButton;
            height:parent.height
            width: facade.toPx(140)
            onClicked: {
                if (page == 1) page-=1; else if (loader.webview) loader.webview = false;
                else if (loader.chatOpen) {
                    loader.focus = loader.context = (true)
                    chatMenuList.xPosition=rootItem.width-chatMenuList.w-facade.toPx(30)
                    chatMenuList.yPosition=facade.toPx(20)
                } else loader.drawOpen=true
                loader.focus = true
            }

            visible: page!=0 || loader.isLogin? true:false
            anchors.verticalCenter: parent.verticalCenter;

            background: Image {
                id: hambrgrButtonImage;
                height:facade.toPx(sourceSize.height* 1.0)
                width: facade.toPx(sourceSize.width * 1.0)
                fillMode: {(Image.PreserveAspectFit)}
                source: "../ui/buttons/" + (page == 1 || loader.webview? "back": (page < 0? "more": "infor")) + "Button.png";
                anchors.centerIn:parent
            }
        }

        Rectangle {
            id: headerLine
            width: parent.width
            height:facade.toPx(6)
            opacity: 0.3
            z: 1000
            color: {loader.head2Color}
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
    }
}
