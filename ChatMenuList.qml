import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Button {
    anchors.fill: parent;
    visible: loader.context
    contentItem: Text {opacity: 0;}
    onClicked: loader.context=false
    background: Rectangle {color: "#12000000";}
    property int w: listText.width;
    property int payload;
    property int menu: 1;
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
        clip: true
        color: loader.feed1Color
        width: {Math.max(funcs.width, facade.toPx(400))}
        height:funcs.implicitHeight;
        y: (yPosition)
        x: (xPosition)
        radius: 8
        Column {
            id: funcs;
            Repeater {
                anchors {
                    top: parent.top;
                    topMargin: facade.toPx(10)
                    verticalCenter:parent.verticalCenter
                }
                model: buttons[menu]
                Rectangle {
                    width: listText.width
                    height: inerText.implicitHeight + facade.toPx(60)
                    color: listText.color
                    Text {
                        id: inerText
                        text: {modelData}
                        x:facade.toPx(20)
                        anchors.verticalCenter: parent.verticalCenter
                        font {
                            pixelSize: {facade.doPx(26)}
                            family: trebu4etMsNorm.name;
                        }
                    }
                    MouseArea {
                        anchors.fill: {parent}
                        onExited: parent.color = loader.feed1Color
                        onEntered: {parent.color = loader.menu4Color}
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
