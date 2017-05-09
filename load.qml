import QtQuick 2.7
import QtQuick.Controls 2.0
import"P2PStyle"as P2PStyle

ApplicationWindow {
    width: 500
    height: 900
    visible: true
    title: qsTr("P2P Chat")

    Timer {
        id: backTimer
        interval: 500
        onTriggered: loader.back()
    }

    function strartPage() {privated.visitedPageList.push(loader.source="qrc:/start.qml")}

    function listenBack(event) {
        loader.focus = true
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape || event === true) {
            event.accepted= true
            if (loader.dialog==true) {
            loader.dialog = !loader.dialog;
            } else if(loader.webvew) {
            loader.webvew = !loader.webvew;
            } else backTimer.restart()
        }
    }

    QtObject {
        id: facade
        function toPx(dp) {
            return dp*(loader.dpi/160)
        }
        function doPx(dp) {
            return dp*(loader.dpi/160)*1.5;
        }
    }

    Loader {
        id: loader;
        focus: true
        objectName: "loader"
        anchors.fill: parent
        property real dpi: 0
        property bool avatar
        property bool dialog
        property bool webvew

        property string tel
        property string login;
        property string famil;

        property var chats:[];

        Keys.onReleased: listenBack(event);

        Component.onCompleted: strartPage()

        QtObject {
            id: privated
            property var visitedPageList:[]
        }

        property variant fields: ["", "", "", "", ""];

        function goTo(page) {
            privated.visitedPageList.push(source=page)
        }
        function back() {
            if (privated.visitedPageList.length > 0) {
                if (source!= "qrc:/start.qml")
                {
                    privated.visitedPageList.pop()
                    source = privated.visitedPageList[privated.visitedPageList.length - 1]
                }
            }
            else
                strartPage();
        }
    }

    Loader {
        id: imagePicker
        source: event_handler.currentOSys()==0?"AndImagePicker.qml": "IOsImagesPicker.qml"

        onLoaded:item.onChange=function(url) {
            //TODO: set property new image url
        }
    }

    P2PStyle.HeaderSplash {
        visible:loader.source!="qrc:/start.qml"
        id: partnerHeader;
    }

    FontLoader {
        source: "qrc:/fonts/TrebuchetMSn.ttf";
        id: trebu4etMsNorm
    }

    P2PStyle.BusyIndicator {id: busyIndicator}

    P2PStyle.Avatardialogs {id: avatardialogs}

    P2PStyle.WindsDialogs {id: windsDialogs}

    P2PStyle.Menusdrawer {id: menuDrawer}
}
