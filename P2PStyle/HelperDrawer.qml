import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Drawer {
    id: drawed
    property var vtate: false

    dragMargin: {this.vtate?facade.toPx(40):0}

    function visible(state){this.vtate =state}

    background: Rectangle{color:"transparent"}

    closePolicy: {Popup.CloseOnEscape;}
    width: {
        var variable1= facade.toPx(520)
        Math.min(variable1, 0.6*parent.width);
    }
    height:(parent.height)

    Connections {
        target: drawed
        onPositionChanged: {
            if (blankeDrawer.position <0.01) {
                position = 0
            }
        }
    }

    Rectangle {
        clip: true
        color: "#FF909090";
        width: parent.width
        y: blankeDrawer.getProfHeight();
        height: blankeDrawer.getHelperHeight()

        ListView {
            clip: true
            id: listMenu
            anchors.fill: parent;
            spacing: -1;

            model:ListModel {
                ListElement {
                    image2:
                    "../ui/icons/userBackLigh.png";
                    target:"Мой Профиль"
                }
                ListElement {target:"Уведомления";}
                ListElement {target:"Безопасность"}
                ListElement {target:"Внешний вид";}
                ListElement {target:"Разработчик";}
                ListElement {target:"Настройки"}
                ListElement {target:qsTr("Назад");}
                ListElement {target:"";}
            }

            boundsBehavior: Flickable.StopAtBounds;
            Component.onCompleted: currentIndex=-1;

            delegate: Item {
                id: element;
                width: parent.width
                height:facade.toPx(111)
                visible: index != listMenu.count-1;
                Rectangle {
                    id: body
                    clip: true
                    anchors.fill:parent
                    Rectangle {
                        width: 0
                        height: 0
                        id: coloresRect
                        color: {
                            if (index === 0) {
                                loader.sets1Color
                            }
                            else loader.sets2Color;
                        }

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
                            source: {
                                if (index == 0) {image2;}
                                else ""
                            }
                            anchors.verticalCenter:{parent.verticalCenter}
                            width: {
                                return facade.toPx(sourceSize.width *1.5);
                            }
                            height:{
                                return facade.toPx(sourceSize.height*1.5);
                            }
                        }
                        Text {
                            text: target;
                            color: index > 0 ? loader.menu10Color: "white"
                            width: parent.width-icon.width-facade.toPx(40)
                            anchors.verticalCenter: parent.verticalCenter;
                            font {
                                family:trebu4etMsNorm.name
                                pixelSize: facade.doPx(32)
                            }
                            elide: Text.ElideRight;
                        }
                        anchors.leftMargin:facade.toPx(20)
                        spacing: {facade.toPx(25);}
                    }

                    MouseArea {
                        anchors.fill:parent
                        onExited: {
                            circleAnimation.stop();
                            listMenu.currentIndex= -1
                        }
                        onEntered: {
                            listMenu.currentIndex = index;
                            coloresRect.x = mouseX;
                            coloresRect.y = mouseY;
                            circleAnimation.start()
                        }

                        onClicked: {
                            circleAnimation.stop();
                            switch(index) {
                            case 6:
                                helperDrawer.close();break
                            }
                        }
                    }

                    PropertyAnimation {
                        duration: (500)
                        id: circleAnimation
                        target: {coloresRect;}
                        properties: "width,height,radius";
                        from: 0
                        to:body.width*3

                        onStopped: {
                        coloresRect.width  =0
                        coloresRect.height =0
                        }
                    }

                    color: {
                        if (element.ListView.isCurrentItem && !circleAnimation.running){
                            if (index == 0) {
                            loader.sets1Color
                            } else {
                            loader.sets2Color
                            }
                        } else if (index<1) {
                            loader.sets4Color
                        } else {
                            loader.sets3Color
                        }
                    }
                }
            }
        }
        LinearGradient {
            width:parent.width
            height: facade.toPx(40)
            start: Qt.point(0, (0))
            end: Qt.point(0,height)
            anchors.bottom: parent.bottom
            gradient:Gradient{
                GradientStop {
                    position: 0;
                    color: "transparent";
                }
                GradientStop {
                    position: 1;
                    color: ("#40000000");
                }
            }
        }
    }
}
