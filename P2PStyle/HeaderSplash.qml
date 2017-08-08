import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Button {
    id: rootItem
    property int page
    property int h: 150;
    property string stat
    property string phot

    DropShadow {
        radius: 20
        samples: 16
        anchors {
            fill:headerRect
        }
        color: "#60000000";
        source: headerRect;
    }
    Rectangle {
        id: headerRect
        width: parent.width
        height: facade.toPx(h - 10)
        color: loader.source == "qrc:/loginanDregister.qml"? ("#3589E9"): ("#4F81B6");

        Item {
            id: inerItem
            Row {
                spacing: facade.toPx(30)
                anchors.left: loader.source == "qrc:/chat.qml"? parent.left: undefined
                anchors.leftMargin: loader.source == "qrc:/chat.qml"?facade.toPx(50):0
                anchors.centerIn: (loader.source == "qrc:/chat.qml")? undefined:parent
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: loader.source == "qrc:/chat.qml"?undefined: parent.horizontalCenter
                }

                Item {
                    width: bug.width
                    height:parent.height
                    visible: (loader.source == "qrc:/chat.qml" && rootItem.phot != "")==true? true: false

                    OpacityMask {
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
                    Text {
                        color:"#FFFFFF"
                        styleColor: "black"
                        style: Text.Raised;
                        elide: Text.ElideLeft
                        width: Math.min(inerItem.width - bug.width - facade.toPx(90), this.implicitWidth)
                        text: {rootItem.text.replace("\n" , "");}

                        font.pixelSize: loader.source == "qrc:/chat.qml"? facade.doPx(28):facade.doPx(34)
                        font.family:trebu4etMsNorm.name
                    }
                    Text {
                        color:"#FFFFFF"
                        visible: loader.source == "qrc:/chat.qml"
                        text: {rootItem.stat.replace("\n" , "");}

                        font.bold: true
                        font.pixelSize: facade.doPx(20)
                        font.family:trebu4etMsNorm.name
                    }
                }
            }
            height: parent.height
            anchors.left: page != 0 || loader.source == ("qrc:/chat.qml")?hambrgrButton.right:parent.left
            anchors.right:page != 0 || loader.source == ("qrc:/chat.qml")?hamMoreButton.left:parent.right
        }

        DropShadow {
            radius: 10
            samples: 20
            color: ("#CC000000")
            source:hambrgrButton
            anchors.fill:hambrgrButton
            visible:page==1?true:false
        }
        Button {
            x: facade.toPx(40)
            id: hambrgrButton;
            visible: (page != 0 || loader.source == ("qrc:/chat.qml"))
            width: Math.max(hambrgrButtonImage.width, facade.toPx(70))
            height:Math.max(hambrgrButtonImage.height,facade.toPx(70))
            anchors.verticalCenter: parent.verticalCenter
            background: Image{
                id: hambrgrButtonImage
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                height:facade.toPx(sourceSize.height*1.2)
                width: facade.toPx(sourceSize.width *1.2)
                fillMode: Image.PreserveAspectFit;
                source: "qrc:/ui/buttons/" + (page === 1? "back": "infor") + "Button.png";
            }
            onClicked: page==1? page--: menuDrawer.open()
        }

        Button {
            id: hamMoreButton;
            visible:loader.source == "qrc:/chat.qml";
            width: Math.max(hamMoreButtonImage.width, facade.toPx(70))
            height:Math.max(hamMoreButtonImage.height,facade.toPx(70))
            x: parent.width-facade.toPx(20)-width;
            anchors.verticalCenter: parent.verticalCenter
            background: Image{
                id: hamMoreButtonImage
                source: "qrc:/ui/buttons/moreButton.png";
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                height:facade.toPx(sourceSize.height*1.2)
                width: facade.toPx(sourceSize.width *1.2)
                fillMode: Image.PreserveAspectFit;
            }
            onClicked: {
                contextDialog.xPosition = rootItem.width- contextDialog.w- facade.toPx(20)
                contextDialog.yPosition = facade.toPx(20)
                loader.context = true;
            }
        }
    }

    contentItem: Text{opacity:0}
    width: parent.width
    height: facade.toPx(h)
    background: Rectangle {
        color:"transparent"
    }
}
