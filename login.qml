import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle
import "js/URLQuery.js" as URLQuery

Item {
    property real oldsWidth
    property real pageWidth
    property real limsWidth: facade.toPx(1080)

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
            topMargin: displayMarginBeginning
        }

        model:ListModel {
            id: listModel
            ListElement {
                image: ""
                placeholder: ""
            }
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
            partnerHeader.height+facade.toPx(50)+
               ((parent.height - partnerHeader.height - pageWidth-(listModel.count-1)*facade.toPx(90)-listModel.count*listView.spacing)/2>0?
                    (parent.height-partnerHeader.height-pageWidth-(listModel.count-1)*facade.toPx(90)-listModel.count*listView.spacing)/2:0)
        }

        delegate: Column {
            width: listView.width
            height: index == 3?
                        facade.toPx(110):
                        (index==0? pageWidth:facade.toPx(89))

            ListView {
                spacing: facade.toPx(10);
                id: navigateButtons
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                visible: index == 0
                height: {pageWidth}
                width: links.count*(pageWidth + spacing)
                orientation:Qt.Horizontal

                model:  ListModel {
                        id: links
                        ListElement {
                            image: "ui/buttons/social/fb.png"
                        }
                        ListElement {
                            image: "ui/buttons/social/tw.png"
                        }
                        ListElement {
                            image: "ui/buttons/social/vk.png"
                        }
                    }
                delegate: Image {
                    source: image
                    width: pageWidth = (facade.toPx(sourceSize.width*1.5*(listView.width>limsWidth? 1: listView.width/limsWidth))>0?
                              oldsWidth=facade.toPx(sourceSize.width*1.5*(listView.width>limsWidth? 1: listView.width/limsWidth)): oldWidth)
                    height:pageWidth
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var params = { }
                            switch (index) {
                            case 0: params = {
                                    display: 'popup',
                                    response_type: 'token',
                                    scope:'publish_stream',
                                    client_id:'396748683992616',
                                    redirect_uri: 'https://www.facebook.com/connect/login_success.html'
                                }
                                loader.urlLink="https://graph.facebook.com/oauth/authorize?%1".arg(URLQuery.serializeParams(params))
                                partnerHeader.text = "Facebook";
                                break;
                            case 1:
                            case 2: params = {
                                    display: 'popup',
                                    client_id: '5813771',
                                    scope: 'wall,offline',
                                    response_type:'token',
                                    redirect_uri: 'http://oauth.vk.com/blank.html'
                                }
                                partnerHeader.text = "Вконтакте"
                                loader.urlLink = ("https://oauth.vk.com/authorize?%1".arg(URLQuery.serializeParams(params))); break;
                            }
                            loader.goTo("qrc:/webview.qml")
                        }
                    }
                }
            }

            DropShadow {
                radius: 12
                samples: 20
                anchors {
                    fill:loginButon
                }
                visible: index == 3 || index == 4
                color: "#80000000";
                source: loginButon;
            }
            Button {
                id: loginButon
                text: plaseholder
                height: facade.toPx(100)
                width: Math.min(0.82*parent.width, facade.toPx(900))
                visible: index == 3 || index == 4

                font.pixelSize: {facade.doPx(29)}
                font.family: trebu4etMsNorm.name;

                anchors.horizontalCenter: {parent.horizontalCenter;}

                onClicked: {
                    switch(index) {
                    case 3:
                        if (loader.fields[0].length <= 10) {
                            windowsDialogs.show("Телефон не правильный",0)
                        }
                        else if(loader.fields[1].length<5) {
                            windowsDialogs.show("Пароль < 5ти символов",0)
                        }
                        else {
                        var telephone = loader.fields[0];
                        var passwords = loader.fields[1];
                        busyIndicator.visible = true;
                        loader.logon(telephone,passwords)
                        }
                        break;
                    case 4:
                        loader.goTo("qrc:/qrscan.qml")
                        break;
                    }
                }

                background: Rectangle {
                    color: parent.down? (index == 3? "#FFC129": "#CD463E"): (index == 3? "#FFCC40": "#F15852")
                    radius:facade.toPx(40)
                }

                contentItem: Text {
                    color: parent.down? (index == 3? "#000000": "#EECFCF"): (index == 3?"#960f133d":"#FFFFFF")
                    horizontalAlignment:Text.AlignHCenter
                    verticalAlignment : Text.AlignVCenter
                    opacity: enabled?1:0.3
                    elide: Text.ElideRight
                    text: parent.text
                    font: parent.font
                }
            }

            Item {
                visible:index == 1 || index == 2;
                height: facade.toPx(88)
                anchors {
                    left: {parent.left}
                    right: parent.right
                    leftMargin: 0.09*parent.width
                    rightMargin:0.09*parent.width
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
                    loader.fields[index-1]=(text)
                }

                inputMethodHints:
                    index == 1?Qt.ImhFormattedNumbersOnly:Qt.ImhNone

                onFocusChanged: if(text.length==0&&index==1)text="8"

                echoMode:
                    index == 2?TextInput.Password: TextInput.Normal;

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
                visible:index==5
                text:plaseholder
            }

            Rectangle {
                visible: index == 1 || index == 2
                width: 0.82*parent.width;
                anchors.horizontalCenter:
                {parent.horizontalCenter}
                color: "#FFFFFF"
                height: 1
            }
        }
    }
}
