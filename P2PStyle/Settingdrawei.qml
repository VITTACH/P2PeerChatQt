import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Drawer {
    id: drawed
    property int curIndex: -1

    function visible(state) {background.visible = state}

    height: (parent.height - menuDrawer.getMenuHeight())
    width: Math.min(facade.toPx(575), 0.75*parent.width)

    DropShadow {
        radius: 12
        samples: 20
        anchors {
            fill:background
        }
        verticalOffset:-12;
        visible: background.visible
        color: "#80000000";
        source: background;
    }
    Rectangle {
        visible: false
        id: background
        height: parent.height
        width: (parent.width + facade.toPx(40))
    }

    Connections {
        target: drawed;
        onPositionChanged: {
            if (loader.source != "qrc:/chat.qml" || menuDrawer.position < 1)
                position = 0
        }
    }
}
