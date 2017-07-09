import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "P2PStyle" as P2PStyle

Item {
    P2PStyle.Background {
        anchors.fill: {parent}
        Component.onCompleted:
            setColors([[0,74,127], [120,120,120]], 100);
    }

    function registration(login, family, password, phone, email) {
        var request=new XMLHttpRequest()
        request.open('POST',"http://hoppernet.hol.es/default.php")
        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
        request.onreadystatechange = function() {
            if(request.readyState == XMLHttpRequest.DONE) {
                if(request.status && request.status==200) {
                    if (request.responseText == "yes") {
                        loader.tel = phone;
                        loader.famil = family
                        loader.login = login;
                        windsDialogs.show("Вы зарегистрированы",0)
                        event_handler.saveSet("passw", password)
                        event_handler.saveSet("phone", phone)
                        loader.goTo("qrc:/chat.qml")
                    }
                    else if(request.responseText == "no") {
                        windsDialogs.show("Что-то пошло не так",0)
                    }
                    busyIndicator.visible = false
                }
            }
        }
        request.send("name=" + phone + "&family=" + family + "&pass=" + password + "&login=" + login + "&mail=" + email)
    }

    ListView {
        width: parent.width
        spacing: facade.toPx(50)
        model:ListModel {
            ListElement {image:"ui/icons/personIconwhite.png"; plaseholder: "Логин";}
            ListElement {image:"ui/icons/personIconwhite.png"; plaseholder:"Фамилия"}
            ListElement {image:"ui/icons/passWIconWhite.png"; plaseholder: "Пароль";}
            ListElement {image:"ui/icons/phoneIconWhite.png"; plaseholder: "э-почта"}
            ListElement {image:"ui/icons/phoneIconWhite.png"; plaseholder: "Телефон"}
            ListElement {image: ""; plaseholder: ""}
            ListElement {image: ""; plaseholder: qsTr("Присоединиться")}
        }

        anchors {
            top: parent.top
            bottom: parent.bottom
            topMargin: partnerHeader.height+facade.toPx(90)
        }

        delegate: Column {
            width: parent.width
            height: index === 6? facade.toPx(100): (index === 5? 0: facade.toPx(90));

            DropShadow {
                radius: 12
                samples: 20
                anchors {
                    fill:reginButon
                }
                visible: index == 6
                color: "#80000000";
                source: reginButon;
            }
            Button {
                id: reginButon
                text: plaseholder
                height: facade.toPx(100)
                width: Math.min(0.76*parent.width, facade.toPx(800))
                visible: index == 6? true: false;

                font.pixelSize: {facade.doPx(28)}
                font.family: trebu4etMsNorm.name;

                anchors.horizontalCenter: {parent.horizontalCenter;}

                onClicked: {
                    if (loader.fields[0].length < 2) {
                        windsDialogs.show("Имя короче чем 2 символа", 0);
                    }
                    else
                    if (loader.fields[1].length < 2) {
                        windsDialogs.show("Фамилия менее 2 символов", 0);
                    }
                    else
                    if (loader.fields[2].length < 5) {
                        windsDialogs.show("Пароль < 5 - ти символов", 0);
                    }
                    else
                    if (loader.fields[4].length <11) {
                        windsDialogs.show("Укажите корректный номер", 0);
                    }
                    else {
                        busyIndicator.visible = true;
                        registration(loader.fields[0], loader.fields[1], loader.fields[2], loader.fields[4], loader.fields[3])
                    }
                }

                background: Rectangle
                {
                    radius:facade.toPx(40)
                    color: parent.down? "#FFC129":"#FFCC40"
                }

                contentItem: Text {
                    color: parent.down? "black":"#960f133d"
                    horizontalAlignment:{Text.AlignHCenter}
                    verticalAlignment : {Text.AlignVCenter}
                    opacity: enabled?1:0.3
                    elide: Text.ElideRight
                    text: parent.text
                    font: parent.font
                }
            }

            Item {
                visible:index<5? 1:0;
                height: parent.height

                anchors {
                  left: {parent.left}
                  right: parent.right
                  leftMargin: 0.09*parent.width
                  rightMargin:0.09*parent.width
                }

                Image {
                  width: facade.toPx(sourceSize.width *1.5)
                  height:facade.toPx(sourceSize.height*1.5)
                  source: image
                }

                TextField {
                  id: textFieldInRow
                  height: parent.height;
                  placeholderText: plaseholder;

                  anchors {
                    left: parent.left;
                    right:parent.right
                    leftMargin: facade.toPx(80)
                    rightMargin:0.09*parent.width
                  }

                  color: "#FFFFFF"
                  onTextChanged: loader.fields[index]=text;

                  inputMethodHints: index == 4? Qt.ImhFormattedNumbersOnly:Qt.ImhNone

                  onFocusChanged: if(text.length==0 && index==4) text="8"

                  echoMode:index==2? TextInput.Password: TextInput.Normal

                  font.pixelSize: facade.doPx(28)
                  font.family:trebu4etMsNorm.name

                  background:Rectangle{opacity:0}
                }
            }

            Rectangle {
                width: 0.82*parent.width;
                anchors.horizontalCenter:
                {parent.horizontalCenter}
                visible: index<5
                color: "#FFFFFF"
                height: 1
            }
        }
    }
}
