import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    property double curX:-1
    property double curY:-1

    height: (parent.height)
    width: {
        var variable1= facade.toPx(170)
        Math.min(variable1, 0.6 * parent.width);
    }

    Rectangle {
        clip: true
        width: parent.width
        color: loader.sets2Color;
        y: blankeDrawer.getProfHeight();
        height: {blankeDrawer.getHelperHeight()}

        ListView {
            id: listview
            anchors {
                fill: parent;
                topMargin: facade.toPx(15)
                bottomMargin:facade.toPx(20)
            }
            delegate: Rectangle {
                height: width
                x: listview.spacing*3
                border.color: "#FFFFFF";
                width: parent.width -3 * x
                border.width: facade.toPx(6)

                color: {
                    if (mypos%2 == 0)
                        loader.sets3Color
                    else {loader.sets4Color}
                    if (index == curX) {
                        if (mypos == curY) {
                            if (!circleAnimation.running)
                                loader.sets1Color
                        }
                    }
                }

                Item {
                    clip: true
                    anchors.fill: parent
                    anchors.margins: parent.border.width;
                    Rectangle {
                        width: 0
                        height: 0
                        id: coloresRect
                        color: loader.sets1Color;

                        transform: Translate {
                            x: -(coloresRect.width /2.0);
                            y: -(coloresRect.height/2.0);
                        }
                    }
                }

                Image {
                    scale: 0.7
                    source: {"qrc:/ui/icons/" + (images)}
                    width: facade.toPx(sourceSize.width);
                    height:facade.toPx(sourceSize.height)
                    anchors.centerIn: (parent);
                }

                PropertyAnimation {
                    duration: (500)
                    id: circleAnimation
                    target: coloresRect
                    properties: {"width, height, radius"}
                    from: 0
                    to: parent.width*3;
                    onStopped: {
                        coloresRect.width  = 0;
                        coloresRect.height = 0;
                    }
                }

                MouseArea {
                    function resets() {
                        curX = -1; curY = -1;
                        circleAnimation.stop();
                    }
                    onEntered: {
                        curX = index;
                        curY = mypos;
                        coloresRect.x = mouseX;
                        coloresRect.y = mouseY;
                        circleAnimation.start()
                    }
                    anchors.fill: parent
                    onClicked: resets()
                    onExited: resets()
                }
            }
            spacing: anchors.bottomMargin/3
            model:ListModel {
                ListElement {
                    mypos: 0; images: "profile.png"
                }
                ListElement {
                    mypos: 1; images: "design.png";
                }
                ListElement {
                    mypos: 2; images: "alerts.png";
                }
                ListElement {
                    mypos: 3; images: "configuration.png"
                }
                ListElement {
                    mypos: 4; images:"security.png"
                }
                ListElement {
                    mypos:5; images:"developer.png"
                }
            }
        }
    }
}
