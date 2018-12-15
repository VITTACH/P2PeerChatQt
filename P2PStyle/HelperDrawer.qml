import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    width: facade.toPx(140)
    height: parent.height

    Rectangle {
        clip: true
        color: loader.sets2Color
        y: mainDrawer.getProfHeight();

        width: parent.width
        height: mainDrawer.getHelperHeight()

        ListView {
            id: listview
            anchors.fill: parent
            spacing:facade.toPx(20)/3
            anchors {
                topMargin: parent.height - contentHeight - facade.toPx(30)
            }

            delegate: Rectangle {
                x: listview.spacing*3
                height: width
                width: parent.width -2*x
                border.color: loader.sets1Color
                border.width: facade.toPx(5)
                color: mypos%2 == 0? loader.sets3Color : loader.sets4Color

                Image {
                    source: "qrc:/ui/icons/" + images
                    width: facade.toPx(sourceSize.width/1.4)
                    height: facade.toPx(sourceSize.height/1.4)
                    anchors.centerIn: (parent);
                }

                MouseArea {
                    anchors.fill: parent
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
