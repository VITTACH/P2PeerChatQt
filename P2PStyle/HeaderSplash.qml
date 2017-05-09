import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Button {
    id: rootItem
    property string stat
    property string phot

    Rectangle {
        color: "#3589E9"
        width: {parent.width}
        height: facade.toPx(120);

        Item {
            id: inerItem
            Row {
                spacing: facade.toPx(30)
                anchors.centerIn: parent

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

                        font.pixelSize: facade.doPx(26)
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
            anchors.left: (loader.source != "qrc:/login.qml") === true? hambrgrButton.right: parent.left;
            anchors.right: (loader.source != "qrc:/login.qml") == true? hamMoreButton.left: parent.right;
        }

        Button {
        x: facade.toPx(20)
        id: hambrgrButton;
        visible: (loader.source != "qrc:/login.qml");
        width: hambrgrButtonImage.width
        height:2*hambrgrButtonImage.height
        background: Rectangle {opacity: 0}
        anchors.verticalCenter: parent.verticalCenter
        Image {
            id: hambrgrButtonImage
            anchors {
                verticalCenter: parent.verticalCenter
            }
            height:facade.toPx(sourceSize.height*1.2)
            width: facade.toPx(sourceSize.width *1.2)
            fillMode: Image.PreserveAspectFit;
            source: "qrc:/ui/buttons/" + (loader.source=="qrc:/regin.qml"? "back":"infor") + "Button.png"
        }
        onClicked: loader.source == "qrc:/regin.qml"? loader.back(): menuDrawer.open()
        }

        Button {
        id: hamMoreButton;
        visible:loader.source == "qrc:/chat.qml";
        width: hamMoreButtonImage.width
        height:2*hamMoreButtonImage.height
        background: Rectangle {opacity: 0}
        anchors.verticalCenter: parent.verticalCenter
        Image {
            id: hamMoreButtonImage
            source: "qrc:/ui/buttons/moreButton.png";
            anchors {
                verticalCenter: parent.verticalCenter
            }
            height:facade.toPx(sourceSize.height*1.2)
            width: facade.toPx(sourceSize.width *1.2)
            fillMode: Image.PreserveAspectFit;
        }
        x: parent.width-facade.toPx(20)-width;
        }
    }

    Rectangle {
        color: "transparent"
        width: parent.width
        height: facade.toPx(10);
        anchors.bottom: parent.bottom;
        LinearGradient {
            anchors.fill: parent
            start:Qt.point(0, 0)
            end:Qt.point(0, parent.height)
            gradient: Gradient {
                GradientStop {
                    position: 0.0; color: "#60000000"
                }
                GradientStop {
                    position: 1.0; color: "#10000000"
                }
            }
        }
    }

    contentItem: Text{opacity:0}
    width: parent.width
    height:facade.toPx(130)
    background: Rectangle {
        color:"transparent"
    }
}
