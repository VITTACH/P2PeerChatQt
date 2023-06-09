import QtQuick 2.7
import QtMultimedia 5.8
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    id: rootItem
    anchors.fill: parent
    anchors.topMargin: actionBar.height;
    clip: true

    //github.com/qt-labs/qt5-everywhere-demo/tree/master/QtDemo/qml/QtDemo/demos/shaders/shaders
    property var shaders: ["isolate", "billboard", "glow", "waves"]

    property int firstPosition: 0
    property int secondPosition: 0

    function formatTime(minutes, seconds, separator) {
        var min = minutes < 10 ? "0" + minutes : minutes;
        var sec = seconds < 10 ? "0" + seconds : seconds;
        return min + separator + sec
    }

    function loadShader(fileName) {
        var xhr = new XMLHttpRequest
        xhr.open("GET", "shaders/" + fileName + ".fsh")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                effect.fragmentShader = "precision mediump float;" + xhr.responseText
            }
        }
        xhr.send()
    }

    PropertyAnimation {
       id: panelAnimation
       target: controlPanel
       to: controlPanel.height == 0? (player.loops != MediaPlayer.Infinite? facade.toPx(160): facade.toPx(220)): 0
       from: controlPanel.height == 0? 0: (player.loops != MediaPlayer.Infinite? facade.toPx(160): facade.toPx(220))
       property: "height"
       duration: 200
    }

    PropertyAnimation {
       id: transit
       target: controlPanel
       to: player.loops != MediaPlayer.Infinite? facade.toPx(160): facade.toPx(220)
       from: player.loops != MediaPlayer.Infinite? facade.toPx(220): facade.toPx(160)
       property: "height"
       duration: 200
    }

    Timer {
        id: borderRectTimeer
        interval: 1000
        onTriggered: borderRect.visible =false
    }

    Timer {
        id: controlShowTimer
        interval: 2000
        onTriggered: panelAnimation.start()
    }

    // Camera {id: camera}

    MediaPlayer {id: player}

    VideoOutput {
        id: video
        source: player

        Behavior on scale {NumberAnimation{duration:200}}
        Behavior on x {NumberAnimation {duration:200}}
        Behavior on y {NumberAnimation {duration:200}}

        width: parent.width
        height: {parent.height - controlPanel.height;}
    }

    PinchArea {
        anchors.top: parent.top
        anchors.bottom: controlPanel.top
        width: parent.width

        pinch.target: {video}
        pinch.minimumScale: Math.min(rootItem.width, rootItem.height) / Math.max(video.contentRect.width, video.contentRect.height)
        pinch.maximumScale: 5

        onPinchUpdated: {
            borderRect.visible = true;
            borderRectTimeer.restart()
        }

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true;

            onWheel: {
                video.scale += video.scale * wheel.angleDelta.y / 1200
                if (video.scale < 0.5) video.scale=0.5
                borderRect.visible = true;
                borderRectTimeer.restart()
            }

            onClicked: if (controlPanel.height == 0) {
                mouse.accepted = false
                panelAnimation.start()
                controlShowTimer.restart()
            }
        }
    }

    ShaderEffect {
        id: effect
        anchors.fill: video
        scale: video.scale

        property variant source: ShaderEffectSource {sourceItem:video; hideSource:true}

        // biilboard
        property real grid: 4.0
        property real dividerValue: 1
        property real targetWidth: video.width
        property real targetHeight: video.height

        property real step_x: 0.0015625
        property real step_y: targetHeight? (step_x * targetWidth / targetHeight): 0.0;

        // shockwave
        property real granularity: 0.5 * 20
        property real weight: 0.5

        property real centerX
        property real centerY
        property real time

        SequentialAnimation {
            running: true
            loops: Animation.Infinite
            ScriptAction {
                script: {
                    effect.centerX = Math.random()
                    effect.centerY = Math.random()
                }
            }
            NumberAnimation {
                target: effect
                property: "time"
                from: 0
                to: 1
                duration: 1000
            }
        }

        // isolate
        property real windowWidth: 0.5 * 60
        property real targetHue: 0.5 * 360
    }

    Rectangle {
        id: borderRect
        visible: false

        width: Math.min(rootItem.width, video.width * video.scale)
        height: parent.height - controlPanel.height

        x: Math.max(0, video.x + (rootItem.width - video.width * video.scale) / 2)

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
        height: facade.toPx(160)
        spacing: facade.toPx(10)

        model: ListModel {
            ListElement {position: 0}
            ListElement {position: 1}
        }

        delegate: Item {
            width: parent.width
            height: {position == 0? (control.height + facade.toPx(40)): sliders.height}

            Row {
                id: control
                anchors.bottom: parent.bottom;
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: facade.toPx(10)
                visible: {position == 0}

                Repeater {
                    id: buttons
                    Button {
                        flat: true
                        width: facade.toPx(80)
                        height:facade.toPx(90)
                        anchors.verticalCenter: parent.verticalCenter

                        onClicked: {
                            switch(index) {
                            case 0:
                                if (player.loops != MediaPlayer.Infinite) player.loops=MediaPlayer.Infinite
                                else player.loops = 0;
                                transit.start()
                                break;
                            case 2:
                                if (player.playbackState == MediaPlayer.PlayingState) {
                                    player.pause()
                                } else {
                                    player.source = loader.urlLink
                                    player.play();
                                }
                                break;
                            case 4:
                                mediaPlayer.fullScreen = !mediaPlayer.fullScreen;
                                mediaPlayer.startMovingAnimation()
                                controlShowTimer.running ? controlShowTimer.stop() : panelAnimation.start()
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
                                } else "ui/buttons/player/" + modelData + "Button.png";
                            }
                        }
                    }

                    model: ["repeatOff", "previous", "play", "next", "fullScreen"]
                }
            }

            Row {
                id: sliders
                x: facade.toPx(60)
                visible: position == 1 && player.loops == MediaPlayer.Infinite
                width: parent.width - x * 2
                height: visible? implicitHeight: 0;

                spacing: facade.toPx(20)

                Label {
                    id: firstTime
                    anchors.verticalCenter: parent.verticalCenter

                    readonly property int minutes: Math.floor(firstPosition / 60000)
                    readonly property int seconds: Math.round((firstPosition % 60000) / (1000))

                    text: formatTime(minutes, seconds, ":")
                    font.pixelSize: facade.doPx(24)
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

                    text: formatTime(minutes, seconds, ":")
                    font.pixelSize: facade.doPx(24)
                    color: "white"
                }
            }

            Button {
                anchors {
                    right: parent.right
                    rightMargin: facade.toPx(60)
                    verticalCenter: control.verticalCenter
                }
                property int shaderCounter: 0

                flat: true
                width: facade.toPx(80);
                height: facade.toPx(90)

                visible: position == 0;

                onClicked: {
                    loadShader(shaders[shaderCounter++])
                    if (shaderCounter >= shaders.length) {
                        shaderCounter = 0
                    }
                }

                Image {
                    anchors.centerIn: parent
                    source: "ui/buttons/player/extensionButton.png"
                    height: facade.toPx(sourceSize.height)
                    width: facade.toPx(sourceSize.width)
                }
            }
        }
    }

    Row {
        id: seeker
        width: parent.width - x * 2
        x: facade.toPx(60)
        anchors.bottom: controlPanel.top;
        anchors.bottomMargin: -height/2

        spacing: facade.toPx(20)

        Label {
            id: curTime
            readonly property int minutes: Math.floor(player.position / 60000)
            readonly property int seconds: Math.round((player.position % 60000) / 1000)

            anchors.bottom: parent.bottom
            anchors.bottomMargin: -height/4

            text: formatTime(minutes, seconds, ":")
            font.pixelSize: facade.doPx(24)
            color: "white"
        }

        Slider {
            id: slider
            width: (seeker.width - curTime.width - allTime.width - parent.spacing * 2)

            handle.width: handle.height
            handle.height: facade.toPx(40)

            to: player.duration

            onValueChanged: {
                if (!sync) player.seek(value)
            }

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

            anchors.bottom: parent.bottom
            anchors.bottomMargin: -height/4

            text: formatTime(minutes, seconds, ":")
            font.pixelSize: facade.doPx(24)
            color: "white"
        }
    }
}
