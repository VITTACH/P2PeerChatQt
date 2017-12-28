import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle

Item {
    function registration(login, family, password, phone, email) {
        var request=new XMLHttpRequest()
        request.open('POST',"http://hoppernet.hol.es/default.php")
        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (request.status && request.status == 200) {
                    if (request.responseText == "yes") {
                        loader.tel = phone;
                        loader.famil = family
                        loader.login = login;
                        informDialog.show("Вы зарегистрированы",0)
                        event_handler.saveSet("phone", (loader.tel))
                        event_handler.saveSet("passw", password)
                        var objectFrnd= JSON.parse(loader.frienList)
                        objectFrnd.push(phone)
                        loader.frienList= JSON.stringify(objectFrnd)
                        loader.addFriends()
                        loader.isLogin = true;
                        goTo("profile.qml")
                    } else if (request.responseText == "no") {
                        informDialog.show("Что-то пошло не так",0)
                    }
                    loadnrsMenu.visible= false
                }
            }
        }
        request.send("name=" + phone + "&family=" + family + "&pass=" + password + "&login= " +
                     login + "&mail=" + email);
    }

    ListView {
        width: parent.width
        spacing: facade.toPx(50)
        displayMarginBeginning:facade.toPx(100)
        model:ListModel {
            ListElement {image:"ui/icons/personIconwhite.png"; plaseholder: "Логин";}
            ListElement {image:"ui/icons/personIconwhite.png"; plaseholder:"Фамилия"}
            ListElement {image:"ui/icons/passWIconWhite.png"; plaseholder: "Ваш личный пароль"}
            ListElement {image:"ui/icons/phoneIconWhite.png"; plaseholder: "Электронная почта"}
            ListElement {image:"ui/icons/phoneIconWhite.png"; plaseholder: "Телефон"}
            ListElement {image: "-"; plaseholder: ""}
            ListElement {image: "_"; plaseholder: "Присоединиться"}
            ListElement {image: "_"; plaseholder: "Демо вход"}
        }

        anchors {
            top: parent.top
            bottom: parent.bottom
            topMargin: partnerHeader.height + facade.toPx(150)
        }

        delegate: Column {
            width: parent.width
            height: index == 7? facade.toPx(150): (image == "-"? 0: facade.toPx(90));

            Item {
                visible: image=="_"
                height: facade.toPx(100)

                DropShadow {
                    radius: 12
                    samples: 20
                    color: "#80000000";
                    source: reginButon;
                    anchors.fill: reginButon
                }
                Button {
                    id: reginButon
                    text: {plaseholder}
                    anchors.fill: parent;

                    font {
                        pixelSize: facade.doPx(28)
                        family:trebu4etMsNorm.name
                    }

                    onClicked: {
                        if (index == 6) {
                            if (loader.fields[0].length < 2) {
                                informDialog.show("Ваше имя менее чем 2 символа",0)
                            }
                            else
                            if (loader.fields[1].length < 2) {
                                informDialog.show("Фамилия короче двух символов",0)
                            }
                            else
                            if (loader.fields[2].length < 5) {
                                informDialog.show("Ваш пароль < 5 - ти символов",0)
                            }
                            else
                            if (loader.fields[4].length <11) {
                                informDialog.show("Ваш номер короче 11 символов",0)
                            }
                            else {
                                loadnrsMenu.visible = true
                                registration(loader.fields[0], loader.fields[1], loader.fields[2], loader.fields[4], loader.fields[3])
                            }
                        }
                    }

                    background: Rectangle {
                        radius:facade.toPx(40)
                        color: parent.down? (index === 6? "#3B569F": "#1494CC"): (index === 6? "#4F6CBD": "#16A8E7")
                    }

                    contentItem: Text {
                        verticalAlignment: Text.AlignVCenter;
                        horizontalAlignment: {(Text.AlignHCenter)}
                        color: ("#FFFFFF");
                        text: (parent.text)
                        font: (parent.font)
                    }
                }
                width:Math.min(0.76*parent.width,facade.toPx(800))
                anchors.horizontalCenter: parent.horizontalCenter;
            }

            Item {
                visible:index < 5? 1:0;
                height: {parent.height}
                width:Math.min(0.82*parent.width,facade.toPx(900))
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                Image {
                    id: icon
                    width: facade.toPx(sourceSize.width *1.5)
                    height:facade.toPx(sourceSize.height*1.5)
                    source: index < 5? image: "";
                }

                TextField {
                    id: textRow
                    color: "white"
                    height: parent.height
                    placeholderText: plaseholder;

                    anchors {
                        left: icon.right
                        leftMargin: (facade.toPx(20));
                    }
                    Connections {
                        target: partnerHeader
                        onPageChanged: {
                            if (loader.aToken != "") {
                            textRow.text=loader.fields[index]
                            }
                        }
                    }
                    inputMethodHints: {
                    if(index == 4) Qt.ImhFormattedNumbersOnly
                    else Qt.ImhNone
                    }
                    onFocusChanged: {
                        if(text.length==0 && index==4)
                            text="8";
                    }
                    echoMode: {
                        if (index == 2) {TextInput.Password;}
                        else TextInput.Normal
                    }
                    onTextChanged: loader.fields[index]=text;
                    font.pixelSize: {facade.doPx(28);}
                    font.family: {trebu4etMsNorm.name}
                    background: Rectangle {opacity: 0}
                }
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter;
                width:Math.min(0.82*parent.width,facade.toPx(900))
                visible:{index<5?true:false;}
                height: 3
            }
        }
    }
}
