import QtQuick 2.7
import QtQuick.Controls 2.0
import"P2PStyle"as P2PStyle

Item {
    Component.onCompleted: partnerHeader.text = "Регистрация"

    P2PStyle.Background {
        anchors.fill:parent
        Component.onCompleted: {
            setColors([[15, 191, 255], [50, 110, 183]], 100);
        }
    }

    function registration(login, family, password, phone, email) {
        var request=new XMLHttpRequest()
        request.open('POST',"http://hoppernet.hol.es/default.php")
        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
        request.onreadystatechange = function() {
            if(request.readyState == XMLHttpRequest.DONE) {
                if(request.status && request.status==200) {
                    if (request.responseText == "yes") {
                        loader.dialog=true;windsDialogs.text = "Вы зарегистрированы";
                        loader.goTo("qrc:/chat.qml")
                    }
                    else if(request.responseText == "no") {
                        loader.dialog=true;windsDialogs.text = "Что-то пошло не так";
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
        model:  ListModel {
                ListElement {
                    image: "ui/icons/personIconwhite.png"
                    plaseholder: "Имя";
                }
                ListElement {
                    image: "ui/icons/personIconwhite.png"
                    plaseholder: "Фамилия"
                }
                ListElement {
                    image: "ui/icons/passWIconWhite.png";
                    plaseholder: "Пароль";
                }
                ListElement {
                    image: "ui/icons/phoneIconWhite.png";
                    plaseholder: "э-почта"
                }
                ListElement {
                    image: "ui/icons/phoneIconWhite.png";
                    plaseholder: "Телефон"
                }
                ListElement {image: ""; plaseholder: "";}
                ListElement {
                    image: ""
                    plaseholder: "Зарегистрировать"
                }
            }
        anchors {
            top: parent.top
            bottom: parent.bottom
            topMargin: partnerHeader.height + facade.toPx(50)
        }
        delegate: Column {
            width: parent.width
            height: index==6?facade.toPx(100): (index==5? facade.toPx(0): facade.toPx(90))
            Button {
                text: plaseholder
                height: facade.toPx(100)
                visible: index == 6?1:0;

                font.pixelSize: facade.doPx(24);
                font.family: trebu4etMsNorm.name

                anchors {
                    left: parent.left;
                    right:parent.right
                    leftMargin: 0.12 * parent.width;
                    rightMargin:0.12 * parent.width;
                }

                onClicked: {
                    if (loader.fields[0].length < 2) {
                        windsDialogs.text = "Имя короче чем 2 символа"
                        loader.dialog = true;
                    }
                    else
                    if (loader.fields[1].length < 2) {
                        windsDialogs.text = "Фамилия менее 2 символов"
                        loader.dialog = true;
                    }
                    else
                    if (loader.fields[2].length < 5) {
                        windsDialogs.text = "Пароль короче 5-ти символов";
                        loader.dialog = true
                    }
                    else
                    if (loader.fields[4].length <11) {
                        windsDialogs.text = "Укажите корректный номер"
                        loader.dialog = true;
                    }
                    else {
                        busyIndicator.visible = true;
                        registration(loader.fields[0], loader.fields[1], loader.fields[2], loader.fields[4], loader.fields[3])
                    }
                }
            background: Rectangle {
                radius:facade.toPx(40)
                color:parent.down?"#FFC129":"#FFCC40"
                }
                contentItem: Text {
                color:parent.down?"black":"#960f133d"
                horizontalAlignment:Text.AlignHCenter
                verticalAlignment : Text.AlignVCenter
                opacity: enabled?1:0.3
                elide: Text.ElideRight
                text: parent.text;
                font: parent.font;
                }
            }

            /*
            Switch {
                leftPadding: 0
                height: facade.toPx(80)
                spacing:facade.toPx(15)
                visible:index == 5?1:0;

                font.pixelSize: {facade.doPx(30);}
                font.family: {trebu4etMsNorm.name}

                anchors {
                    left: parent.left
                    leftMargin: 0.09*parent.width;
                }
                onClicked: {
                    if(checked)
                        loader.fields[4] = "true";
                    else
                        loader.fields[4] = "false"
                }
                text: checked == true? "Да": "Нет"

                indicator: Rectangle {
                    radius:facade.toPx(30)
                    x: parent.leftPadding;
                    y: parent.height/2 - height/2;
                    implicitWidth:facade.toPx(120)
                    implicitHeight:facade.toPx(54)
                    color:parent.checked==true?"#760f133d":"#86FFFFFF"

                    Rectangle {
                        width: parent.parent.height/1.8
                        height:parent.parent.height/1.8
                        x: parent.parent.checked? parent.width-(width+(parent.height-height)/2):(parent.height-height)/2
                        color:parent.parent.down==true? "#2E2F57": (parent.parent.checked==true? "#FFFFFF": "#960f133d")
                        anchors.verticalCenter: parent.verticalCenter;
                        radius: width/2
                    }
                }
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    leftPadding: parent.indicator.width+parent.spacing
                    color:parent.down? "#BDB5B5": (parent.checked==true? "white": "white")
                    verticalAlignment: Text.AlignVCenter
                    opacity: (enabled == true)? 1.0: 0.3
                }
            }
            */

            Item {
                visible:index<5? 1:0;
                height: parent.height

                Image {
                source: image
                width: facade.toPx(sourceSize.width *1.5)
                height:facade.toPx(sourceSize.height*1.5)
                }

                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 0.09 * parent.width
                    rightMargin:0.09 * parent.width
                }
                TextField {
                    id: textFieldInRow
                    height: parent.height;
                    anchors {
                        left: parent.left;
                        right:parent.right
                        rightMargin: 0.09 * parent.width;
                        leftMargin: facade.toPx(80)
                    }
                    placeholderText: {plaseholder;}

                    onTextChanged: {
                        loader.fields[index] = text;
                    }

                    color: "#FFFFFF"
                    inputMethodHints: (index == 4)? Qt.ImhFormattedNumbersOnly: Qt.ImhNone

                    onFocusChanged: if(text.length==0 && index==4) text="8"

                    echoMode:index==2? TextInput.Password: TextInput.Normal

                    font.pixelSize: facade.doPx(28);
                    font.family: trebu4etMsNorm.name
                    background: Rectangle{opacity:0}
                }
            }

            Rectangle {
                anchors {
                    leftMargin: 0.09 * parent.width;
                    rightMargin:0.09 * parent.width;
                    right:parent.right
                    left: parent.left;
                }
                visible: index<5? 1:0;
                color: "#FFFFFF"
                height: 1
            }
        }
    }
}
