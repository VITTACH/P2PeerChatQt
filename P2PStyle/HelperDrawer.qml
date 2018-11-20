import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    height:parent.height
    width: 5*parent.width/7

    Rectangle {
        width: parent.width
        color: loader.sets2Color
        y: mainDrawer.getProfHeight()
        height: mainDrawer.getHelperHeight()

        ListView {
            id: listview
            spacing: facade.toPx(40);
            anchors {
                fill: parent
                topMargin: facade.toPx(25)
                bottomMargin:facade.toPx(20)
            }

            delegate: Row {
                x: facade.toPx(30)
                spacing: facade.toPx(30)

                Image {
                    source: "qrc:/ui/icons/"+images;
                    width: facade.toPx(sourceSize.width/1.40)
                    height:facade.toPx(sourceSize.height/1.4)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    color: loader.feed4Color
                    font.pixelSize: facade.doPx(25);
                    font.family: trebu4etMsNorm.name
                    anchors.verticalCenter: parent.verticalCenter
                    text: target

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            switch(mypos) {
                            case 5:
                                event_handler.saveSettings("user", "")
                                event_handler.saveSettings("frnd", "")
                                loader.restores();
                                drawes.close()
                                break
                            }
                        }
                    }
                }
            }

            model:ListModel {
                ListElement {
                    mypos: 0;
                    images: "profile.png";
                    target: qsTr("Профиль");
                }
                ListElement {
                    mypos: 1;
                    images: "configuration.png";
                    target: qsTr("Плагины")
                }
                ListElement {
                    mypos: 2;
                    images: "design.png"
                    target: qsTr("Внешний вид");
                }
                ListElement {
                    mypos: 3;
                    images: "security.png"
                    target: qsTr("Шифрование")
                }
                ListElement {
                    mypos: 4;
                    images: "alerts.png"
                    target: qsTr("Поддержка");
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
