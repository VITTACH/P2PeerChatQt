import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.3

Row {
    id: header
    clip: true
    width: parent.width

    property string text: ""
    property string photo: ""
    property string status: ""
    property string editUrl: ""

    property int page: -1
    property int payload: 0

    function addPage(pageName) {pagesModel.append({target: pageName});}

    Column {
        id: column
        width: parent.width

        Rectangle {
            width: parent.width
            height: facade.toPx(130)
            color: loader.headBackgroundColor

            Button {
                id: button
                x: facade.toPx(30)
                width: facade.toPx(100)
                height: width
                anchors.verticalCenter: parent.verticalCenter

                background: Image {
                    source: "/ui/buttons/actionBar/" + (payload == 1 || loader.webview? "back": (payload < 0? "dots": "menu")) + "Button.png"
                    width: facade.toPx(sourceSize.width)
                    height: facade.toPx(sourceSize.height)
                    anchors.centerIn: {parent}
                }

                visible: payload!=0 || loader.isLogin || loader.webview

                onClicked: {
                    if (payload > 0) payload--
                    else if (loader.webview == true) {
                        loader.webview = false
                        header.text =""
                        if (loader.isLogin == false) {
                            loader.back()
                        }
                    } else if (loader.chatOpen) {
                        chatMenuList.xPosition = (header.width - chatMenuList.w - facade.toPx(30))
                        chatMenuList.yPosition = (facade.toPx(20))
                        loader.focus = loader.context = true;
                    } else loader.drawOpen = true
                }
            }

            Row {
                spacing: facade.toPx(30)

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: loader.isLogin? button.right: undefined;
                    leftMargin: loader.isLogin? button.x: 0
                    horizontalCenter: loader.isLogin == true ? undefined : parent.horizontalCenter
                }

                Item {
                    id: bug
                    height: facade.toPx(90);
                    width: visible? height:0
                    visible: {payload < 0 && (header.phot !== "")}
                    anchors.verticalCenter: parent.verticalCenter;

                    Image {
                        source: photo
                        anchors.fill: parent
                        anchors.margins: {iamgeBorder.radius/3.50}
                    }

                    Rectangle {
                        id: iamgeBorder
                        anchors.fill: parent
                        radius: facade.toPx(15)
                        border.width: facade.toPx(5)
                        border.color: {loader.mainMenuBorderColor}
                        color: "transparent"
                    }
                }

                Column {
                    visible: page != 0
                    spacing: facade.toPx(10)

                    Text {
                        width: Math.min((header.width - bug.width-facade.toPx(160)),implicitWidth)
                        color: "white"

                        font.family: trebu4etMsNorm.name;
                        font.pixelSize: loader.isLogin == true ? facade.doPx(26) : facade.doPx(30)
                        text: header.text.replace("\n", "")
                        elide: Text.ElideRight
                    }

                    Text {
                        font.family: trebu4etMsNorm.name;
                        font.bold: true
                        font.pixelSize: facade.doPx(18)
                        visible: loader.isLogin && !loader.webview
                        color: text == "Online"?"white":"darkgrey"
                        text: header.status.replace("\n", "")
                    }
                }

                Flickable {
                    visible: page == 0
                    width: header.width - bug.width - 2 * parent.spacing - button.x - button.width
                    height: facade.toPx(80)

                    flickableDirection: Flickable.HorizontalFlick;
                    TextArea.flickable: TextArea {
                        font.pixelSize: facade.doPx(20)
                        placeholderText: "Url"
                        onTextChanged: {
                            if (text.endsWith("\n") > 0) {
                                text = text.replace("\n", "")
                                cursorPosition = text.length;
                                editUrl = text
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: facade.toPx(80)
            color: loader.headBackgroundColor
            visible: page >= 0 && !loader.webview;

            ListView {
                anchors.fill: parent
                orientation: Qt.Horizontal;

                model: ListModel {id: pagesModel;}

                delegate: Button {
                    flat: true
                    height: parent.height
                    width: facade.toPx(200)

                    contentItem: Text {
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter

                        font.weight: Font.DemiBold
                        font.family: trebu4etMsNorm.name
                        font.pixelSize: facade.doPx(22);

                        text: target
                        color: "white"
                    }

                    onClicked: page = index

                    Component.onCompleted: {
                        background.color = "transparent"
                    }

                    Rectangle {
                        anchors.bottom: {parent.bottom;}
                        visible: index == page
                        height: facade.toPx(3)
                        width: parent.width
                    }
                }
            }
        }
    }
}
