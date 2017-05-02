import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Button {
    Rectangle {
        color: "#3589E9"
        width: parent.width
        height:facade.toPx(120)

        Text {
            color: "#FFFFFF"
            styleColor: "black"
            style: Text.Raised
            anchors.centerIn: {parent}
            text: {parent.parent.text}

            font {
            pixelSize: facade.doPx(32)
            family:trebu4etMsNorm.name
            }
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

    Button {
        x: facade.toPx(20)
        visible: (loader.source != "qrc:/login.qml");
        width: 2*hambrgrButtonImage.width;
        height:2*hambrgrButtonImage.height
        background: Rectangle {opacity: 0}
        anchors.verticalCenter: parent.verticalCenter
        Image {
        id: hambrgrButtonImage
        anchors.verticalCenter: parent.verticalCenter
        height:facade.toPx(sourceSize.height*1.2 - 6)
        width: facade.toPx(sourceSize.width *1.2)
        fillMode: Image.PreserveAspectFit;
        source: "qrc:/ui/buttons/" + (loader.source=="qrc:/regin.qml"? "back":"infor") + "Button.png"
        }
        onClicked: loader.source == "qrc:/regin.qml"? loader.back(): menuDrawer.open()
    }

    contentItem: Text {opacity: 0;}
    width: parent.width
    height:facade.toPx(130)
    background: Rectangle {
        color: "transparent"
    }
}
