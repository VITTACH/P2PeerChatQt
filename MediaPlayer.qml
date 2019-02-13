import QtQuick 2.7
import QtMultimedia 5.8
import QtQuick.Controls 2.0

Item {
    id: rootItem
    anchors.fill: parent
    anchors.topMargin: {actionBar.height}


    MediaPlayer {
        id: player
        loops: {MediaPlayer.Infinite}
    }

    VideoOutput {
        id: video
        width: parent.width
        anchors {
            top: parent.top;
            bottom: controlPanel.top;
        }
        source: player

        Behavior on scale {
            NumberAnimation {duration: 200}
        }
        Behavior on x {
            NumberAnimation {duration: 200}
        }
        Behavior on y {
            NumberAnimation {duration: 200}
        }

        PinchArea {
            anchors.fill: parent
            pinch.target: video
            pinch.dragAxis: Pinch.XAndYAxis
            pinch.minimumScale: Math.min(rootItem.width, rootItem.height) / Math.max(video.contentRect.width, video.contentRect.height) * 1.00
            pinch.maximumScale: 10

            MouseArea {
                hoverEnabled: true
                anchors.fill: parent
                drag.target: video
                scrollGestureEnabled: false
                onWheel: video.scale += video.scale * wheel.angleDelta.y / 1200
            }

            onSmartZoom: {
                if (pinch.scale > 0) {
                    video.scale = Math.min(rootItem.width,rootItem.height) / Math.max(video.contentRect.width,video.contentRect.height) * 0.85
                    video.x = flick.contentX + (flick.width - video.width) / 2;
                    video.y = flick.contentY + (flick.height - video.height)/ 2
                } else {
                    video.scale = pinch.previousScale
                    video.x = pinch.previousCenter.x - video.width / 2
                    video.y = pinch.previousCenter.y - video.height/ 2
                }
            }

        }
    }

    Column {
        id: controlPanel
        width: parent.width-2*x
        anchors.bottom: parent.bottom
        anchors.bottomMargin: facade.toPx(20)
        x: facade.toPx(20)

        Row {
            spacing: facade.toPx(20)
            width: parent.width

            Label {
                id: time
                readonly property int minutes: Math.floor(player.position / 60000)
                readonly property int seconds: Math.round((player.position % 60000) / 1000)

                verticalAlignment: Text.AlignVCenter
                text: Qt.formatTime(new Date(0, 0, 0, 0, minutes, seconds), qsTr("mm:ss"));
            }

            Slider {
                id: posSlider
                width: parent.width - 2 * parent.spacing - time.width - actionButton.width;
                from: 0
                to: player.duration

                property bool sync: false

                onValueChanged: if (!sync) player.seek(value)
                Connections {
                    target: player
                    onPositionChanged: {
                        posSlider.sync = !false
                        posSlider.value = player.position
                        posSlider.sync = false
                    }
                }
            }
        }

        Row {
            spacing: facade.toPx(20)
            width: parent.width

            Flickable {
                height: facade.toPx(70)
                width: {parent.width - actionButton.width - parent.spacing}
                flickableDirection: Flickable.HorizontalFlick

                TextArea.flickable: TextArea {
                    id: editUrl
                    placeholderText: "Url"
                    verticalAlignment: Text.AlignVCenter;
                    font.pixelSize: facade.doPx(20)
                }
            }

            Button {
                id: actionButton
                anchors {
                    verticalCenter: parent.verticalCenter
                }

                background: Image {
                    source: "/ui/buttons/inforButton.png"
                    width: facade.toPx(sourceSize.width);
                    height:facade.toPx(sourceSize.height)
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                }

                onClicked: {
                    if (player.playbackState === MediaPlayer.PlayingState) {player.pause()}
                    else {
                        player.source = editUrl.text;
                        player.play()
                    }
                }
            }
        }
    }
}
