import QtQuick 2.7
import "P2PStyle" as P2PStyle

Item {
    Timer {
        interval: 1
        running: true
        onTriggered: {
            zoomingmov.start()
            opacitymov.start()
        }
    }

    Timer {
        running: true
        interval:3000
        onTriggered: {
            loader.goTo("qrc:/loginanDregister.qml");
        }
    }

    P2PStyle.Background
    {
        anchors.fill: {parent}
        Component.onCompleted: setColors([[255,255,255], [255,255,255], [15,191,255], [120,120,120]],25)
    }

    PropertyAnimation {
        target: logo;
        property: {"opacity";}
        id: opacitymov;
        from: 0; to: 1;
        duration: 1900;
    }
    PropertyAnimation {
        target: logo;
        property: {("scale");}
        id: zoomingmov;
        from:0.8;to: 1;
        duration: 1000;
    }

    /* if i will want use background image
    Image {
        height:parent.width<parent.height? parent.height: ((width/sourceSize.width) * sourceSize.height)
        width: parent.width<parent.height? sourceSize.width*parent.height/sourceSize.height:parent.width
        y: (parent.height/ 2 - height/ 2);
        x: (parent.width / 2 - width / 2);
    }
    */

    Image {
        id: logo
        scale: 0.8
        opacity: 0
        source:("qrc:/ui/logos/logo.png");
        width: sourceSize.width/ 1.2*(parent.width < 600? parent.width: 600)/500
        height:sourceSize.height/1.2*(parent.width < 600? parent.width: 600)/500
        x: (parent.width / 2 - width / 2);
        y: (parent.height/ 2 - height/ 2);
    }
}
