import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

//--------------------------------------------------dialogAndroid----------------------------------------------
Button {
    z: 3
    id: dialogAndroid
    visible: loader.dialog;
    anchors.fill: {parent;}
    property string inputMode: "";
    property string choseMode: "";

    onClicked: loader.dialog=false

    background: Rectangle {color:"#AC404040"}

    function show(text, powMode) {
        loader.dialog = (true);
        switch (powMode) {
            case 1: inputMode = "one"; break;
            case 2: choseMode = "one"; break;
            default:inputMode = choseMode= ""
        }
        dialogAndroid.text = text;
    }

    contentItem: Text {opacity: 0}

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

        //создаём горизонтальный разделитель у всего окна
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

        //место отобажения сообщения для диалогового окна
        Rectangle {
            color: "#f7f7f7"
            radius:facade.toPx(25)

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                bottom:dialogAndroidDividerHorizontal.top
            }

            width: (parent.width - 2*dialogWindow.radius)

            Column {
                spacing:facade.toPx(20)
                Label {
                    color: "#000000"
                    wrapMode: Text.Wrap
                    text: dialogAndroid.text
                    width: parent.parent.width
                    font.pixelSize: facade.doPx(27)
                    font.family:trebu4etMsNorm.name
                    horizontalAlignment:Text.AlignHCenter
                }

                anchors {
                    top: parent.top
                    topMargin: facade.toPx(50);
                    centerIn: inputMode != ""? undefined: parent;
                    horizontalCenter: {(parent.horizontalCenter)}
                }

                Flickable {
                    id: flickable
                    visible:inputMode!=""? 1:0;

                    height: inputMode!=""? screenTextFieldPost.implicitHeight: 0;

                    anchors{
                        left: parent.left
                        right: parent.right
                        leftMargin : 9/100 * parent.width
                        rightMargin: 9/100 * parent.width
                    }
                    flickableDirection: {Flickable.VerticalFlick}
                    TextArea.flickable: TextArea
                    {
                        id: screenTextFieldPost;
                        placeholderText:qsTr("Написать.")

                        onLineCountChanged: {
                            if(lineCount < 4)
                            flickable.height = screenTextFieldPost.implicitHeight
                        }
                        onFocusChanged: dialogWindow.y = dialogAndroid.height*0.1

                        background: Rectangle {
                            border {
                                color: "#E9E9E9"; width:1
                            }
                        }
                        color: "#000000"
                        wrapMode: TextEdit.Wrap
                        font.family: trebu4etMsNorm.name;
                        font.pixelSize: (facade.doPx(26))

                        onTextChanged: {
                            if(length > 250)
                            text = text.substring(0,250);
                            loader.fields[0] =text
                            cursorPosition =length
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
                    text: 250- screenTextFieldPost.length
                    anchors {
                        right: parent.right
                        rightMargin: 0.09 * parent.width;
                    }
                }
            }
        }

        Rectangle {
            height: facade.toPx(25)
            color: dialogAndroidButtonOk.pressed == true? "#ffd7d7d7": "#f7f7f7";
            width: (choseMode != "") == true? parent.width / 2 - 0: parent.width;
            anchors {
                right: parent.right
                top:dialogAndroidDividerHorizontal.bottom
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                top:dialogAndroidDividerHorizontal.bottom
            }
            width: parent.width / 2;
            height: facade.toPx(25);
            color: dialogAndroidButtonCancel.pressed == true? "#d7d7d7":"#f7f7f7"
            visible: choseMode !="";
        }

        Row {
            id: dialogAndroidrow
            // А также прибиваем строку к низу у диалогового окна
            anchors {
                left: parent.left
                right: parent.right
                bottom:parent.bottom
            }
            height: facade.toPx(100)

            Button {
                visible: choseMode !="";
                id: dialogAndroidButtonCancel;

                width: parent.width/2-1;
                anchors.top: parent.top;
                anchors.bottom: parent.bottom;

                onClicked: {
                    inputMode = "";
                    loader.dialog=false;
                    dialogAndroid.text = ("");
                }

                contentItem: Text {
                    color: ("#34aadc")
                    verticalAlignment: {
                        Text.AlignVCenter;
                    }
                    horizontalAlignment: {
                        Text.AlignHCenter;
                    }
                    text: qsTr("Закрыть");
                    font {
                        pixelSize: facade.doPx(27)
                        family:trebu4etMsNorm.name
                    }
                }

                background: Rectangle {
                    radius:facade.toPx(25)
                    color: dialogAndroidButtonCancel.pressed? "#d7d7d7":"#f7f7f7"
                }
            }

            //Создаю разделитель между кнопками шириной 2 пикселя
            Rectangle {
                color: "#808080"
                width: facade.toPx(2)
                visible: (choseMode != "")
                //Растягиваю разделитель по высоте объекта строки
                anchors {
                    top: parent.top
                    bottom: parent.bottom;
                }
            }

            Button {
                id: dialogAndroidButtonOk;
                width: choseMode!=""? parent.width/2:parent.width

                contentItem: Text {
                    color:"#34aadc"
                    elide: Text.ElideRight
                    verticalAlignment: {
                        Text.AlignVCenter;
                    }
                    horizontalAlignment: {
                        Text.AlignHCenter;
                    }
                    font {
                        bold: true
                        pixelSize: facade.doPx(27)
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
                      case "VK":postToVk()
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
            anchors {
                fill: parent
                topMargin: (dialogWindow.radius)
                leftMargin: (dialogWindow.radius)
                rightMargin: (dialogWindow.radius)
                bottomMargin: dialogWindow.radius;
            }

            gradient: Gradient {
                GradientStop {
                    position: 0.0;
                    color: "white"
                }
                GradientStop {
                    position: 0.8;
                    color: "gray"
                }
            }
        }
    }
}
//-------------------------------------------------------------------------------------------------------------
