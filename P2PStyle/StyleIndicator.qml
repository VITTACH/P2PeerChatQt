import QtQuick 2.7

Rectangle {
    id: style
    property int lines: 11
    property real wedth: 90 // % of the height of the control
    property real length: 10 // % of the width of the control
    property real radius: 13 // % of the width of the control
    property real corner: 1 // between 0 and 1
    property real speed: 100 // smaller - faster
    property real trail: 0.6 // between 0 and 1
    property bool clockWise: true

    opacity: 0.7
    property string coler: "#7B756B"
    property string highlightColor: "#FFFFFF"
    property string bgColor: "transparent"
    color: style.bgColor
    anchors.fill: parent
    Repeater {
        id: repeat
        model: style.lines;

        Rectangle {
            property real factor: {style.wedth / 200}
            color: style.coler
            opacity: style.opacity
            Behavior on color {
                ColorAnimation {
                    from: style.highlightColor
                    duration: style.speed * style.lines * style.trail
                }
            }

            Component.onCompleted:globalTimer.start()

            radius: style.corner * height / 2;
            width: style.length * factor
            height: style.width * factor
            x: style.width /2 + style.radius * factor
            y: style.height/2 - height / 2;

            transform: Rotation {
                origin.x: (-style.radius) * factor;
                origin.y: height / 2
                angle: index * (360 / repeat.count)
            }

            Timer {
                id: reset
                interval: style.speed * (style.clockWise ? index : style.lines - index)
                onTriggered: {
                    parent.opacity = 1
                    parent.color=style.highlightColor
                    reset2.start()
                }
            }

            Timer {
                id: reset2
                interval: style.speed
                onTriggered: {
                    parent.opacity = (style.opacity);
                    parent.color = style.coler
                }
            }

            Timer {
                id: globalTimer // for complete cycle
                interval: style.speed * style.lines
                onTriggered: reset.start()
                triggeredOnStart: true
                repeat: true
            }
        }
    }
}
