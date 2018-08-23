import QtQuick 2.7
import QtQuick.Controls  2.0
import QtGraphicalEffects 1.0

Button {
    id: rootItem;
    anchors.fill: parent
    visible: {loader.dialog}
    contentItem: Text {opacity: 0}
    background: Rectangle {color: "#60404040"}

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
        radius: facade.toPx(25);
        anchors.centerIn:parent;
        width: Math.min(0.73 * parent.width, facade.toPx(666.6));

        Rectangle {
            color: "#F2F2F2"
            anchors {
                fill: parent
                margins:dialogWindow.radius
            }
        }

        Rectangle {
            height: 1
            color: "#808080"
            id: dividerHorizont;
            width: parent.width;
            anchors.bottom: {dialogRow.top;}
        }

        MouseArea {anchors.fill: {(parent)}}

        Item {
            anchors {
                top: parent.top;
                bottom: dividerHorizont.top;
                horizontalCenter: parent.horizontalCenter
            }

            width: (parent.width - 2*dialogWindow.radius)

            Column {
                Label {
                    color:"#000000"
                    wrapMode: Text.Wrap
                    text: rootItem.text
                    width: parent.parent.width
                    horizontalAlignment:Text.AlignHCenter
                    font {
                        pixelSize: facade.doPx(27)
                        family:trebu4etMsNorm.name
                    }
                }
                spacing:facade.toPx(20)

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

                    flickableDirection: {
                        Flickable.VerticalFlick
                    }

                    TextArea.flickable: TextArea {
                        id: screenTextFieldPost
                        placeholderText:qsTr("Написать.")

                        onLineCountChanged: {
                            if(lineCount < 4)
                            flickable.height = screenTextFieldPost.implicitHeight
                        }

                        onFocusChanged: {dialogWindow.y = rootItem.height * 0.1;}

                        color: "#000000"
                        wrapMode: {TextEdit.Wrap;}
                        font.family: trebu4etMsNorm.name;
                        font.pixelSize: (facade.doPx(26))
                        background: Rectangle {border {color:"#E9E9E9"; width:1}}

                        onTextChanged: {
                            if(length > 250)
                            text = text.substring(0, 250)
                            loader.fields[0] =text
                            cursorPosition =length
                        }
                        Keys.onReleased: {
                            if (event.key==Qt.Key_Back||event.key==Qt.Key_Escape)
                                rootItem.text = "";
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
                top: dividerHorizont.bottom
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                top: dividerHorizont.bottom
            }
            width: parent.width / 2;
            height: facade.toPx(25);
            color: dialogAndroidButtonCancel.pressed == true? "#d7d7d7":"#f7f7f7"
            visible: choseMode !="";
        }

        Row {
            id: dialogRow
            width: parent.width
            height: facade.toPx(100)
            anchors.bottom:parent.bottom
            Button {
                visible: choseMode !="";
                id: dialogAndroidButtonCancel;

                width: parent.width/2-1;
                anchors.top: parent.top;
                anchors.bottom: parent.bottom;

                onClicked: {
                    inputMode = "";
                    loader.dialog=false;
                    rootItem.text = ("")
                }

                contentItem: Text {
                    color:"#34aadc"
                    text: qsTr("Отмена")
                    verticalAlignment: Text.AlignVCenter;
                    horizontalAlignment:Text.AlignHCenter
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
                    text:qsTr("Принять")
                    elide:Text.ElideRight;
                    verticalAlignment: Text.AlignVCenter;
                    horizontalAlignment:Text.AlignHCenter
                    font {
                    bold: true;
                    pixelSize: facade.doPx(27)
                    family:trebu4etMsNorm.name
                    }
                }

                background: Rectangle {
                    color:dialogAndroidButtonOk.pressed==true?"#d7d7d7":"#f7f7f7"
                    radius:facade.toPx(25)
                }

                onClicked: {
                    choose = false;
                    inputMode = "";
                    loader.forceActiveFocus();
                    loader.dialog = false;
                    rootItem.text="";
                    switch(inputMode) {
                        case "VK":
                            postToVk(); break;
                    }
                }

                anchors {
                    bottom: parent.bottom;
                    top: parent.top
                }
            }
        }
    }

    onClicked: {
        loader.focus = !(loader.dialog =false)
    }

    property bool choose: true
    property string inputMode: "";
    property string choseMode: "";

    function show(text, powMode) {
        switch (powMode) {
            case 1: inputMode = ("one"); break
            case 2: choseMode = ("one"); break
            default:inputMode = choseMode = ""
        }
        choose=loader.dialog=true;
        rootItem.text=text
    }
}
