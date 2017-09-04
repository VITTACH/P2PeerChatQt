import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Drawer {
    id: drawed
    property var vtate:false;

    dragMargin: {this.vtate? facade.toPx(40):0}

    function visible(state) {this.vtate =state}

    background: Rectangle {color:"transparent"}

    Connections {
        target: drawed
        onPositionChanged: {
            if (menuDrawer.position <= 0.100) {
                position = 0
            }
        }
    }

    closePolicy:{
        (Popup.CloseOnPressOutside | Popup.CloseOnEscape);
    }

    height: {parent.height;}
    width: {Math.min(facade.toPx(647), 0.74*parent.width)}

    Rectangle {
        color: "#727273"
        width: parent.width
        y: {menuDrawer.getProfHeight()}
        height: parent.height - menuDrawer.getProfHeight()

        ListView {
            clip: true
            id: listMenu
            anchors.fill: parent
            delegate: Item {
                id: element
                width: parent.width;
                height:facade.toPx(123)
                Rectangle {
                    id: body
                    clip: true
                    anchors.fill:parent
                    Rectangle {
                        width: 0
                        height: 0
                        id: coloresRect
                        color:"#d8d8d8"

                        transform: Translate {
                            x: -coloresRect.width /2
                            y: -coloresRect.height/2
                        }
                    }
                Row {
                    id: navigate
                    anchors.fill:parent
                    anchors.bottomMargin: 1
                    Image {
                        id: icon
                        source:index>0||element.ListView.isCurrentItem? (image1):(image2)
                        anchors.verticalCenter: parent.verticalCenter;
                        width: ((facade.toPx(sourceSize.width *1.5)));
                        height:((facade.toPx(sourceSize.height*1.5)));
                    }
                    Text {
                        text: target;
                        color:index>0||element.ListView.isCurrentItem? "#51587F": "white"
                        width: parent.width-icon.width-facade.toPx(40)
                        anchors.verticalCenter: parent.verticalCenter;
                        font.family: {trebu4etMsNorm.name}
                        font.pixelSize: {facade.doPx(32);}
                        elide: Text.ElideRight;
                    }
                    anchors.leftMargin: {facade.toPx(20);}
                    spacing: {facade.toPx(25);}
                }

                MouseArea {
                    anchors.fill:parent
                    onExited: {
                        circleAnimation.stop();
                        listMenu.currentIndex= -1
                    }
                    onEntered: {
                        listMenu.currentIndex = index
                        coloresRect.x = mouseX;
                        coloresRect.y = mouseY;
                        circleAnimation.start()
                    }

                    onClicked: {
                        circleAnimation.stop();
                        switch(index) {
                        case 4:
                            settingDrawer.close()
                            break
                        }
                    }
                }

                PropertyAnimation {
                    duration: 500
                    target: coloresRect;
                    id: circleAnimation;
                    properties: "width,height,radius"
                    from: 0
                    to: body.width*3

                    onStopped: {
                    coloresRect.width =0
                    coloresRect.height=0
                    }
                }

                color: element.ListView.isCurrentItem && !circleAnimation.running? "#d8d8d8": (index == 0? (loader.isOnline? "#FF455869": "#999999"): "#EEEDEEF0")

                Rectangle {
                    visible: index!=1 && index!=4
                    anchors.top: navigate.bottom;
                    width: parent.width
                    color: "#6198D9"
                    height: 1
                    }
                }
            }

            boundsBehavior:Flickable.StopAtBounds

            Component.onCompleted:currentIndex=-1

            model:ListModel {
                ListElement {
                    image1:"../ui/icons/imProfileBlue.png"
                    image2:"../ui/icons/imProfileLigh.png"
                    target:qsTr("Мой Профиль")
                }
                ListElement {
                    image1:"../ui/icons/mynotifyBlue.png";
                    image2:"../ui/icons/mynotifyLigh.png";
                    target:qsTr("Уведомления")
                }
                ListElement {
                    image1:"../ui/icons/myalgortBlue.png";
                    image2:"../ui/icons/myalgortLigh.png";
                    target:qsTr("Безопасность")
                }
                ListElement {
                    image1: "../ui/icons/manswerBlue.png";
                    image2: "../ui/icons/manswerLigh.png";
                    target:qsTr("Помощь")
                }
                ListElement {
                    image1: "qrc:/ui/icons/goBackBlue.png"
                    image2: "qrc:/ui/icons/goBackLigh.png"
                    target: qsTr("Назад")
                }
            }
        }
    }
}
