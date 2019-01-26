import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    height: parent.height
    width: facade.toPx(200);

    property var itemHeight: facade.toPx(120)

    Rectangle {
        clip: true
        y: mainDrawer.getProfHeight();
        color: loader.helpBackgroundColor
        width: parent.width;
        height: mainDrawer.getHelperHeight();

        ListView {
            spacing: facade.toPx(20)/3
            anchors {
                fill: parent
                topMargin: Math.max(0, 3*(height - buttons.count * (itemHeight + spacing))/4)
            }

            delegate: Rectangle {
                x: facade.toPx(20)
                color: {loader.helpListItemColor}
                width: itemHeight
                height: itemHeight

                Image {
                    source: "/ui/icons/" + images
                    width: facade.toPx(sourceSize.width / 1.3)
                    height: facade.toPx(sourceSize.height/1.3)
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent;
                    onClicked: switch(mypos) {
                    case 5:
                        event_handler.saveSettings("user", "")
                        event_handler.saveSettings("friends", "")
                        drawes.close()
                        loader.restores()
                        break
                    }
                }
            }

            model:ListModel {
                id: buttons
                ListElement {
                    mypos: 0;
                    images: "profile.png";
                    target: qsTr("Мой профиль")
                }

                ListElement {
                    mypos: 1;
                    images: "configuration.png"
                    target: qsTr("Дополнения");
                }

                ListElement {
                    mypos: 2;
                    images: "design.png"
                    target: qsTr("Внешний вид")
                }

                ListElement {
                    mypos: 3;
                    images: "security.png"
                    target: qsTr("Шифрование");
                }

                ListElement {
                    mypos: 4;
                    images: "alerts.png"
                    target: qsTr("Уведомления")
                }

                ListElement {
                    mypos: 5;
                    images:"developer.png"
                    target: qsTr("Выйти")
                }
            }
        }
    }
}
