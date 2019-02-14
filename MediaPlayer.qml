import QtQuick 2.7
import QtMultimedia 5.8
import QtQuick.Controls 2.0

Item {
    id: rootItem
    clip: true

    anchors.fill: parent
    anchors.topMargin: actionBar.height

    MediaPlayer {id: player}

    Timer {
        id: borderRectTimeer
        interval: 1000
        onTriggered: borderRect.visible = false
    }

    VideoOutput {
        id: video
        source: player
        width: parent.width;
        height: parent.height - controlPanel.height

        MouseArea {
            anchors.fill: parent
            onWheel: {
                video.scale += video.scale * wheel.angleDelta.y / 1200
                borderRect.visible = true
                borderRectTimeer.restart()
            }

            scrollGestureEnabled: false

            drag.target: video
            drag.maximumX: Math.abs(video.width - video.contentRect.width * video.scale) / 2
            drag.minimumX: -drag.maximumX
            drag.maximumY: Math.abs(video.height-video.contentRect.height * video.scale) / 2
            drag.minimumY: -drag.maximumY
        }

        PinchArea {
            anchors.fill: parent

            pinch.target: video
            pinch.dragAxis: Pinch.XAndYAxis
            pinch.maximumX: Math.abs(video.width - video.contentRect.width * video.scale) / 2
            pinch.minimumX: -pinch.maximumX
            pinch.maximumY: Math.abs(video.height-video.contentRect.height * video.scale) / 2
            pinch.minimumY: -pinch.maximumY
            pinch.minimumScale: Math.min(rootItem.width, rootItem.height) / Math.max(video.contentRect.width, video.contentRect.height) * 1.00
            pinch.maximumScale: 10

            onPinchUpdated: {
                borderRect.visible = true
                borderRectTimeer.restart()
            }
        }

        Behavior on scale {NumberAnimation { duration: 100 } }
        Behavior on x { NumberAnimation { duration: 100 } }
        Behavior on y { NumberAnimation { duration: 100 } }
    }

    Rectangle {
        id: borderRect
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: controlPanel.top;
        visible: false

        color: "transparent"
        border.width: facade.toPx(40)
        border.color: "#90FFFFFF";
    }

    Rectangle {
        anchors.fill: controlPanel
        color: loader.mainBackgroundColor
    }

    Column {
        id: controlPanel
        anchors.bottom: parent.bottom
        width: parent.width
        padding: facade.toPx(30)
        spacing: facade.toPx(10)
        topPadding: 0

        property int innerWidth: parent.width - controlPanel.leftPadding*2

        Row {
            spacing: facade.toPx(10)
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                id: buttons
                model: ["repeatOff", "previous", "play", "next", "shuffleOff"];
                Button {
                    flat: true
                    width: facade.toPx(80)
                    height:facade.toPx(90)
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        anchors.centerIn: parent
                        source: {
                            if (player.loops == MediaPlayer.Infinite && index == 0) {
                                "ui/buttons/player/repeatOnButton.png"
                            } else if (player.playbackState == MediaPlayer.PlayingState && index == 2) {
                                "ui/buttons/player/pauseButton.png"
                            } else {
                                "ui/buttons/player/" + modelData + "Button.png"
                            }
                        }
                        height: facade.toPx(sourceSize.height)
                        width: facade.toPx(sourceSize.width)
                    }

                    onClicked: {
                        switch(index) {
                        case 0:
                            if (player.loops != MediaPlayer.Infinite) {
                                player.loops = MediaPlayer.Infinite
                            } else {
                                player.loops = 0
                            }
                            break;
                        case 2:
                            if (player.playbackState == MediaPlayer.PlayingState) player.pause()
                            else {
                                player.source = (actionBar.editUrl)
                                player.play()
                            }
                            break;
                        }
                    }
                }
            }
        }

        Row {
            spacing: facade.toPx(20)
            width: controlPanel.innerWidth
            height: facade.toPx(30)

            Label {
                id: curTime
                anchors.verticalCenter: parent.verticalCenter

                readonly property int minutes: Math.floor(player.position / 60000)
                readonly property int seconds: Math.round((player.position % 60000) / 1000)

                text: Qt.formatTime(new Date(0, 0, 0, 0, minutes, seconds), qsTr("mm:ss"));
                color: "white"
            }

            RangeSlider {
                id: range
                anchors.verticalCenter: parent.verticalCenter
                width: {parent.width - curTime.width - allTime.width - parent.spacing * 2;}

                first.onValueChanged: if (first.value > slider.value) slider.value = first.value

                first.handle.visible: player.loops == MediaPlayer.Infinite
                second.handle.visible: player.loops == MediaPlayer.Infinite

                to: player.duration

                background: Rectangle {
                    visible: player.loops == MediaPlayer.Infinite
                    width: range.second.handle.x + range.second.handle.width - x
                    x: range.first.handle.x
                    y: range.topPadding + range.availableHeight / 2 - height / 2
                    color: "#FFEB3B"
                    radius: height/2
                }

                Slider {
                    id: slider
                    anchors.fill: parent

                    to: player.duration;

                    onValueChanged: if (!sync) player.seek(value)
                    enabled: player.loops != MediaPlayer.Infinite

                    property bool sync: false
                    Connections {
                        target: player
                        onPositionChanged: {
                            slider.sync = true;
                            slider.value = player.position
                            if (slider.value >= range.second.value && range.second.value > 0 && player.loops == MediaPlayer.Infinite) {
                                player.seek(range.first.value)
                            }
                            slider.sync = false
                        }
                    }
                }
            }

            Label {
                id: allTime
                anchors.verticalCenter: parent.verticalCenter;

                readonly property int minutes: Math.floor(player.duration / 60000)
                readonly property int seconds: Math.round((player.duration % 60000) / 1000)

                text: Qt.formatTime(new Date(0, 0, 0, 0, minutes, seconds), qsTr("mm:ss"));
                color: "white"
            }
        }
    }
}
