import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

//--------------------------------------------------dialogAndroid----------------------------------------------
Button {
    z: 3
    id: dialogAndroid
    anchors.fill: parent
    visible: loader.dialog;

    background: Rectangle {
        opacity: 0.8; color: "#404040";
    }

    property string inputMode;

    Rectangle {
        id: dialogWin
        color: "#f7f7f7"
        radius:facade.toPx(25)

        x: (parent.width /2 - width /2)
        y: (parent.height/2 - height/2)

        height:dialogAndroid.height/2.5
        width:2.2*dialogAndroid.width/3

        // Создаём горизонтальный разделитель
        Rectangle {
            id:dialogAndroidDividerHorizontal
            height: 1
            color: "#808080"
            anchors {
                left: parent.left
                right: parent.right
                bottom: dialogAndroidrow.top;
            }
        }

        // место отобажения сообщения для диалогового окна
        Rectangle {
            color: "#f7f7f7"
            radius: facade.toPx(25)

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: dialogAndroidDividerHorizontal.top
            }

            Column {
                spacing: facade.toPx(20)
                Label {
                    color: "#000000"
                    wrapMode: Text.Wrap
                    text: dialogAndroid.text
                    width: parent.parent.width
                    font {
                        pixelSize: facade.doPx(22);
                        family: trebu4etMsNorm.name
                    }
                    horizontalAlignment: {Text.AlignHCenter}
                }

                anchors {
                    top: parent.top
                    topMargin: facade.toPx(50)
                    horizontalCenter:parent.horizontalCenter

                    centerIn: inputMode != ""? none: parent;
                }

                Flickable {
                    id: flickable
                    visible:inputMode!=""? 1:0

                    height: inputMode!=""? screenTextFieldPost.implicitHeight: 0;

                    anchors{
                        left: parent.left
                        right: parent.right
                        leftMargin: 0.09 * parent.width
                        rightMargin:0.09 * parent.width
                    }
                    flickableDirection: Flickable.VerticalFlick
                    TextArea.flickable: TextArea
                    {
                        id: screenTextFieldPost;
                        placeholderText: "Написать...";

                        onLineCountChanged: {
                            if(lineCount < 4)
                            flickable.height = screenTextFieldPost.implicitHeight
                        }
                        onFocusChanged: dialogWin.y = dialogAndroid.height * 0.1;

                        background: Rectangle {
                            border {
                                color: "#E9E9E9";width:1
                            }
                        }
                        color: "#000000"
                        wrapMode: TextEdit.Wrap
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(26);

                        onTextChanged: {
                            if(length > 250)
                            text = text.substring(0,250)
                            loader.fields[0]=text
                            cursorPosition=length
                        }
                        Keys.onReleased: {
                            if (event.key==Qt.Key_Back||event.key==Qt.Key_Escape)
                                dialogAndroid.text = "";
                            listenBack(event)
                        }
                    }
                }
                Label {
                    visible: inputMode!=""? 1: 0;
                    text: 250-screenTextFieldPost.length
                    anchors {
                        right: parent.right
                        rightMargin:0.09 * parent.width;
                    }
                }
            }
        }

        Rectangle {
            height: facade.toPx(25)
            color: dialogAndroidButtonOk.pressed == true? "#d7d7d7": "#f7f7f7"
            width: dialogAndroid.text==newMessage? parent.width/2-0: parent.width
            anchors {
                right: parent.right
                top: dialogAndroidDividerHorizontal.bottom
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                top: dialogAndroidDividerHorizontal.bottom
            }
            width: parent.width / 2;
            height: facade.toPx(25);
            color: dialogAndroidButtonCancel.pressed == true? "#d7d7d7":"#f7f7f7"
            visible: dialogAndroid.text == newMessage? 1:0
        }

        Row {
            id: dialogAndroidrow
            // А также прибиваем строку к низу у диалогового окна
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: dialogAndroid.height<900?facade.toPx(100):100

            Button {
                width: parent.width/2-1;
                anchors.top: parent.top;
                anchors.bottom: parent.bottom

                id: dialogAndroidButtonCancel
                visible: (dialogAndroid.text == newMessage)? 1: 0

                onClicked: {
                    inputMode = "";
                    loader.dialog = false;
                    dialogAndroid.text="";
                }

                contentItem: Text {
                    verticalAlignment: Text.AlignVCenter;
                    horizontalAlignment:Text.AlignHCenter
                    color:"#34aadc"
                    font {
                        pixelSize: facade.doPx(24)
                        family:trebu4etMsNorm.name
                    }
                    text: qsTr("Закрыть");
                }

                background: Rectangle {
                    radius:facade.toPx(25)
                    color: dialogAndroidButtonCancel.pressed? "#d7d7d7":"#f7f7f7"
                }
            }

            //Создаю разделитель между кнопками шириной в 2 пикселя
            Rectangle {
                color: "#808080"
                width: facade.toPx(2)
                visible: (dialogAndroid.text == newMessage) ? 1: 0;
                // Растягиваем разделитель по высоте объекта строки
                anchors {
                    top: parent.top
                    bottom: parent.bottom;
                }
            }

            Button {
                id: dialogAndroidButtonOk;
                width: dialogAndroid.text==newMessage?parent.width/2:parent.width

                contentItem: Text {
                    elide: Text.ElideRight
                    verticalAlignment: {
                        Text.AlignVCenter;
                    }
                    horizontalAlignment: {
                        Text.AlignHCenter;
                    }
                    color:"#34aadc"
                    font {
                        bold: true;
                        pixelSize: facade.doPx(24)
                        family:trebu4etMsNorm.name
                    }
                    text: qsTr("Понятно");
                }

                background: Rectangle {
                    color:dialogAndroidButtonOk.pressed==true?"#d7d7d7":"#f7f7f7"
                    radius:facade.toPx(25)
                }

                onClicked: {
                    loader.focus = true
                    loader.dialog = false;
                    dialogAndroid.text="";
                    switch(inputMode) {
                     case "VK": postToVk(); break;
                    }
                    inputMode = "";
                }

                anchors {
                    bottom: parent.bottom;
                    top: parent.top
                }
            }
        }

        RadialGradient {
            opacity: 0.2
            anchors.fill: parent
            gradient: Gradient {
                GradientStop {
                    position: 0.0;
                    color: "white"
                }
                GradientStop {
                    position: 0.8;
                    color: "black"
                }
            }
        }
    }
    property string newMessage: "Вам поступило сообщение. Открыть?"

    contentItem: Text {opacity: 0}
}
//-------------------------------------------------------------------------------------------------------------
