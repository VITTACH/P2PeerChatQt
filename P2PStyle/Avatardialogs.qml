import QtQuick 2.7
import QtQuick.Dialogs 1.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Button {
    id: avatardialogs
    anchors.fill: parent
    visible: loader.avatar;
    background: Rectangle {
        color: "#CC404040";
    }

    onClicked:loader.avatar=false;

    contentItem: Text {opacity: 0}

    text: "Установите свою фотографию на аватар"

    Rectangle {
        color: "#f7f7f7"
        radius: facade.toPx(25)
        anchors.centerIn:parent
        height:avatardialogs.height/2.5
        width: Math.min(2.2 * avatardialogs.width/3, 400)

        //Область для сообщения для диалогового;
        Rectangle {
            color: "#f7f7f7"
            radius:facade.toPx(25)
            width: parent.width-facade.toPx(80);
            anchors {
                top: parent.top
                bottom: picDialogAndroidrow.top;
                horizontalCenter: parent.horizontalCenter
            }

            Label {
                color: "#000000"
                wrapMode:Text.Wrap
                width: parent.width;
                anchors.centerIn:parent
                text:avatardialogs.text
                horizontalAlignment: {Text.AlignHCenter;}
                font {
                    pixelSize: {facade.doPx(22)}
                    family: trebu4etMsNorm.name;
                }
            }
        }

        Rectangle {
            width: parent.width
            height:picDialogAndroidButtonGallery.height/2
            anchors.top:picDialogAndroidrow.top;
            anchors.topMargin:facade.toPx(102.4)
            color: picDialogAndroidButtonGallery.pressed==true? "#d7d7d7": "#f7f7f7";
        }

        Column {
            height:facade.toPx(202)
            id: picDialogAndroidrow
            anchors{
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            Rectangle {
                height: 1.2
                color: "#808080"
                width: parent.width
                id: picDialogDividerHorizontal1;
            }

            Button {
                width: parent.width
                height: facade.toPx(100)
                id: picDialogAndroidButtonCamera

                onClicked: {
                    loader.avatar=false;
                    imagePicker.item.takePhoto()
                }

                contentItem: Text {
                    color: "#34aadc"
                    text: {"Сделать фотографию"}
                    verticalAlignment: Text.AlignVCenter;
                    horizontalAlignment:
                    {Text.AlignHCenter;}
                    font {
                      bold: true
                      pixelSize: facade.doPx(24)
                      family:trebu4etMsNorm.name
                    }
                }

                background: Rectangle {
                    color: picDialogAndroidButtonCamera.pressed? "#d7d7d7": "#f7f7f7"
                }
            }

            Rectangle {
                height: 1.2
                color: "#808080"
                width: parent.width
                id: picDialogDividerHorizontal2;
            }

            Button {
                width: parent.width
                height: facade.toPx(100)
                id:picDialogAndroidButtonGallery

                contentItem: Text {
                    color:"#34aadc"
                    text: "Загрузить из галереи"
                    verticalAlignment: Text.AlignVCenter;
                    horizontalAlignment:
                    {Text.AlignHCenter;}
                    font {
                    bold: true
                    pixelSize:{facade.doPx(24)}
                    family: trebu4etMsNorm.name
                    }
                }

                background: Rectangle {
                    radius:facade.toPx(25)
                    color: picDialogAndroidButtonGallery.pressed? "#d7d7d7":"#f7f7f7"
                }

                onClicked: {
                    loader.avatar = false;
                    event_handler.currentOSys() === 0? fileDialog.open(): imagePicker.item.pickImage();
                }
            }
        }

        RadialGradient {
            opacity: 0.2
            anchors.fill: parent
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color:"white"
                }
                GradientStop {
                    position: 0.8
                    color:"black"
                }
            }
        }
    }

    Loader {
        id: imagePicker
        source: "qrc:/" + event_handler.currentOSys() == 1? "AndImagePicker.qml": "IOsImagesPicker.qml"

        onLoaded: {
            item.onChange=function(url)
            {
                loader.avatarPath = url
                event_handler.sendAvatar(decodeURIComponent(url))
            }
        }
    }

    FileDialog {
        id:fileDialog
        folder: shortcuts.home
        title: "Выберите изображение"
        nameFilters:["Изображения (*.jpg,*.png)","Все файлы (*)"]
        onAccepted: {
            loader.avatarPath = fileUrl
            event_handler.sendAvatar(decodeURIComponent(fileUrl))
        }
    }
}
