import QtQuick 2.7
import QtQuick.Controls 2.0
import"P2PStyle"as P2PStyle

Item {
    Component.onCompleted: partnerHeader.text = qsTr("Вход")

    P2PStyle.Background {
        anchors.fill:parent
        Component.onCompleted: {
            setColors([[15, 191, 255], [50, 110, 183]], 100)
        }
    }

    function login(phone,password) {
        var request = new XMLHttpRequest(), response;
        request.open('POST',"http://hoppernet.hol.es/default.php")
        request.onreadystatechange = function() {
            if (request.readyState == XMLHttpRequest.DONE) {
                if (request.status && request.status==200) {
                    if (request.responseText == "") response = -1;
                    else if (request.responseText != "no") {
                        response = 1;
                        var obj = JSON.parse(request.responseText)
                        loader.famil = obj.family
                        loader.login = obj.login;
                        loader.tel = obj.name
                    }
                    else
                        response = 0;
                switch(response)
                {
                case 1:
                    loader.goTo("qrc:/chat.qml");
                    event_handler.sendMsgs(phone)
                    break;
                case 0:
                    windsDialogs.text = "Вы не зарегистрированы!";
                    loader.dialog = true
                    break;
                case -1:
                    windsDialogs.text = "Нет доступа к интернету";
                    loader.dialog = true
                    break;
                }
                    busyIndicator.visible =false;
                }
            }
        }
        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
        request.send("phone=" + phone + "&pass=" + password)
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
                plaseholder: "Еще нет аккаунта?";
            }
        }

        displayMarginBeginning: {parent.height*0.5 - 2*facade.toPx(100);}

        delegate: Column {
            width: parent.width
            height:{(index==2)==true? facade.toPx(110): facade.toPx(89);}
            Button {
                text: plaseholder
                height:facade.toPx(100)
                visible:index == 2? 1:0
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 0.09*parent.width
                    rightMargin:0.09*parent.width
                }

                font.pixelSize: {facade.doPx(24)}
                font.family: trebu4etMsNorm.name;

                onClicked: {
                    if(loader.fields[0].length <11) {
                        windsDialogs.text = "Укажите корректный телефон!"
                        loader.dialog = true
                    }
                    else
                    if(loader.fields[1].length < 5) {
                        windsDialogs.text = "Пароль короче 5-ти символов"
                        loader.dialog = true
                    }
                    else {
                        var telephone = loader.fields[0];
                        var passwords = loader.fields[1];
                        busyIndicator.visible = true;
                        login(telephone, passwords)
                    }
                }
                background: Rectangle {
                    color:parent.down?"#FFC129":"#FFCC40"
                    radius:facade.toPx(40)
                }
                contentItem: Text {
                    color:parent.down?"black":"#960f133d"
                    horizontalAlignment:Text.AlignHCenter
                    verticalAlignment : Text.AlignVCenter
                    opacity: enabled?1:0.3
                    elide: Text.ElideRight
                    text: parent.text
                    font: parent.font
                }
            }

            Item {
                visible:index<2? 1:0;
                height: facade.toPx(88)
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 0.09 * parent.width
                    rightMargin:0.09 * parent.width
                }
                TextField {
                    color:"white"
                    height:facade.toPx(88)
                    placeholderText: {plaseholder;}
                    anchors {
                        left: parent.left;
                        right:parent.right
                        rightMargin:0.09*parent.width
                        leftMargin: facade.toPx(80)
                    }

                    onFocusChanged: if(text.length==0&&index==0) text="8"

                    echoMode:index==1?TextInput.Password:TextInput.Normal

                    background:Rectangle {opacity: 0}
                    font.family: trebu4etMsNorm.name;
                    font.pixelSize: (facade.doPx(28))

                    onTextChanged: loader.fields[index] = text;

                    inputMethodHints:Qt.ImhFormattedNumbersOnly
                }
                Image {
                    id: icon
                    source: image
                    width: facade.toPx(sourceSize.width * 1.5);
                    height:facade.toPx(sourceSize.height* 1.5);
                }
            }

            Button {
                background: Rectangle {opacity:0}

                font.pixelSize: {facade.doPx(22)}
                font.family: trebu4etMsNorm.name;

                onClicked: loader.goTo("qrc:/regin.qml");

                visible: index==3?1:0

                contentItem: Text {
                    color:parent.down?"#960f133d":"white"
                    horizontalAlignment:Text.AlignHCenter
                    verticalAlignment : Text.AlignVCenter
                    opacity: enabled?1:0.3
                    elide: Text.ElideRight
                    text: parent.text;
                    font: parent.font;
                    padding: -8;
                }

                anchors {
                    left: parent.left;
                    right:parent.right
                    leftMargin: 0.09 * parent.width
                    rightMargin:0.09 * parent.width
                }
                text:plaseholder
            }

            Rectangle {
                anchors {
                    leftMargin: 0.09 * parent.width
                    rightMargin:0.09 * parent.width
                    right:parent.right
                    left: parent.left;
                }
                visible: index<2? 1:0;
                color: "#FFFFFF"
                height: 1
            }
        }
    }
}
