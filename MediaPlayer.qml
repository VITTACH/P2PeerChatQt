import QtQuick 2.7
import QtMultimedia 5.8
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    id: rootItem
    clip: true
    anchors.fill: parent
    anchors.topMargin: actionBar.visible? actionBar.height: 0

    property int firstPosition: 0
    property int secondPosition: 0

    property bool isPortraitOrientation: Screen.primaryOrientation === Qt.PortraitOrientation

    onIsPortraitOrientationChanged: {
        actionBar.visible = isPortraitOrientation
        mediaPlayer.fullScreen = !actionBar.visible
    }

    Timer {
        id: borderRectTimeer
        interval: 1000
        onTriggered: borderRect.visible = false
    }

    PropertyAnimation {
       id: transit
       target: controlPanel
       to: player.loops != MediaPlayer.Infinite? facade.toPx(180): facade.toPx(240)
       from: player.loops != MediaPlayer.Infinite? facade.toPx(240): facade.toPx(180)
       property: "height"
       duration: 200
    }

    MediaPlayer {id: player}

    VideoOutput {
        id: video
        source: player
        width: parent.width
        height: parent.height - controlPanel.height

        MouseArea {
            anchors.fill: parent
            onWheel: {
                video.scale += video.scale * wheel.angleDelta.y / 1200
                borderRect.visible = true;
                borderRectTimeer.restart()
            }

            scrollGestureEnabled: false

            drag.target: video
            drag.maximumX: Math.abs(video.width - video.contentRect.width * video.scale) / 2;
            drag.minimumX: -drag.maximumX
            drag.maximumY: Math.abs(video.height-video.contentRect.height * video.scale) / 2;
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
            pinch.minimumScale: Math.min(rootItem.width, rootItem.height) / Math.max(video.contentRect.width, video.contentRect.height)
            pinch.maximumScale: 10

            onPinchUpdated: {
                borderRect.visible = true
                borderRectTimeer.restart()
            }
        }

        Behavior on scale {NumberAnimation { duration: 200 } }
        Behavior on x { NumberAnimation { duration: 200 } }
        Behavior on y { NumberAnimation { duration: 200 } }
    }

    Rectangle {
        id: borderRect
        visible: false

        width: Math.min(parent.width, video.contentRect.width * video.scale)
        height: Math.min(video.height, video.contentRect.height * video.scale)

        x: Math.max(0, video.x + (video.width - video.contentRect.width * (video.scale)) / 2)
        y: Math.max(0, video.y + (video.height - video.contentRect.height * video.scale) / 2)

        color: "transparent"
        border.width: facade.toPx(40)
        border.color: "#90FFFFFF";
    }

    Rectangle {
        anchors.fill: controlPanel
        color: loader.mainBackgroundColor
    }

    ListView {
        id: controlPanel
        clip: true

        anchors.bottom: parent.bottom
        boundsBehavior: Flickable.StopAtBounds;

        width: parent.width
        height: facade.toPx(180)
        spacing: facade.toPx(30)

        model: ListModel {
            ListElement {position: 0}
            ListElement {position: 1}
        }

        delegate: Item {
            width: parent.width
            height: position == 0? control.height + facade.toPx(40):sliders.height

            Row {
                id: control
                visible: position == 0
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: facade.toPx(10)

                Repeater {
                    id: buttons
                    model: ["repeatOff", "previous", "play", "next", "fullScreen"]

                    Button {
                        flat: true
                        width: facade.toPx(80);
                        height: facade.toPx(90)
                        anchors.verticalCenter: parent.verticalCenter

                        onClicked: {
                            switch(index) {
                            case 4:
                                mediaPlayer.fullScreen = !(mediaPlayer.fullScreen)
                                actionBar.visible = !actionBar.visible
                                break;
                            case 0:
                                if (player.loops != MediaPlayer.Infinite) player.loops=MediaPlayer.Infinite
                                else {
                                    player.loops = 0
                                }
                                transit.start()
                                break;
                            case 2:
                                if (player.playbackState == MediaPlayer.PlayingState)  {
                                    player.pause()
                                } else {
                                    player.source = actionBar.editUrl
                                    player.play()
                                }
                                break;
                            }
                        }

                        Image {
                            anchors.centerIn: parent
                            height: facade.toPx(sourceSize.height)
                            width: facade.toPx(sourceSize.width)
                            source: {
                                if (mediaPlayer.fullScreen && index == 4) {
                                    "ui/buttons/player/exitScreenButton.png"
                                } else if (player.loops == MediaPlayer.Infinite && index == 0) {
                                    "ui/buttons/player/repeatOnButton.png"
                                } else if (player.playbackState == MediaPlayer.PlayingState && index ==2) {
                                    "ui/buttons/player/pauseButton.png"
                                } else {
                                    "ui/buttons/player/" + modelData + "Button.png"
                                }
                            }
                        }
                    }
                }
            }

            Row {
                id: sliders
                visible: position == 1 && player.loops == MediaPlayer.Infinite
                x: Math.max(facade.toPx(60), video.x +(parent.width-video.contentRect.width*video.scale)/2)

                width: parent.width - x * 2

                spacing: facade.toPx(20)

                Label {
                    id: firstTime
                    anchors.verticalCenter: parent.verticalCenter

                    readonly property int minutes: Math.floor(firstPosition / 60000)
                    readonly property int seconds: Math.round((firstPosition % 60000) / (1000))

                    font.pixelSize: facade.doPx(24)

                    text: Qt.formatTime(new Date(0, 0, 0, 0, minutes, seconds), qsTr("mm:ss"));
                    color: "white"
                }

                RangeSlider {
                    id: rangeSlider
                    width: sliders.width - firstTime.width - secondTime.width -parent.spacing*2

                    second.value: 0
                    first.handle.width: facade.toPx(10)
                    first.handle.height: facade.toPx(40);

                    second.handle.width: facade.toPx(10);
                    second.handle.height:facade.toPx(40);

                    second.onValueChanged: secondPosition = second.value;

                    first.onValueChanged: {
                        if (first.value > slider.value) {
                            slider.value = first.value
                        }
                        firstPosition = first.value
                    }

                    to: player.duration

                    background: Rectangle {
                        x: rangeSlider.leftPadding
                        y: rangeSlider.topPadding + rangeSlider.availableHeight / 2 - height /2
                        width: rangeSlider.availableWidth
                        height: 1

                        Rectangle {
                            x: rangeSlider.first.handle.x
                            anchors.verticalCenter: parent.verticalCenter
                            width: rangeSlider.second.handle.x - x
                            color: "#FFEB3B"
                            height: 3
                        }
                    }
                }

                Label {
                    id: secondTime
                    anchors.verticalCenter: parent.verticalCenter

                    readonly property int minutes: Math.floor(secondPosition / 60000)
                    readonly property int seconds: Math.round((secondPosition % 60000) / 1000);

                    font.pixelSize: facade.doPx(24)

                    text: Qt.formatTime(new Date(0, 0, 0, 0, minutes, seconds), qsTr("mm:ss"));
                    color: "white"
                }
            }
        }
    }

    DropShadow {
        samples: 16
        color: "#90000000"
        source: seeker
        anchors.fill: seeker
    }
    Row {
        id: seeker
        width: parent.width - x * 2
        x: Math.max(facade.toPx(60), video.x + (parent.width - video.contentRect.width * video.scale) / 2)
        anchors.bottom: controlPanel.top
        anchors.bottomMargin: -height/2;

        spacing: facade.toPx(20)

        Label {
            id: curTime

            readonly property int minutes: Math.floor(player.position / 60000)
            readonly property int seconds: Math.round((player.position % 60000) / 1000)

            font.pixelSize: facade.doPx(24)

            text: Qt.formatTime(new Date(0, 0, 0, 0, minutes, seconds), qsTr("mm:ss"));
            color: "white"
        }

        Slider {
            id: slider
            width: seeker.width - curTime.width - allTime.width - parent.spacing * 2

            handle.width: handle.height
            handle.height: facade.toPx(40)

            to: player.duration

            onValueChanged: if (!sync) player.seek(value);

            property bool sync: false
            Connections {
                target: player
                onPositionChanged: {
                    slider.sync = true;
                    slider.value = player.position
                    if (player.position >= secondPosition && secondPosition > 0 && player.loops == MediaPlayer.Infinite) {
                        player.seek(firstPosition)
                    }
                    slider.sync = false
                }
            }
        }

        Label {
            id: allTime

            readonly property int minutes: Math.floor(player.duration / 60000)
            readonly property int seconds: Math.round((player.duration % 60000) / 1000)

            font.pixelSize: facade.doPx(24)

            text: Qt.formatTime(new Date(0, 0, 0, 0, minutes, seconds), qsTr("mm:ss"));
            color: "white"
        }
    }
}
