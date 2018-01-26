import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Button {
    property bool choose:true;
    property string inputMode: "";
    property string choseMode: "";

    contentItem: Text {opacity: 0}

    function show(text, powMode) {
        choose=loader.dialog=true;
        switch (powMode) {
            case 1: inputMode = "one"; break;
            case 2: choseMode = "one"; break;
            default:inputMode = choseMode= ""
        }
        dialogAndroid.text = text;
    }

    DropShadow {
        radius: 16
        samples: 20
        color:("#C0000000")
        source:dialogWindow
        anchors.fill:dialogWindow;
    }
    Rectangle {
        id: dialogWindow;
        color: "#f7f7f7";
        height: 2*width/3
        radius: {facade.toPx(25);}
        anchors.centerIn: {parent}
        width: Math.min(0.73 * parent.width, facade.toPx(666.6));

        MouseArea {anchors.fill: {(parent);}}

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
                    TextArea.flickable:TextArea{
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
            anchors {
                left: parent.left;
                right: parent.right;
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
                    color:"#34aadc"
                    text: qsTr("Отмена")
                    verticalAlignment: {Text.AlignVCenter;}
                    horizontalAlignment: {Text.AlignHCenter;}
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

            Rectangle {
                color: "#808080"
                width: 1
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
                    elide:Text.ElideRight;
                    verticalAlignment: {Text.AlignVCenter;}
                    horizontalAlignment: {Text.AlignHCenter;}
                    font {
                    bold: true;
                    pixelSize: facade.doPx(27)
                    family:trebu4etMsNorm.name
                    }
                    text:qsTr("Ок")
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
                        case "VK": postToVk();
                    }
                    choose = false;
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
                margins: (dialogWindow.radius)
            }

            gradient: Gradient {
                GradientStop {
                    position: (0.0)
                    color:"#ffffff"
                }
                GradientStop {
                    position: (0.8)
                    color:"#999999"
                }
            }
        }
    }
    background: Rectangle {color: "#AC404040"}

    id: dialogAndroid
    visible: loader.dialog;
    anchors.fill: {parent;}

    onClicked: {
        loader.focus = true
        loader.dialog=false
    }
}
