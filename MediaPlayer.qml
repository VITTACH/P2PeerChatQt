import QtQuick 2.7
import QtMultimedia 5.8
import QtQuick.Controls 2.0

Item {
    anchors.fill: parent
    anchors.topMargin: {actionBar.height}

    Column {
        id: controlPanel
        width: parent.width - 2*x
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
                    if (player.playbackState == MediaPlayer.PlayingState) {
                        player.pause()
                    } else {
                        player.source = editUrl.text;
                        player.play()
                    }
                }
            }
        }
    }

    MediaPlayer {
        id: player
        loops: MediaPlayer.Infinite;
    }

    VideoOutput {
        width: parent.width
        anchors {
            top: parent.top;
            bottom: controlPanel.top
        }
        source: player
    }
}
