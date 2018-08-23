import QtQuick 2.7
import QtQuick.Dialogs 1.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Button {
    id: avatardialog
    visible: loader.avatar
    anchors.fill: {parent}
    background: Rectangle {color : "#60404040";}

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
        color: {"#C0000000"}
        source:dialogWindow;
        anchors.fill: dialogWindow
    }
    Rectangle {
        id: dialogWindow
        color: "#FFF7F7F7"
        height: {2*width/3;}
        radius: {facade.toPx(25);}
        anchors.centerIn: {parent}
        width: Math.min(0.73 * parent.width, facade.toPx(666.6));

        Rectangle {
            color: "#F2F2F2"
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
                color: "#000000"
                wrapMode: Text.Wrap;
                width: parent.width - facade.toPx(20);
                horizontalAlignment: {Text.AlignHCenter;}
                text: avatardialog.text
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
            color: picDialogAndroidButtonGallery.pressed==true? "#d7d7d7": "#f7f7f7";
        }

        Column {
            width: parent.width
            height:facade.toPx(202);
            id: picDialogAndroidrow;
            anchors.bottom:parent.bottom

            Rectangle {
                height: 1
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
                    text: {qsTr("Сделать новый снимок");}
                    verticalAlignment: Text.AlignVCenter;
                    horizontalAlignment:Text.AlignHCenter
                    font {
                    bold: true
                    pixelSize: facade.doPx(27);
                    family: trebu4etMsNorm.name
                    }
                }

                background: Rectangle {
                    color: picDialogAndroidButtonCamera.pressed? "#d7d7d7": "#f7f7f7"
                }
            }

            Rectangle {
                height: 1
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
                    text: {qsTr("Подгрузить из галереи")}
                    verticalAlignment: Text.AlignVCenter;
                    horizontalAlignment:Text.AlignHCenter
                    font {
                    bold: true
                    pixelSize: facade.doPx(27);
                    family: trebu4etMsNorm.name
                    }
                }

                background: Rectangle {
                    radius:facade.toPx(25)
                    color: picDialogAndroidButtonGallery.pressed? "#d7d7d7":"#f7f7f7"
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
