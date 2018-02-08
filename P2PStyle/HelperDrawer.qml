import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Drawer {
    id: drawed
    property var vtate:false

    dragMargin: {this.vtate?facade.toPx(40):0}

    function visible(state){this.vtate =state}

    background: Rectangle{color:"transparent"}

    closePolicy: {Popup.CloseOnEscape;}
    width: {
        var variable1= facade.toPx(430)
        Math.min(variable1, 0.6*parent.width);
    }
    height: (parent.height);

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
            spacing: (anchors.topMargin);

            anchors {
                fill: parent
                topMargin:facade.toPx(20)
            }

            model:ListModel {
                ListElement {
                    mypos: 0;
                    target: "[\"Мой профиль\",\"Безопасность\"]"
                }
                ListElement {
                    mypos: 1;
                    target: "[\"Внешний вид\",\"Конфигурация\"]"
                }
                ListElement {
                    mypos: 2;
                    target: "[\"Уведомления\", \"Разработчик\"]"
                }
            }

            delegate: Column {
                id: col
                width: parent.width
                Row {
                    id: row
                    width: parent.width
                    spacing: listMenu.spacing
                    x: spacing
                    Repeater {
                        id:rep
                        model: JSON.parse(target)
                        Rectangle {
                            id: body
                            clip: true
                            height: width

                            MouseArea {
                                onExited: {
                                    circleAnimation.stop();
                                    listMenu.currentIndex = 0 - 1;
                                }
                                anchors.fill: {parent}
                                onClicked: circleAnimation.stop();
                                onEntered: {
                                    coloresRect.x = mouseX;
                                    coloresRect.y = mouseY;
                                    circleAnimation.start()
                                    listMenu.currentIndex = mypos;
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

                            width: (parent.width - row.spacing) / rep.count - row.spacing

                            color: {
                                if (col.ListView.isCurrentItem&&!circleAnimation.running)
                                    (index == 0)?loader.sets1Color : (loader.sets2Color);
                                else if(index<1) loader.sets4Color
                                else loader.sets3Color
                            }

                            Rectangle {
                                width: 0
                                height: 0
                                id: coloresRect;
                                color: index==0? loader.sets1Color : (loader.sets2Color);

                                transform: Translate {
                                    x:-coloresRect.width /2
                                    y:-coloresRect.height/2
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
