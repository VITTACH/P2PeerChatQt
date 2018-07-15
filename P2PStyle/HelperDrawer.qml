import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    height: parent.height
    width: 2*parent.width/3
    Rectangle {
        clip: true
        width: parent.width
        color: loader.sets2Color;
        y: blankeDrawer.getProfHeight();
        height: blankeDrawer.getHelperHeight()

        ListView {
            id: listview
            anchors {
                fill: parent;
                topMargin: facade.toPx(15)
                bottomMargin: facade.toPx(20);
            }
            delegate: Row {
                x: listview.spacing * 2
                Rectangle {
                    height: width
                    radius: {width / 8}
                    width: facade.toPx(140) - (2 * parent.x);

                    color: {loader.sets4Color}

                    Image {
                        scale: 0.7
                        source: {"qrc:/ui/icons/" + (images)}
                        width: facade.toPx(sourceSize.width);
                        height:facade.toPx(sourceSize.height)
                        anchors.centerIn: (parent);
                    }
                }
                spacing: facade.toPx(25)
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: loader.menu10Color;
                    font.pixelSize: facade.doPx(28)
                    font.family:trebu4etMsNorm.name
                    text: target
                }
            }
            spacing: anchors.bottomMargin/3
            model:ListModel {
                ListElement {
                    mypos: 0; images: "profile.png"
                    target: qsTr("Профиль")
                }
                ListElement {
                    mypos: 1; images: "design.png";
                    target: qsTr("Внешний вид")
                }
                ListElement {
                    mypos: 2; images: "alerts.png";
                    target: qsTr("Уведомления")
                }
                ListElement {
                    mypos: 3; images: "configuration.png"
                    target: qsTr("Конфигурации")
                }
                ListElement {
                    mypos: 4; images:"security.png"
                    target: qsTr("Безопасность")
                }
                ListElement {
                    mypos:5; images:"developer.png"
                    target: qsTr("Разработчики")
                }
            }
        }
    }
}
