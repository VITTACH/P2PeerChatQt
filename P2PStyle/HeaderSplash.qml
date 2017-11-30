import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    id: rootItem
    property int page
    property string stat
    property string phot
    property string text

    width: parent.width;
    height:facade.toPx(150)
    DropShadow {
        radius: 15
        samples: 16
        anchors.fill: headerRect
        verticalOffset: 10;
        color: "#60000000";
        source: headerRect;
    }
    Rectangle {
        id: headerRect
        width: parent.width
        height: facade.toPx(140)
        color: {
            if (loader.source == "qrc:/loginanDregister.qml")
                loader.head1Color
            else
                loader.head1Color
        }

        Item {
            id: inerItem
            Row {
                spacing: facade.toPx(30)
                anchors {
                    left: (loader.isLogin)? parent.left:undefined
                    leftMargin: loader.isLogin? facade.toPx(50):0
                    centerIn: (loader.isLogin)? undefined: parent
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: loader.isLogin? undefined: parent.horizontalCenter
                }

                Item {
                    width: bug.width
                    height:parent.height
                    visible: loader.source == "qrc:/chat.qml" && rootItem.phot != ""

                    DropShadow {
                        radius: 15
                        samples: 15
                        source: big
                        opacity: 0.56;
                        color: "black"
                        anchors.fill:big
                    }
                    OpacityMask {
                        id: big
                        source: bug
                        maskSource: mask
                        anchors.fill:bug
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
                            source: phot
                            anchors.centerIn: {parent}
                            height:sourceSize.width>sourceSize.height? parent.height: sourceSize.height*(parent.width/sourceSize.width);
                            width: sourceSize.width>sourceSize.height? sourceSize.width*(parent.height/sourceSize.height): parent.width;
                        }
                    }

                    Image {
                        id: mask
                        smooth: true;
                        visible:false
                        source:"qrc:/ui/mask/round.png"
                        sourceSize: Qt.size(bug.width,bug.height)
                    }
                }

                Column {
                    visible: loader.source != "qrc:/profile.qml";
                    Text {
                        color:"#FFFFFF"
                        styleColor: "black"
                        style: Text.Raised;
                        elide: Text.ElideLeft
                        width: Math.min((inerItem.width - bug.width - facade.toPx(90)), (this.implicitWidth))
                        text: {rootItem.text.replace("\n" , "");}

                        font.pixelSize: loader.isLogin? facade.doPx(28): facade.doPx(34)
                        font.family:trebu4etMsNorm.name
                    }
                    Text {
                        text: str
                        visible: loader.isLogin
                        color: str == "Online"? "white":"darkgrey"
                        property string str: rootItem.stat.replace("\n" , "")

                        font.bold: true
                        font.pixelSize: facade.doPx(20)
                        font.family:trebu4etMsNorm.name
                    }
                }
            }
            height: parent.height
            anchors.left: page != 0 || loader.isLogin? hambrgrButton.right: parent.left;
            anchors.right:page != 0 || loader.isLogin? hamMoreButton.left: parent.right;
        }

        DropShadow {
            radius: 10
            samples: 20
            color: ("#CC000000")
            source:hambrgrButton
            anchors.fill: hambrgrButton
            visible: page==1?true:false
        }
        Button {
            id: hambrgrButton;
            visible: page!=0||loader.isLogin? true: false
            width: facade.toPx(150)
            height: {parent.height}
            anchors.verticalCenter: parent.verticalCenter
            background:Image {
                id: hambrgrButtonImage;
                fillMode: Image.PreserveAspectFit;
                source: "qrc:/ui/buttons/" + (page == 1 || loader.source == "qrc:/chat.qml" || loader.webview ? "back" : "infor") + "Button.png"
                anchors.centerIn:parent
                height:facade.toPx(sourceSize.height*1.2)
                width: facade.toPx(sourceSize.width *1.2)
            }
            onClicked: {
                if (page == 1) {page -= 1}
                else if(loader.source == "qrc:/chat.qml")
                    loader.back()
                else if (loader.webview) {
                    loader.webview = false
                } else {
                    basicMenuDrawer.open()
                }
                loader.focus = true
            }
        }

        Button {
            id: hamMoreButton;
            visible: (loader.source == "qrc:/chat.qml");
            width: facade.toPx(90);
            height: {parent.height}
            x: parent.width-facade.toPx(20)-width;
            anchors.verticalCenter: parent.verticalCenter
            background: Image{
                id: hamMoreButtonImage;
                fillMode: Image.PreserveAspectFit;
                source: "qrc:/ui/buttons/moreButton.png";
                anchors.centerIn:parent
                height:facade.toPx(sourceSize.height*1.2)
                width: facade.toPx(sourceSize.width *1.2)
            }
            onClicked: {
                contextDialog.xPosition = rootItem.width-contextDialog.w-facade.toPx(20)
                contextDialog.yPosition = facade.toPx(20)
                loader.context = true;
                loader.focus = true
            }
        }
    }
}
