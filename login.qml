import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle

Item {
    Component.onCompleted: partnerHeader.text = qsTr("Вход")

    P2PStyle.Background {
        anchors.fill: {parent}
        Component.onCompleted:
            setColors([[0, 74, 127], [120, 120, 120]], 100);
    }

    ListView {
        id: listView
        width: parent.width
        spacing: facade.toPx(50)
        anchors {
            top: parent.top
            bottom:parent.bottom
            topMargin:0.5*parent.height - 2*facade.toPx(100)
        }

        model:ListModel {
            ListElement {
                image: "ui/icons/phoneIconWhite.png";
                plaseholder: qsTr ("Номер телефон");
            }
            ListElement {
                image: "ui/icons/passWIconWhite.png";
                plaseholder: qsTr ("Введите пароль");
            }
            ListElement {
                image: ""
                plaseholder: qsTr ("Начать Общение");
            }
            ListElement {
                image: ""
                plaseholder: qsTr ("Вход по QR-коду")
            }
            ListElement {
                image: ""
                plaseholder: "Еще нет аккаунта?";
            }
        }

        displayMarginBeginning: {
            parent.height*0.5-2*facade.toPx(100);
        }

        delegate: Column {
            width: parent.width
            height: (index == 2)? facade.toPx(110): facade.toPx(89);

            DropShadow {
                radius: 12
                samples: 20
                anchors {
                    fill:loginButon
                }
                visible: index == 2 || index == 3
                color: "#80000000";
                source: loginButon;
            }
            Button {
                id: loginButon
                text: plaseholder
                height: facade.toPx(100)
                width: Math.min(0.82*parent.width, facade.toPx(900))
                visible: index == 2 || index == 3

                font.pixelSize: {facade.doPx(29)}
                font.family: trebu4etMsNorm.name;

                anchors.horizontalCenter: {parent.horizontalCenter;}

                onClicked: {
                    switch(index) {
                    case 2:
                        if (loader.fields[0].length <= 10) {
                        windsDialogs.show("Телефон не правильный",0)
                        }
                        else if(loader.fields[1].length<5) {
                        windsDialogs.show("Пароль < 5ти символов",0)
                        }
                        else {
                        var telephone = loader.fields[0];
                        var passwords = loader.fields[1];
                        busyIndicator.visible = true;
                        loader.logon(telephone,passwords)
                        }
                        break;
                    }
                }

                background: Rectangle {
                    color: parent.down? (index == 2? "#FFC129": "#CD463E"): (index == 2? "#FFCC40": "#F15852")
                    radius:facade.toPx(40)
                }

                contentItem: Text {
                    color: parent.down? (index == 2? "#000000": "#EECFCF"): (index == 2?"#960f133d":"#FFFFFF")
                    horizontalAlignment:Text.AlignHCenter
                    verticalAlignment : Text.AlignVCenter
                    opacity: enabled?1:0.3
                    elide: Text.ElideRight
                    text: parent.text
                    font: parent.font
                }
            }

            Item {
                visible:index < 2? 1:0;
                height: facade.toPx(88)
                anchors {
                    left: {parent.left}
                    right: parent.right
                    leftMargin: 0.09 * parent.width
                    rightMargin:0.09 * parent.width
                }
                Image {
                    id: icon;
                    source: image
                    width: facade.toPx(sourceSize.width * 1.5);
                    height:facade.toPx(sourceSize.height* 1.5);
                }
                TextField {
                color:"white"
                height: facade.toPx(88)
                placeholderText: {(plaseholder);}

                onTextChanged: {
                    loader.fields[index] = (text)
                }

                inputMethodHints:
                    index == 0?Qt.ImhFormattedNumbersOnly:Qt.ImhNone

                onFocusChanged: if(text.length==0&&index==0)text="8"

                echoMode:
                    index == 1?TextInput.Password: TextInput.Normal;

                anchors {
                    left: parent.left;
                    right:parent.right
                    rightMargin:0.09*parent.width
                    leftMargin: (facade.toPx(80))
                }
                background:Rectangle {opacity: 0}

                font.family: trebu4etMsNorm.name;
                font.pixelSize:facade.doPx(38)
                }
            }

            Button {
                anchors {
                    leftMargin: 0.09*parent.width
                    rightMargin:0.09*parent.width
                    left: parent.left;
                    right:parent.right
                }

                background: Rectangle {opacity:0}

                font.pixelSize: {facade.doPx(26)}
                font.family: trebu4etMsNorm.name;

                onClicked: partnerHeader.page = 1

                contentItem: Text {
                    horizontalAlignment:Text.AlignHCenter
                    verticalAlignment : Text.AlignVCenter
                    color:parent.down?"lightgray":"white"
                    opacity:enabled?1:0.3
                    elide:Text.ElideRight
                    text: parent.text;
                    font: parent.font;
                    padding: -8;
                }
                visible:index==4
                text:plaseholder
            }

            Rectangle {
                width: 0.82*parent.width;
                anchors.horizontalCenter:
                {parent.horizontalCenter}
                visible: index<2
                color: "#FFFFFF"
                height: 1
            }
        }
    }
}
