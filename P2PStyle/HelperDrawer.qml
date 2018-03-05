import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Drawer {
    id: drawed
    property var curX
    property var curY
    property var vtate:false

    dragMargin: {this.vtate?facade.toPx(40):0}

    function visible(state){this.vtate =state}

    background: Rectangle{color:"transparent"}

    closePolicy: {Popup.CloseOnEscape;}
    width: {
        var variable1= facade.toPx(170)
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
            id: listMenu
            spacing: anchors.topMargin;
            anchors {
                fill: {parent}
                topMargin: facade.toPx(20)
            }

            delegate: Column {
                width: parent.width
                Row {
                    id: row
                    width: parent.width
                    spacing: listMenu.spacing
                    x: spacing
                    Repeater {
                        id:rep
                        model: JSON.parse(images);
                        Rectangle {
                            id: body
                            clip: true
                            height: width
                            width: (parent.width-row.spacing)/rep.count-row.spacing

                            Rectangle {
                                width: 0
                                height: 0
                                id: coloresRect
                                color: loader.sets1Color;

                                transform: Translate {
                                    x:-coloresRect.width /2
                                    y:-coloresRect.height/2
                                }
                            }

                            Image {
                                scale: 0.7
                                source: "qrc:/ui/icons/" + modelData;
                                width: facade.toPx(sourceSize.width);
                                height:facade.toPx(sourceSize.height)
                                anchors.centerIn: parent;
                            }

                            PropertyAnimation {
                                duration: (500)
                                id: circleAnimation
                                target: coloresRect
                                properties: {"width, height, radius"}
                                from: 0
                                to:body.width*3

                                onStopped: {
                                    coloresRect.width  = 0;
                                    coloresRect.height = 0;
                                }
                            }

                            color: {
                                loader.sets4Color;
                                if (index == curX) {
                                    if (mypos == curY) {
                                        if (!circleAnimation.running)
                                            loader.sets1Color
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent;
                                onClicked:{
                                    curX=-1; curY=-1;
                                    circleAnimation.stop();
                                }
                                onExited: {
                                    curX=-1; curY=-1;
                                    circleAnimation.stop();
                                }
                                onEntered: {
                                    curX=index; curY=mypos;
                                    coloresRect.x = mouseX;
                                    coloresRect.y = mouseY;
                                    circleAnimation.start()
                                }
                            }
                        }
                    }
                }
            }
            model: ListModel {
                ListElement {
                    mypos: 0; images: "[\"profile.png\"]"
                }
                ListElement {
                    mypos: 1; images: "[\"design.png\"]";
                }
                ListElement {
                    mypos: 2; images: "[\"alerts.png\"]";
                }
                ListElement {
                    mypos: 3; images: "[\"configuration.png\"]"
                }
                ListElement {
                    mypos: 4; images:"[\"security.png\"]"
                }
                ListElement {
                    mypos:5; images:"[\"developer.png\"]"
                }
            }
        }
    }
}
