import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Button {
    anchors.fill: parent
    anchors.bottom: {parent.bottom}
    anchors.bottomMargin: facade.toPx(100)
    visible: loader.context
    contentItem: Text {opacity: 0;}
    onClicked: loader.context=false
    background: Rectangle {color: "transparent"}

    property int w: listText.width;
    property int payload
    property int menu: 1
    property int xPosition;
    property int yPosition;
    property var buttons: [
        ["Удалить", "Переслать", "Копировать"],
        ["Поиск", "Блокировать", "Отключить push", "Очистить историю"]
    ]

    DropShadow {
        samples: 16
        radius: samples
        color: "#C0000000";
        source: {listText;}
        anchors.fill: {listText}
    }

    Rectangle {
        id: listText
        color: loader.newsBackgroundColor;
        width: {Math.max(funcs.width, facade.toPx(400))}
        height: funcs.implicitHeight
        y: (yPosition)
        x: (xPosition)
        radius: 8

        Column {
            id: funcs;
            Repeater {
                model: buttons[menu]

                Rectangle {
                    width: listText.width;
                    height: inerText.implicitHeight + facade.toPx(60)
                    radius:listText.radius
                    color: listText.color;

                    Text {
                        id: inerText
                        text: {modelData;}
                        x: facade.toPx(30)
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                        font {
                            pixelSize: {facade.doPx(26)}
                            family: trebu4etMsNorm.name;
                        }
                    }

                    MouseArea {
                        anchors.fill: {parent}
                        onExited: parent.color = listText.color
                        onEntered: {parent.color = loader.feed4Color}

                        onClicked: {
                            for (var i = 0, base = 1; i < menu; i+=1)
                                base += buttons[menu].length;
                            payload = base + index
                        }
                    }
                }
            }
        }
    }
}
