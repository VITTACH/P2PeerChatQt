import QtQuick 2.7
import QtQuick.Dialogs 1.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Button {
    anchors.fill: parent
    visible: loader.avatar
    onClicked: loader.avatar = false;

    background: Rectangle {color : "#90000000";}

    Connections {
        target: loader;
        onAvatarChanged: {loader.focus = !false}
    }

    contentItem: Text {opacity: (0);}
    text: "Установите свою фотографию на аватар"

    FileDialog {
        id: fileDialog;
        folder: shortcuts.home
        title: "Выберите изображение"
        nameFilters:["Изображения (*.jpg *.png)","Все файлы (*)"]
        onAccepted: {
            loader.avatarPath=fileUrl
            event_handler.sendAvatar(decodeURIComponent(fileUrl))
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height/6
        anchors.horizontalCenter:parent.horizontalCenter
        width: Math.min(0.73 * parent.width, facade.toPx(666.6));
        height: {2*width/3;}
        color: "#F2F2F2"

        MouseArea {anchors.fill: parent}

        Rectangle {
            anchors {
                top: parent.top
                bottom: actions.top;
                horizontalCenter:parent.horizontalCenter
                margins: facade.toPx(40)
            }
            width: parent.width-facade.toPx(60)

            Label {
                wrapMode: Text.Wrap;
                width: {parent.width - facade.toPx(20);}
                horizontalAlignment: {Text.AlignHCenter}
                text: parent.parent.parent.text
                anchors.centerIn: parent
                font {
                    pixelSize: facade.doPx(22);
                    family: trebu4etMsNorm.name
                }
            }
        }

        Column {
            id: actions
            width: parent.width
            anchors.bottom: parent.bottom

            Repeater {
                id: buttons
                model: ["Сделать новый снимок","Подгрузить из галереи"]
                Item {
                    width: parent.width
                    height: facade.toPx(100)

                    Button {
                        anchors.right: parent.right
                        anchors.rightMargin: facade.toPx(30)
                        anchors.verticalCenter: parent.verticalCenter

                        background: Rectangle {
                            color: parent.pressed? "#919191": "#C2C2C2"
                            border.width: parent.pressed?2:0
                            border.color: "#575757"
                        }

                        contentItem: Text {
                            text: modelData;
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter

                            font {
                                pixelSize: {facade.doPx(20)}
                                family: trebu4etMsNorm.name;
                            }
                        }

                        onClicked: {
                            loader.avatar=false
                            if (index == 0) {
                                imagePicker.item.takePhoto()
                            } else {
                                if (event_handler.currentOSys() == 0) {
                                    fileDialog.open();
                                } else { imagePicker.item.pickImage() }
                            }

                        }
                    }

                    Rectangle {
                        color: "#808080"
                        anchors.top: parent.top;
                        width: parent.width
                        height: 1
                    }
                }
            }
        }
    }
}
