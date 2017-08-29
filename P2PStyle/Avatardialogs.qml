import QtQuick 2.7
import QtQuick.Dialogs  1.0
import QtQuick.Controls  2.0
import QtGraphicalEffects 1.0

Button {
    id: avatardialog
    visible: loader.avatar
    anchors.fill: {parent}
    background: Rectangle {color : "#AC404040";}

    onClicked: loader.avatar=false

    contentItem:Text {opacity: 0;}
    Connections {
        target: loader;
        onAvatarChanged: {loader.focus = !false}
    }

    text: "Установите свою фотографию на аватар"

    FileDialog {
        id:fileDialog
        folder: shortcuts.home
        title: "Выберите изображение"
        nameFilters:["Изображения (*.jpg *.png)","Все файлы (*)"]
        onAccepted: {
            loader.avatarPath=fileUrl
            event_handler.sendAvatar(decodeURIComponent(fileUrl))
        }
    }

    DropShadow {
        radius: 16
        samples: 20
        color: "#C0000000";
        source:dialogWindow
        anchors.fill:dialogWindow;
    }
    Rectangle {
        id:dialogWindow;
        radius: {facade.toPx(25);}
        anchors.centerIn: {parent}
        color: "#f7f7f7"
        height: {width;}
        width: Math.min(0.73 * parent.width, facade.toPx(666.6));

        //Область для сообщения для диалогового;
        Rectangle {
            color: "#f7f7f7"
            radius:facade.toPx(25)

            anchors {
                top: parent.top;
                bottom: picDialogAndroidrow.top;
                horizontalCenter: parent.horizontalCenter
            }

            width: (parent.width - 2*dialogWindow.radius)

            Label {
                color: "#000000"
                wrapMode:Text.Wrap
                width:parent.width
                horizontalAlignment: {Text.AlignHCenter;}
                text: avatardialog.text
                anchors.centerIn:parent
                font.pixelSize: facade.doPx(27);
                font.family: trebu4etMsNorm.name
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
            height:facade.toPx(202);
            id: picDialogAndroidrow;
            anchors{
                left: (parent.left);
                right: parent.right;
                bottom:parent.bottom
            }

            Rectangle {
                height: 1.2
                color: "#808080"
                width: parent.width;
                id: picDialogDividerHorizontal1;
            }

            Button {
                width: parent.width;
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
                      pixelSize: facade.doPx(27)
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
                    pixelSize: {facade.doPx(27)}
                    family: trebu4etMsNorm.name;
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
            anchors {
                fill: parent
                topMargin: dialogWindow.radius;
                leftMargin: dialogWindow.radius;
                rightMargin:dialogWindow.radius;
                bottomMargin:dialogWindow.radius
            }
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color:"white"
                }
                GradientStop {
                    position: 0.8
                    color: "gray"
                }
            }
        }
    }
}
