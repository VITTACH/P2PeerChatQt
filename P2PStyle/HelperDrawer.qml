import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    height: parent.height
    width: 2 * parent.width/3.0;
    Rectangle {
        clip: true
        width: parent.width
        color: loader.sets2Color
        y: blankeDrawer.getProfHeight();
        height: blankeDrawer.getHelperHeight()

        ListView {
            id: listview
            anchors {
                fill: parent;
                topMargin: facade.toPx(25)
                bottomMargin: facade.toPx(20);
            }
            spacing: facade.toPx(35)
            delegate: Row {
                x: facade.toPx(30)
                spacing: facade.toPx(30)
                Image {
                    source: "qrc:/ui/icons/"+images
                    width: facade.toPx(sourceSize.width/1.3);
                    height:facade.toPx(sourceSize.height/1.3)
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    color: "#D6D6D6"
                    font.pixelSize: facade.doPx(28)
                    font.family:trebu4etMsNorm.name
                    anchors.verticalCenter: parent.verticalCenter
                    text: target
                }
            }
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
                    target: qsTr("Разработчик")
                }
            }
        }
    }
}
