import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Drawer {
    id: drawed
    property var vtate: false

    dragMargin: {this.vtate? facade.toPx(40):0}

    function visible(state) {this.vtate =state}

    background: Rectangle {color:"transparent"}

    Connections {
        target: drawed
        onPositionChanged: {
            if(basicMenuDrawer.position<=0.1) {
                position = 0
            }
        }
    }

    closePolicy: Popup.CloseOnEscape;

    height:{(parent.height)}
    width: {Math.min(facade.toPx(520), 0.60*parent.width)}

    Rectangle {
        width: parent.width;
        y: basicMenuDrawer.getProfHeight()
        height: {
            parent.height-basicMenuDrawer.getProfHeight();
        }
        color: "#DEDEE0"

        ListView {
            clip: true
            id: listMenu
            anchors.fill: parent
            spacing: facade.toPx(10)
            delegate: Item {
                id: element;
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
                        color: loader.sets2Color

                        transform: Translate {
                            x:-coloresRect.width /2
                            y:-coloresRect.height/2
                        }
                    }
                    Row {
                        id: navigate
                        anchors.fill:parent
                        Image {
                            id: icon
                            source:{
                               if(index>0||element.ListView.isCurrentItem)
                                    image1;
                               else image2;
                            }
                            anchors.verticalCenter: parent.verticalCenter;
                            width: ((facade.toPx(sourceSize.width *1.5)));
                            height:((facade.toPx(sourceSize.height*1.5)));
                        }
                        Text {
                            text: target;
                            color: {
                               if(index>0||element.ListView.isCurrentItem)
                                    loader.menu16Color; else "#FFFFFFFF"
                            }
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
                            case 5:
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

                    color: {
                        if (element.ListView.isCurrentItem&&!circleAnimation.running)
                            loader.sets2Color
                        else
                            if(index==0)loader.menu17Color
                        else "#EEEDEEF0"
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
                    target: qsTr("Безопасность")
                }
                ListElement {
                    image1: "../ui/icons/myalgortBlue.png"
                    image2: "../ui/icons/myalgortLigh.png"
                    target: qsTr("Настройки")
                }
                ListElement {
                    image1: "../ui/icons/manswerBlue.png";
                    image2: "../ui/icons/manswerLigh.png";
                    target: qsTr("Помощь")
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
