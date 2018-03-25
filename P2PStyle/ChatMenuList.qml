import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Button {
    id: contextDialogs
    anchors.fill: parent;
    visible: loader.context
    contentItem: Text {opacity: 0;}

    onClicked: loader.context=false

    background: Rectangle {color: "#40000000";}

    property int w: listText.width;
    property int action
    property int menu: 1;
    property var buttons: [
        ["Удалить", "Переслать", "Копировать"],
        ["Найти", "Профиль", "Отключить push", "Очистить историю"]
    ]
    property int xPosition;
    property int yPosition;

    DropShadow {
        samples: 16
        radius: samples
        color: "#C0000000";
        source: {listText;}
        anchors.fill: listText;
    }
    Rectangle {
        id:listText
        x: (xPosition)
        y: (yPosition)
        radius: 8
        height:funcs.implicitHeight;
        color: loader.feedColor
        width: Math.max(funcs.width, facade.toPx((400)))
        Column {
            id: funcs
            Repeater {
                anchors {
                    top: parent.top;
                    topMargin: facade.toPx(10)
                    verticalCenter:parent.verticalCenter
                }
                model: buttons[menu]
                Rectangle {
                    id: line
                    width: listText.width
                    height:inerText.implicitHeight+facade.toPx(60)
                    color: {loader.feedColor}
                    radius: {listText.radius}

                    Text {
                        id: inerText
                        text: {modelData}
                        anchors {
                            left: parent.left
                            leftMargin: facade.toPx(20);
                            verticalCenter: parent.verticalCenter;
                        }
                        font {
                            pixelSize: {facade.doPx(26)}
                            family: trebu4etMsNorm.name;
                        }
                    }

                    MouseArea {
                        anchors.fill: parent;
                        onExited: line.color=loader.feedColor
                        onEntered: line.color = ("#20000000")
                        onClicked: {
                            var i, base = (1)
                            for (i = 0; i < menu; i+= 1)
                                base += buttons[menu].length;
                            action = base + index
                        }
                    }
                }
            }
        }
    }
}
