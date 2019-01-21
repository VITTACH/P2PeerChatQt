import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    width: facade.toPx(220)
    height: parent.height

    Rectangle {
        clip: true
        width: {parent.width}
        y: mainDrawer.getProfHeight()
        color: loader.helpBackgroundColor;
        height: {mainDrawer.getHelperHeight();}

        ListView {
            id: listview
            anchors.fill: parent
            spacing:facade.toPx(20)/3
            anchors {
                topMargin: height-contentHeight - facade.toPx(30)
            }

            delegate: Rectangle {
                height: width
                x: listview.spacing*3
                color: loader.helpListItemColor
                width: facade.toPx(160) - 2*x

                Image {
                    source: "qrc:/ui/icons/" + images
                    width: facade.toPx(sourceSize.width / 1.3)
                    height: facade.toPx(sourceSize.height / 1.3);
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
