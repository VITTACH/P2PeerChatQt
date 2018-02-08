import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle

Item {
    function registration(login, family, password, phone, email) {
        var request=new XMLHttpRequest()
        request.open('POST', "http://hoppernet.hol.es/default.php")
        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (request.status && request.status == 200) {
                    if (request.responseText == "yes") {
                        loader.tel = phone;
                        loader.famil = family
                        loader.login = login;
                        event_handler.saveSet("phone", loader.tel);
                        event_handler.saveSet("passw", (password));
                        var objectFrnd=JSON.parse(loader.frienList)
                        objectFrnd.push(phone)
                        informDialog.show("Вы зарегистрированы", 0)
                        loader.frienList=JSON.stringify(objectFrnd)
                        loader.addFriends()
                        loader.isLogin = true;
                        goTo("profile.qml")
                    } else if (request.responseText == "no") {
                        informDialog.show("Что-то пошло не так", 0)
                    }
                }
            }
        }
        request.send("name=" + phone + "&family=" + family + "&pass=" + password + "&login= " + login + "&mail=" + email)
    }

    ListView {
        anchors {
            fill: parent;
            topMargin: displayMarginBeginning;
        }

        spacing:facade.toPx(50)
        displayMarginBeginning: {
            var rs=parent.height-partnerHeader.height-contentHeight
            partnerHeader.height + spacing + (rs/2 > 0 ? rs/2 : 0);
        }

        model:ListModel {
            ListElement {image: "ui/icons/personIconwhite.png";plaseholder: "Логин";}
            ListElement {image: "ui/icons/personIconwhite.png";plaseholder:"Фамилия"}
            ListElement {image: "ui/icons/PassWIconWhite.png"; plaseholder: "Пароль"}
            ListElement {image: "ui/icons/phoneIconWhite.png"; plaseholder: "Почта";}
            ListElement {image: "ui/icons/phoneIconWhite.png"; plaseholder:"Телефон"}
            ListElement {image: "-"; plaseholder: ""}
            ListElement {image: "_"; plaseholder: "Присоединиться"}
            ListElement {image: "_"; plaseholder: "Демо вход"}
        }
        delegate: Column {
            width: parent.width
            height: index == 7? facade.toPx(150): (image == "-"? 0: facade.toPx(90));

            Item {
                visible:image == "_"
                height: facade.toPx(100)

                DropShadow {
                    radius: 12
                    samples: 20
                    color: ("#80000000")
                    source: button
                    anchors.fill: button
                }
                Button {
                    id: button
                    text: plaseholder
                    anchors.fill: parent
                    font.family: trebu4etMsNorm.name
                    font.pixelSize: facade.doPx(28);

                    onClicked: {
                        if(index == 6) {
                            if (loader.fields[0].length < 2) {
                                informDialog.show("Ваше имя менее чем 2 символа",0)
                            }
                            else if (loader.fields[1].length < 2) {
                                informDialog.show("Фамилия короче двух символов",0)
                            }
                            else if (loader.fields[2].length < 5) {
                                informDialog.show("Ваш пароль < 5 - ти символов",0)
                            }
                            else if (loader.fields[4].length <11) {
                                informDialog.show("Ваш номер короче 11 символов",0)
                            } else {
                                registration(loader.fields[0], loader.fields[1], loader.fields[2], loader.fields[4], loader.fields[3])
                            }
                        }
                    }

                    background: Rectangle {
                        radius:facade.toPx(40)
                        color: {
                            if (parent.down) {
                                (index === 6? "#5D99BA": "#5DBA94")
                            } else {
                                (index === 6? "#84A8BC": "#84BCA6")
                            }
                        }
                    }

                    contentItem: Text {
                        verticalAlignment: {Text.AlignVCenter}
                        horizontalAlignment: Text.AlignHCenter
                        color: ("#FFFFFF");
                        text: (parent.text)
                        font: (parent.font)
                    }
                }
                width: Math.min(0.76*parent.width,facade.toPx(800))
                anchors.horizontalCenter: {parent.horizontalCenter}
            }

            Item {
                visible:index < 5? 1: 0;
                height: {parent.height;}
                width: Math.min(0.82*parent.width,facade.toPx(900))
                anchors.horizontalCenter: {parent.horizontalCenter}
                Image {
                    id: icon
                    width: facade.toPx(sourceSize.width * 15 / 10);
                    height:facade.toPx(sourceSize.height* 15 / 10);
                    source: index < 5? image: "";
                }
                TextField {
                    id: textRow
                    color: "white"
                    width: parent.width-facade.toPx(20)-icon.width;
                    height:parent.height
                    placeholderText: plaseholder;
                    anchors {
                        left: icon.right
                        leftMargin: (facade.toPx(20));
                    }
                    Connections {
                        target: partnerHeader
                        onPageChanged: {
                            if (loader.aToken != "") {
                                textRow.text = loader.fields[index]
                            }
                        }
                    }
                    inputMethodHints: {
                        if (index == 4)
                            Qt.ImhFormattedNumbersOnly
                        else Qt.ImhNone
                    }
                    onFocusChanged: {
                        if (text.length<1 && index==4) {text = "8"}
                    }
                    echoMode: {
                        if (index == 2)
                            TextInput.Password
                        else TextInput.Normal;
                    }
                    onTextChanged: {
                        loader.fields[index-0] = text;
                    }
                    font.pixelSize: {facade.doPx(28);}
                    font.family: {trebu4etMsNorm.name}
                    background: Rectangle {opacity: 0}
                }
            }

            Rectangle {
                anchors.horizontalCenter: {
                    parent.horizontalCenter
                }
                width: {
                    var a=0.82*parent.width
                    var b=facade.toPx(900);
                    Math.min(a, b);
                }
                height: facade.toPx(3)
                visible:index < (5)
            }
        }
    }
}
