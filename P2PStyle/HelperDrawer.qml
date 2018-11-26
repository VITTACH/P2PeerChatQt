import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    height: parent.height
    width: 5*parent.width/7

    Rectangle {
        color: loader.sets2Color
        y: mainDrawer.getProfHeight()

        width: parent.width
        height: mainDrawer.getHelperHeight()

        ListView {
            id: listview
            anchors.fill: parent
            anchors {
                topMargin:parent.height-contentHeight-facade.toPx(30)
            }

            clip: true
            spacing: facade.toPx(60)

            delegate: Item {
                width: parent.width
                height: content.height

                Row {
                    Image {
                        source: "qrc:/ui/icons/"+images;
                        width: facade.toPx(sourceSize.width/1.4)
                        height: facade.toPx(sourceSize.height/1.4)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        color: loader.feed4Color
                        font.pixelSize: facade.doPx(25);
                        font.family: trebu4etMsNorm.name
                        anchors.verticalCenter: parent.verticalCenter
                        text: target
                    }

                    id: content
                    x: facade.toPx(30)
                    spacing: facade.toPx(30)
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        switch(mypos) {
                        case 5:
                            drawes.close()
                            event_handler.saveSettings("user", "")
                            event_handler.saveSettings("friends", "")
                            loader.restores()
                            break
                        }
                    }
                }
            }

            model:ListModel {
                ListElement {
                    mypos: 0;
                    images: "profile.png";
                    target: qsTr("Профиль")
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
