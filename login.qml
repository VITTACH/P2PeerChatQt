import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle
import "js/URLQuery.js" as URLQuery

Item {
    property variant oldsWidth;
    property variant pageWidth;
    property variant limsWidth: facade.toPx((1080));

    Component.onCompleted: partnerHeader.text="Вход"

    Item {
        width:2*parent.width
        height: {parent.height}
        P2PStyle.ColorAnimate {
            anchors.fill: {(parent)}
            Component.onCompleted: setColors([[180, 180, 180], [107,107,107]], 500)
        }
        Image {
            y:(parent.height-height)
            x:(parent.width-width)/2
            source: {("qrc:/ui/backind/back1.png");}
            height: {facade.doPx(sourceSize.height)}
            width: {
                if (parent.width > facade.toPx(sourceSize.width)) {
                    parent.width
                }
                else {facade.toPx(sourceSize.width)}
            }
        }
    }

    ListView {
        id: listView
        width: parent.width
        spacing: facade.toPx(50)
        model:ListModel {
            id: listModel
            ListElement {image: ""; placeholder: "develop VITTACH"}
            ListElement {
                image: "ui/icons/phoneIconWhite.png"; plaseHolder: "Номер телефона"
            }
            ListElement {
                image: "ui/icons/PassWIconWhite.png"; plaseHolder: "Введите пароль"
            }
            ListElement {image: ""; plaseHolder: "Начать Общение";}
            ListElement {image: ""; plaseHolder: "Вход по QR-коду"}
            ListElement {image: ""; plaseHolder: "Нету аккаунта?";}
        }

        anchors {
            top: parent.top
            bottom:parent.bottom
            topMargin: displayMarginBeginning
        }
        displayMarginBeginning: {
            partnerHeader.height+facade.toPx(50)+
               ((parent.height - partnerHeader.height - pageWidth-(listModel.count-1)*facade.toPx(90)-listModel.count*listView.spacing)/2>0?
                    (parent.height-partnerHeader.height-pageWidth-(listModel.count-1)*facade.toPx(90)-listModel.count*listView.spacing)/2:0)
        }

        delegate: Column {
            width: listView.width
            height: index==3? facade.toPx(110): (index<1?pageWidth:facade.toPx(89))

            ListView {
                visible:index<1
                height: pageWidth
                width: {links.count*(pageWidth + spacing)}
                spacing: facade.toPx(10);
                orientation:Qt.Horizontal
                anchors.horizontalCenter: {parent.horizontalCenter}

                model:ListModel {
                    id: links
                    ListElement {image: "ui/buttons/social/fb.png"}
                    ListElement {image: "ui/buttons/social/tw.png"}
                    ListElement {image: "ui/buttons/social/vk.png"}
                }
                delegate: Image {
                    source: image
                    width: pageWidth = (facade.toPx(sourceSize.width*1.5*(listView.width>limsWidth? 1: listView.width/limsWidth)) > 0?
                            oldsWidth = facade.toPx(sourceSize.width*1.5*(listView.width>limsWidth? 1: listView.width/limsWidth)):oldsWidth)
                    height:pageWidth
                    MouseArea {
                        onClicked: {
                            var params
                            switch (index) {
                            case 0: params = {
                                    display: 'popup',
                                    response_type: 'token',
                                    client_id:'396748683992616',
                                    redirect_uri:'https://www.facebook.com/connect/login_success.html'
                                }
                                loader.urlLink = "https://graph.facebook.com/oauth/authorize?%1".arg(URLQuery.serializeParams(params))
                                partnerHeader.text = "Facebook";
                                break;
                            case 1:
                            case 2: params = {
                                    display: 'popup',
                                    client_id: '5813771',
                                    scope: 'wall, offline',
                                    response_type: 'token',
                                    redirect_uri:'http://oauth.vk.com/blank.html'
                                }
                                loader.urlLink = (String) ("https://oauth.vk.com/authorize?%1".arg(URLQuery.serializeParams(params)));
                                partnerHeader.text = "Вконтакте"
                                break;
                            }
                            loader.goTo("qrc:/webview.qml")
                        }
                        anchors.fill: parent
                    }
                }
            }

            Item {
                height:facade.toPx(100)
                visible: (index == 3 || index == 4)
                width: Math.min(0.82*parent.width,facade.toPx(900))
                anchors.horizontalCenter: {parent.horizontalCenter}

                DropShadow {
                    radius: 12
                    samples: 20
                    anchors.fill: loginButon
                    color: "#80000000";
                    source: loginButon;
                }
                Button {
                    id: loginButon
                    text: typeof plaseHolder == "undefined"? "": plaseHolder
                    anchors.fill:parent

                    font.pixelSize: facade.doPx(29)
                    font.family:trebu4etMsNorm.name

                    onClicked: {
                        switch(index) {
                        case 3:
                            if (loader.fields[0].length <= 10) {
                                informDialog.show("Телефон не правильный",0)
                            }
                            else if(loader.fields[1].length<5) {
                                informDialog.show("Пароль < 5ти символов",0)
                            }
                            else {
                                var telephone = loader.fields[(0)];
                                var passwords = loader.fields[(1)];
                                loader.logon(telephone, passwords);
                            }
                            break;
                        case 4:
                            loader.goTo("qrc:/qrscaner.qml");
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
                        verticalAlignment: Text.AlignVCenter
                        text: parent.text
                        font: parent.font
                    }
                }
            }

            Item {
                Image {
                    id: icon;
                    source: image
                    width: {facade.toPx(sourceSize.width *15 / 10)}
                    height:{facade.toPx(sourceSize.height*15 / 10)}
                }

                height:facade.toPx(88)
                visible:{(index === 1) || (index === 2)}
                width: Math.min(0.82*parent.width,facade.toPx(900))
                anchors.horizontalCenter: (parent.horizontalCenter)

                TextField {
                    color:"white"
                    height: facade.toPx(88)
                    placeholderText: typeof plaseHolder == "undefined"? "": plaseHolder
                    onTextChanged: loader.fields[index - 1] = text;

                    onFocusChanged: if (text.length === 0 && index === (1)){text = "8"}
                    echoMode: if (index == 2) TextInput.Password; else TextInput.Normal
                    inputMethodHints: index == 1? Qt.ImhFormattedNumbersOnly:Qt.ImhNone
                    background: Rectangle {opacity: (0)}
                    font.family: {(trebu4etMsNorm.name)}
                    font.pixelSize: {(facade.doPx(38));}
                    anchors.leftMargin: facade.toPx(20);
                    anchors.left:icon.right
                }
            }

            Button {
                contentItem: Text {
                    verticalAlignment: Text.AlignVCenter
                    color:parent.down == true? "#D3D3D3": "#FFFFFF"
                    text: parent.text;
                    font: parent.font;
                }

                anchors.left: {parent.left}
                anchors.leftMargin: 0.09 * parent.width;
                anchors.right: parent.right
                anchors.rightMargin:0.09 * parent.width;

                text:typeof plaseHolder=="undefined"?"":plaseHolder
                font.pixelSize: {facade.doPx(26)}
                font.family: trebu4etMsNorm.name;
                background: Rectangle {opacity:0}
                onClicked: partnerHeader.page =1;
                visible: (index == 5);
            }

            Rectangle {
                anchors.horizontalCenter: {parent.horizontalCenter}
                width: Math.min(0.82*parent.width,facade.toPx(900))
                visible:index == 1 || index == 2;
                height: facade.toPx(3)
            }
        }
    }
}
