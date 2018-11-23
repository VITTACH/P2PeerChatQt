import QtQuick 2.7
import QtQuick.Dialogs 1.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Button {
    anchors.fill: parent
    visible: loader.avatar
    onClicked: loader.avatar = false;

    property string color1: "#F7F7F7"
    property string color2: "#000000"
    property string color3: "#D7D7D7"
    property string color4: "#808080"
    property string color5: "#34AADC"

    background: Rectangle {color : "#80727272";}

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
        id: dialogWindow
        radius: facade.toPx(25)
        anchors.bottom: parent.bottom
        anchors.bottomMargin:parent.height/6
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(0.73 * parent.width, facade.toPx(666.6));
        height: {2*width/3;}
        color: color1

        Rectangle {
            color: loader.toastColor
            anchors {
                fill: parent
                margins: dialogWindow.radius
            }
        }

        MouseArea {anchors.fill: {(parent)}}

        Item {
            anchors {
                top: parent.top;
                bottom: picDialogAndroidrow.top;
                horizontalCenter: parent.horizontalCenter
            }

            width: (parent.width - 2*dialogWindow.radius)

            Label {
                color: color2
                wrapMode: Text.Wrap;
                width: parent.width - facade.toPx(20);
                horizontalAlignment: {Text.AlignHCenter;}
                text: parent.parent.parent.text;
                anchors.centerIn:parent
                font {
                    pixelSize: (facade.doPx(27))
                    family: trebu4etMsNorm.name;
                }
            }
        }

        Rectangle {
            width: parent.width
            height:picDialogAndroidButtonGallery.height/2
            anchors.top: picDialogAndroidrow.top
            anchors.topMargin:facade.toPx(102.4)
            color: picDialogAndroidButtonGallery.pressed==true? color3: color1;
        }

        Column {
            id: picDialogAndroidrow
            anchors.bottom: parent.bottom
            width: parent.width
            height: facade.toPx(202)

            Rectangle {
                height: 1
                color: color4
                width: parent.width;
            }

            Button {
                width: parent.width;
                height: facade.toPx(100)
                id: picDialogAndroidButtonCamera

                contentItem: Text {
                    color: color5
                    text: qsTr("Сделать новый снимок")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font {
                        bold: true
                        pixelSize: facade.doPx(27);
                        family: trebu4etMsNorm.name
                    }
                }

                background: Rectangle {
                    color: picDialogAndroidButtonCamera.pressed? color3: color1
                }

                onClicked: {
                    loader.avatar = false
                    imagePicker.item.takePhoto();
                }
            }

            Rectangle {
                height: 1
                color: color4
                width: parent.width
            }

            Button {
                width: parent.width
                height: facade.toPx(100)
                id: picDialogAndroidButtonGallery

                contentItem: Text {
                    color: color5
                    text: qsTr("Подгрузить из галереи")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font {
                        bold: true
                        pixelSize: facade.doPx(27);
                        family: trebu4etMsNorm.name
                    }
                }

                background: Rectangle {
                    radius:facade.toPx(25)
                    color: picDialogAndroidButtonGallery.pressed?color3: color1
                }

                onClicked: {
                    loader.avatar = false;
                    if (event_handler.currentOSys()==0) {
                        fileDialog.open();
                    } else {imagePicker.item.pickImage()}
                }
            }
        }
    }
}
