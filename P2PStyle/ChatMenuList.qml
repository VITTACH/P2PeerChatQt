import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Button {
    id: contextDialogs
    anchors.fill: parent
    visible: loader.context

    background: Rectangle {
        color:"transparent"
    }

    property int action
    property int menu: 1;
    property var buttons: [["Удалить", "Переслать", "Копировать"], ["Информация", "Отключить звук", "Отключить push", "Очистить историю"]]
    property int xPosition;
    property int yPosition;

    DropShadow {
        radius: 12
        samples: 16
        anchors {
            fill: listText;
        }
        color: "#C0000000";
        source: {listText;}
    }

    Rectangle {
        id: listText;
        x: xPosition;
        y: yPosition;
        radius: 8
        color: loader.feedColor
        width: Math.max(funcs.width, facade.toPx(400))
        height: funcs.implicitHeight + facade.toPx(20)

        Column {
            id: funcs
            anchors {
                top: parent.top
                topMargin: facade.toPx(10)
                verticalCenter: parent.verticalCenter;
            }

            Repeater {
                model:buttons[menu]
                Rectangle {
                    id: line
                    radius:listText.radius
                    width: listText.width;
                    color: {loader.feedColor}
                    height:inerText.implicitHeight+facade.toPx(60)
                    Text {
                        anchors {
                            left: parent.left
                            leftMargin:facade.toPx(20)
                            verticalCenter: {
                                parent.verticalCenter;
                            }
                        }

                        id: inerText
                        text: modelData
                        font {
                            pixelSize: facade.doPx(26)
                            family:trebu4etMsNorm.name
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onExited: {line.color = loader.feedColor}
                        onEntered: {
                            line.color = ("#20000000")
                        }
                        onClicked: {
                            var i, base = 1;
                            for (i = 0; i < menu; i++)
                            base+=buttons[menu].length
                            action = base + index
                        }
                    }
                }
            }
        }
    }
    property int w: listText.width;

    contentItem: Text {opacity: 0;}

    onClicked: loader.context=false
}
