import QtQuick 2.7
import QtQuick.Controls 2.0
import"P2PStyle"as P2PStyle

Item {
    id: rootChat
    TextArea {
        id: buferText;
        visible: false
        wrapMode:TextEdit.Wrap
        width: 3*rootChat.width/4
        font.pixelSize: facade.doPx(26)
        font.family:trebu4etMsNorm.name
    }

    property bool input: false

    Connections {
        target: event_handler;
        onReciving: appendMessage(response, 1)
    }

    /*
    P2PStyle.Background {
        anchors.fill:parent
        Component.onCompleted: {
            setColors([[255,235,93], [252, 175, 39]], 100)
        }
    }
    */

    function appendMessage(newmessage, flag) {
        chatModel.append({
            someText: newmessage,
            myheight: buferText.contentHeight,
            mySpacing:(flag==0)==true? 2: facade.toPx(20),
            textColor:(flag==0)==true?"#960f133d":"black",
            backgroundColor:(flag==0)?"#ECECEC":"#DBEEFC",
            HorizonPosition: facade.toPx(30)+flag*(parent.width/4-facade.toPx(60)),
            image: flag === 0? "ui/chat/leFtMessage.png": "ui/chat/rightMessag.png"
        });
        if (flag == 0) event_handler.sendMsgs(newmessage);
    }

    Component.onCompleted: partnerHeader.text = "Комната";

    ListView {
        id: chatScreenList

        width:parent.width
        anchors {
            top:parent.top
            bottom: flickableTextArea.top;
            topMargin:partnerHeader.height+facade.toPx(10)
        }

        model: ListModel {
            id: chatModel;
        }
        delegate: Item {
            height: (facade.toPx(65) - myheight>= 0)?
                     mySpacing + facade.toPx(65):
                     mySpacing + facade.doPx(26)+ myheight
            Image {
                source: image
                width: facade.toPx(sourceSize.width * 1.2)
                height:facade.toPx(sourceSize.width * 1.2)
                y: parentText.y + parentText.height-sourceSize.height
                x: (parentText.x == facade.toPx(30))?
                        parentText.x - width/2:
                            parentText.x + parentText.width - width/2
            }
            TextArea {
                id: parentText
                text: someText
                readOnly: true

                background: Rectangle {
                    color: backgroundColor
                    radius:facade.toPx(25)
                }

                wrapMode: {TextEdit.Wrap;}
                width: 3*rootChat.width/4;
                height: (facade.toPx(65)- myheight >= 0)?
                         facade.toPx(65): myheight + facade.doPx(26);

                font {
                family:trebu4etMsNorm.name
                pixelSize: facade.doPx(26)
                }

                verticalAlignment:Text.AlignVCenter
                color: textColor;
                x:HorizonPosition
            }
        }
    }

    Rectangle {
        anchors {
            leftMargin: 0.02*parent.width;
            rightMargin:0.02*parent.width;
            top: flickableTextArea.top
            bottom: parent.bottom
            right: parent.right;
            left: parent.left;
        }
        radius:facade.toPx(25)
    }

    Flickable {
        id: flickableTextArea;

        anchors {
            left: parent.left;
            rightMargin: 0.03*parent.width+chatScreenPostButton.width
            bottomMargin: input?rootChat.height*0.45:facade.toPx(25);
            leftMargin: 0.02*parent.width;
            right: (parent.right)
            bottom:parent.bottom;
        }

        height: (screenTextFieldPost.lineCount < 5)? facade.toPx(70)+
                (screenTextFieldPost.lineCount - 1)* facade.doPx(43):
                 facade.toPx(70)+4*facade.doPx(43)

        flickableDirection:Flickable.VerticalFlick

        TextArea.flickable:TextArea
        {
            verticalAlignment: {Text.AlignVCenter}
            placeholderText: "Написать...";
            onActiveFocusChanged:input=true
            font {
                pixelSize: facade.doPx(26);
                family: trebu4etMsNorm.name
            }
            id: screenTextFieldPost
            wrapMode: TextEdit.Wrap
            background: Rectangle {
            radius: facade.toPx(25)
            border.color: "#C8C8C8"
            border.width: 2
            }
        }
    }

    Button {
        width: buttonImage.width + facade.toPx(10);
        height:buttonImage.height;
        contentItem: Text {
            elide: Text.ElideRight
            color:parent.down? "#0f133d": "#7680B1"
            verticalAlignment: {Text.AlignVCenter}
            horizontalAlignment:Text.AlignHCenter;
        }
        Image {
        id: buttonImage
        source:"ui/buttons/sendButton.png"
        height:facade.toPx(sourceSize.height* 1.5);
        width: facade.toPx(sourceSize.width * 1.5);
        }
        onClicked: {
        if (screenTextFieldPost.text.length >= 1) {
            buferText.text=screenTextFieldPost.text
            appendMessage(buferText.text,0.0);
            chatScreenList.positionViewAtEnd()
            screenTextFieldPost.text = "";
        }
        input = false
        }
        background: Rectangle {opacity: 0}
        anchors {
            rightMargin: 0.02*parent.width
            right: parent.right
        }
        id:chatScreenPostButton
        y: flickableTextArea.y;
    }
}
