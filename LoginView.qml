import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0;
import "P2PStyle" as P2PStyle;
import "js/URLQuery.js"as URLQuery

Item {
    property var pageWidth

    Rectangle {
        height: parent.height
        width: 2 * parent.width
        color: loader.feed3Color;

        Image {
            opacity: 0.55
            anchors.bottom: parent.bottom
            source: {("qrc:/ui/backind/back1.png");}
            height: parent.height/4
            x: (parent.width-width)/2
            width: {
                if (parent.width > facade.toPx(sourceSize.width)) {parent.width;}
                else {facade.toPx(sourceSize.width)}
            }
        }
    }

    ListView {
        id: listView
        width: parent.width
        spacing: facade.toPx(50);

        anchors {
            top: parent.top
            bottom: parent.bottom
            topMargin: displayMarginBeginning;
        }

        displayMarginBeginning: {
            var rs=parent.height-partnerHeader.height-contentHeight
            partnerHeader.height + spacing + (rs/2 > 0 ? rs/2 : 0);
        }

        model:ListModel {
            ListElement {image: ""; placeholder: ""}
            ListElement {
                image: "ui/icons/phoneIconWhite.png"; plaseHolder: qsTr("Телефон")
            }
            ListElement {
                image: "ui/icons/PassWIconWhite.png"; plaseHolder: qsTr("Введите пароль");
            }
            ListElement {
                image: qsTr(""); plaseHolder:qsTr("Начать Общение")
            }
            ListElement {
                image: qsTr("");plaseHolder:qsTr("Вход по QR-Коду")
            }
            ListElement {
                image: qsTr(""); plaseHolder:qsTr("Нету аккаунта?")
            }
            ListElement {image: ""; placeholder: ""}
        }
        delegate: Column {
            width: parent.width
            height: if (index == 0) pageWidth; else facade.toPx(90)

            ListView {
                id: socials
                visible: !index
                height: pageWidth
                width: model.count * (pageWidth + spacing)-spacing;
                orientation:Qt.Horizontal
                spacing: facade.toPx(25);
                anchors.horizontalCenter: {parent.horizontalCenter}

                model:ListModel {
                    id: socModel;
                    ListElement {image: "ui/buttons/social/fb.png"}
                    ListElement {image: "ui/buttons/social/tw.png"}
                    ListElement {image: "ui/buttons/social/vk.png"}
                }
                delegate: Item {
                    height: width
                    width: pageWidth = (Math.min(0.82*listView.width, facade.toPx(700))-(socModel.count-1)*socials.spacing)/socModel.count

                    DropShadow {
                        radius:11
                        samples: 15
                        source: social
                        color: "#90000000"
                        anchors.fill: social
                    }

                    Image {
                        id: social
                        source: image
                        anchors.fill: parent

                        MouseArea {
                            onClicked: {
                                switch (index) {
                                    case 0: var params = {
                                        display: 'popup',
                                        response_type: 'token',
                                        client_id:'396748683992616',
                                        redirect_uri:'https://www.facebook.com/connect/login_success.html'
                                    }
                                    loader.urlLink = "https://graph.facebook.com/oauth/authorize?%1".arg(URLQuery.serializeParams(params))
                                    partnerHeader.text = qsTr("Facebook");
                                    break;

                                    case 1:
                                    case 2: var params = {
                                        display: 'popup',
                                        client_id: '5813771',
                                        scope: 'wall, offline',
                                        response_type: 'token',
                                        redirect_uri: 'https://oauth.vk.com/blank.html'
                                    }
                                    loader.urlLink = (String) ("https://oauth.vk.com/authorize?%1".arg(URLQuery.serializeParams(params)));
                                    partnerHeader.text = qsTr("Вконтакте")
                                    break;
                                }

                                loader.webview = true
                                loader.goTo("qrc:/WebView.qml")
                            }
                            anchors.fill: parent
                        }
                    }
                }
            }

            Item {
                height: facade.toPx(100)
                visible: (index == 3 || index == 4);
                width: Math.min(0.82*parent.width,facade.toPx(700))
                anchors.horizontalCenter: {parent.horizontalCenter}

                DropShadow {
                    radius: 12
                    samples: 20
                    color: {"#80000000"}
                    source: {loginButon}
                    anchors.fill: {loginButon}
                }
                Button {
                    id: loginButon
                    anchors.fill: parent
                    text: {
                        if (typeof plaseHolder == "undefined") {""}
                        else plaseHolder
                    }
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(29);

                    onClicked: {
                        switch(index) {
                        case 3:
                            if (loader.fields[0].length <= 10) {
                                defaultDialog.show("Ошибка входа", "Телефон не правильный")
                            } else if (loader.fields[1].length<5) {
                                defaultDialog.show("Ошибка входа", "Пароль < 5ти символов")
                            } else {
                                var telephone = loader.fields[(0)];
                                var passwords = loader.fields[(1)];
                                loader.logon(telephone, passwords);
                            }
                            break;
                        case 4:
                            loader.goTo("qrc:/QrScaner.qml");
                            break;
                        }
                    }

                    background: Rectangle {
                        color: {
                            if (parent.down) {
                                (index == 3? "#F7DA71": "#D86B68");
                            } else {
                                (index == 3? "#E2CE7A": "#CC7D7A");
                            }
                        }
                        radius:facade.toPx(40)
                    }

                    contentItem: Text {
                        color: {
                            if (parent.down) {
                                (index == 3? "#000000": "#EECFCF");
                            } else {
                                (index == 3? "#0f133d": "#FFFFFF");
                            }
                        }
                        horizontalAlignment: {(Text.AlignHCenter);}
                        verticalAlignment: Text.AlignVCenter;
                        text: parent.text;
                        font: parent.font;
                    }
                }
            }

            Item {
                height:facade.toPx(88)
                visible: index === 1 || index === 2;
                width: Math.min(0.82*parent.width,facade.toPx(700))
                anchors.horizontalCenter: (parent.horizontalCenter)

                Image {
                    id: icon;
                    source: image;
                    width: {facade.toPx(sourceSize.width * 15 /10)}
                    height:{facade.toPx(sourceSize.height* 15 /10)}
                }

                TextField {
                    color: "white"
                    height: facade.toPx(88)
                    width: parent.width-facade.toPx(20)-icon.width;
                    onTextChanged: loader.fields[index - 1] = text;
                    placeholderText: {
                        typeof plaseHolder == "undefined" ? ("") : plaseHolder;
                    }
                    inputMethodHints: {
                        if (index == 1) Qt.ImhDialableCharactersOnly
                        else Qt.ImhNone
                    }
                    onFocusChanged: {
                        if (text.length == 0 && index == 1)text="8"
                    }
                    echoMode: index == 2? TextInput.Password : TextInput.Normal
                    background: Rectangle{opacity:0}
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(29);
                    x: facade.toPx(80);
                }
            }

            Item {
                Button {
                    anchors.right: parent.right
                    onClicked: partnerHeader.page=1;
                    anchors.bottom: {parent.bottom;}
                    contentItem: Text {
                        verticalAlignment: Text.AlignVCenter
                        color:parent.down==true? "#D3D3D3": "white"
                        text: parent.text
                        font: parent.font
                    }
                    text: typeof plaseHolder == "undefined"? ("") : plaseHolder
                    background: Rectangle{opacity:0}
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(26);
                }

                visible: {index === 5;}
                height:facade.toPx(100)
                width: Math.min(0.82*parent.width,facade.toPx(700))
                anchors.horizontalCenter: {parent.horizontalCenter}
            }

            Rectangle {
                anchors.horizontalCenter: {parent.horizontalCenter}
                width: Math.min(0.82*parent.width,facade.toPx(700))
                visible: {index == 1 || index == 2;}
                height: facade.toPx(3);
            }
        }
    }
}