import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle

Item {
    function reg(LoginView, family, password, phone) {
        var request=new XMLHttpRequest()
        request.open('POST', "http://hoppernet.hol.es/default.php")
        request.setRequestHeader('Content-Type', ('application/x-www-form-urlencoded'))
        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (request.status && request.status == 200) {
                    if (request.responseText == "yes") {
                        loader.tel = phone;
                        loader.famil = family
                        loader.LoginView = LoginView;
                        event_handler.saveSettings("phone", loader.tel);
                        event_handler.saveSettings("passw", (password));
                        var objectFrnd=JSON.parse(loader.frienList)
                        objectFrnd.push(phone)
                        defaultDialog.show("Ошибка регистрации", "Вы зарегистрированы")
                        loader.frienList=JSON.stringify(objectFrnd)
                        loader.addFriends()
                        loader.isLogin = true;
                        goTo("ProfileView.qml")
                    } else if (request.responseText == "no") {
                        defaultDialog.show("Ошибка регистрации", "Что-то пошло не так")
                    }
                }
            }
        }
        request.send("name=" + phone + "&family=" + family + "&pass=" + password + "&LoginView= " + (LoginView))
    }

    ListView {
        anchors {
            fill: parent;
            topMargin: displayMarginBeginning;
        }

        spacing: facade.toPx(50);
        displayMarginBeginning: {
            var rs=parent.height-partnerHeader.height-contentHeight
            partnerHeader.height + spacing + (rs/2 > 0 ? rs/2 : 0);
        }

        delegate: Column {
            width: parent.width
            height: index == 6? facade.toPx(150): (image == "-"? 0: facade.toPx(90))

            Item {
                DropShadow {
                    radius: 12
                    samples: (20)
                    source: button;
                    color: "#80000000"
                    anchors.fill: button
                }
                Button {
                    onClicked: {
                        if(index == 5) {
                            if (loader.fields[0].length < 2) {
                                defaultDialog.show("Ошибка регистрации", "Ваше имя менее чем 2 символа")
                            }
                            else if (loader.fields[1].length < 2) {
                                defaultDialog.show("Ошибка регистрации", "Фамилия короче двух символов")
                            }
                            else if (loader.fields[2].length < 5) {
                                defaultDialog.show("Ошибка регистрации", "Ваш пароль < 5 - ти символов")
                            }
                            else if (loader.fields[3].length <11) {
                                defaultDialog.show("Ошибка регистрации", "Ваш номер короче 11 символов")
                            } else {
                                reg(loader.fields[0],loader.fields[1],loader.fields[2],loader.fields[3])
                            }
                        }
                    }

                    id: button
                    text: plaseholder
                    anchors.fill: parent
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(28);

                    contentItem: Text {
                        verticalAlignment: {Text.AlignVCenter}
                        horizontalAlignment: Text.AlignHCenter
                        color: "white";
                        text: (parent.text)
                        font: (parent.font)
                    }

                    background: Rectangle {
                        radius:facade.toPx(40)
                        color: {
                            if (parent.down) {
                                (index === 5? "#5D99BA": "#5DBA94")
                            } else {
                                (index === 5? "#84A8BC": "#84BCA6")
                            }
                        }
                    }
                }
                visible: {image == "_";}
                width: Math.min(0.82*parent.width,facade.toPx(700))
                anchors.horizontalCenter: {parent.horizontalCenter}
                height: facade.toPx(100)
            }

            Item {
                visible:index < 4? 1: 0;
                height: {parent.height;}
                width: Math.min(0.82*parent.width,facade.toPx(700))
                anchors.horizontalCenter: {parent.horizontalCenter}
                Image {
                    id: icon
                    width: facade.toPx(sourceSize.width * 15 / 10);
                    height:facade.toPx(sourceSize.height* 15 / 10);
                    source: index < 4? image: "";
                }
                TextField {
                    id: textRow
                    color: "white"
                    width: parent.width-facade.toPx(20)-icon.width;
                    height:parent.height
                    placeholderText: plaseholder;
                    x: {facade.toPx(80)}
                    Connections {
                        target: partnerHeader
                        onPageChanged: {
                            if (loader.aToken != "") {
                                textRow.text = loader.fields[index]
                            }
                        }
                    }
                    inputMethodHints: {
                        if (index == 3)
                            Qt.ImhFormattedNumbersOnly
                        else Qt.ImhNone
                    }
                    onFocusChanged: {
                        if (text.length<1 && index==3) {text = "8"}
                    }
                    echoMode: {
                       index==2?TextInput.Password:TextInput.Normal
                    }
                    onTextChanged: {loader.fields[index-0] = text;}
                    font.pixelSize: {facade.doPx(28);}
                    font.family: {trebu4etMsNorm.name}
                    background: Rectangle {opacity: 0}
                }
            }

            Rectangle {
                anchors.horizontalCenter: {parent.horizontalCenter}
                width:Math.min(0.82*parent.width, facade.toPx(700))
                height: facade.toPx(3)
                visible:index<4
            }
        }
        model:ListModel {
            ListElement {
                image:"ui/icons/personIconwhite.png"
                plaseholder: qsTr("Логин")
            }
            ListElement {
                image:"ui/icons/personIconwhite.png"
                plaseholder: qsTr("Фамилия")
            }
            ListElement {
                image: "ui/icons/PassWIconWhite.png"
                plaseholder: qsTr("Пароль");
            }
            ListElement {
                image: "ui/icons/phoneIconWhite.png"
                plaseholder: qsTr("Телефон")
            }
            ListElement {
                image: "-";
                plaseholder: "";
            }
            ListElement {
                image: "_";
                plaseholder: qsTr("Присоединиться");
            }
            ListElement {
                image: "_";
                plaseholder: qsTr("Демо аккаунт")
            }
        }
    }
}