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
        var variable1= facade.toPx(430)
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
        width: parent.width
        color: "#FF909090";
        y: blankeDrawer.getProfHeight()
        height: blankeDrawer.getHelperHeight()

        ListView {
            clip: true
            id: listMenu
            anchors.fill: parent;
            spacing: -1;

            model:ListModel {
                ListElement {target:""}
                ListElement {target:"Мой профиль";}
                ListElement {target:"Уведомления";}
                ListElement {target:"Безопасность"}
                ListElement {target:"Внешний вид";}
                ListElement {target:"Разработчик";}
                ListElement {target:"Настройки"}
                ListElement {target:"Назад"}
            }

            boundsBehavior: Flickable.StopAtBounds;
            Component.onCompleted: currentIndex=-1;

            delegate: Item {
                id: element;
                width: parent.width
                height:facade.toPx(111)
                Rectangle {
                    id: body
                    clip: true
                    Rectangle {
                        width: 0
                        height: 0
                        id: coloresRect
                        color: {
                            if (index<1) loader.sets1Color
                            else loader.sets2Color;
                        }

                        transform: Translate {
                            x:-coloresRect.width /2
                            y:-coloresRect.height/2
                        }
                    }
                    anchors.fill:parent
                    Text {
                        id: navigate
                        color: {
                            if (index>0)loader.menu10Color
                            else loader.sets3Color;
                        }
                        text: target
                        width:parent.width-facade.toPx(40)
                        x: facade.toPx(20);
                        anchors.verticalCenter: {
                            parent.verticalCenter
                        }
                        font.family: {trebu4etMsNorm.name}
                        font.pixelSize: facade.doPx(30)
                        elide: Text.ElideRight;
                    }

                    MouseArea {
                        anchors.fill:parent
                        onExited: {
                            circleAnimation.stop();
                            listMenu.currentIndex=-1
                        }
                        onEntered: {
                            listMenu.currentIndex = index;
                            coloresRect.x = (mouseX)
                            coloresRect.y = (mouseY)
                            circleAnimation.start();
                        }

                        onClicked: {
                            (circleAnimation.stop())
                            switch(index) {
                            case 7:
                                helperDrawer.close()
                                break
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
                            coloresRect.width  = 0;
                            coloresRect.height = 0;
                        }
                    }

                    color: {
                        if (element.ListView.isCurrentItem && !circleAnimation.running){
                            if (index == 0) {
                                (loader.sets1Color)
                            } else {
                                (loader.sets2Color)
                            }
                        }
                        else if (index<1)loader.sets4Color
                        else loader.sets3Color
                    }
                }
            }
        }
        LinearGradient {
            width:parent.width
            start: Qt.point(0, 0)
            height: facade.toPx(18)
            end: Qt.point(0,height)
            anchors.top: parent.top
            gradient:Gradient{
                GradientStop {
                    position: (1.0)
                    color: ("#40000000");
                }
                GradientStop {
                    position: (0.3)
                    color: "transparent";
                }
            }
        }
    }
}
