import QtQuick 2.0
import QtMultimedia 5.7
import QtQuick.Controls 2.0

Item {
    Timer {
        running: true
        interval: 39000
        onTriggered: loader.back()
    }

    /*
     * todo: make this function working pls!
    function sendQrCode(binary) {
        var boundary = String(Math.random()).slice(2);
        var boundaryMiddle = '--' + boundary + '\r\n';
        var boundaryLast = '--' + boundary + '--\r\n';

        var body=['Content-Disposition: form-data; name="file"; filename="1.png"\r\nContent-Type: text/xml\r\n\r\n' + binary + '\r\n'];

        body = boundaryMiddle + body + boundaryLast;

        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'http://api.qrserver.com/v1/read-qr-code/', true);

        xhr.setRequestHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);

        xhr.onreadystatechange = function(){
          if (xhr.readyState == XMLHttpRequest.DONE) {
              console.log(xhr.responseText);
              return;
          }
        }

        xhr.send(body);
    }*/

    Timer {
        interval: 1000
        triggeredOnStart: false

        onTriggered: {
            viewer.grabToImage(function(resultImg) {
                cameracontroler.decodeQMLImage(resultImg)
            })
        }

        running:true
        repeat: true
    }

    Connections {
        target: cameracontroler

        onTagFound: {
            var qrResult = JSON.parse(idScanned);
            loader.logon(qrResult.tel, qrResult.password)
        }

        onErrorMessage: {
            console.log(message)
        }
    }

    VideoOutput {
        id: viewer
        source: camera
        anchors.fill: parent
        autoOrientation:true
        fillMode: VideoOutput.PreserveAspectCrop

        PinchArea {
            anchors.fill: parent;
            pinch.minimumScale: 1
            pinch.maximumScale: camera.maximumDigitalZoom
            scale: camera.digitalZoom

            onPinchUpdated: {
                camera.digitalZoom = pinch.scale
            }
        }
    }

    Camera {
        id: camera
        flash.mode: Camera.FlashAuto
        captureMode: Camera.CaptureStillImage

        exposure {
            exposureCompensation: -1
            exposureMode: {Camera.ExposurePortrait;}
        }

        imageProcessing.whiteBalanceMode: {
            CameraImageProcessing.WhiteBalanceFlash;
        }

        imageCapture {
            onImageCaptured: {
                imageProcessor.processImage(preview)
            }
            onImageSaved: {
                imageProcessor.delCaptureImage(path)
            }
        }
    }

    Rectangle {
        id: uperSquare
        color: "#AA000000"
        width: parent.width
        anchors {
            top: parent.top
            bottom: center.top
        }
    }

    Rectangle {
        id: downSquare
        color: "#AA000000"
        width: parent.width
        anchors {
            bottom: parent.bottom;
            top: center.bottom
        }
    }

    Rectangle {
        id: leftSquare
        color: "#AA000000"
        anchors {
            left: parent.left
            top: uperSquare.bottom
            bottom: downSquare.top
            right: center.left
        }
    }

    Rectangle {
        id: rightSquare
        color: "#AA000000"
        anchors {
            right: parent.right
            top: uperSquare.bottom
            bottom: downSquare.top
            left: center.right
        }
    }

    Rectangle {
        id: center
        width: height
        color: "transparent"
        height: parent.width > parent.height? parent.width/3: parent.height/3
        anchors.centerIn: parent;

        Rectangle {
            width: 4
            height: {parent.height/5}
            anchors.left: parent.left
            anchors.leftMargin: -width/2;
            radius: width
            color: "limegreen"
        }

        Rectangle {
            width: 4
            height: parent.height/5
            anchors.right: parent.right
            anchors.rightMargin: -width/2
            radius: width
            color: "limegreen"
        }

        Rectangle {
            width: 4
            height: {parent.height/5}
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: -width/2;
            radius: width
            color: "limegreen"
        }

        Rectangle {
            width: 4
            height: parent.height/5
            anchors.right: parent.right
            anchors.rightMargin: -width/2
            anchors.bottom: parent.bottom
            radius: width
            color: "limegreen"
        }

        Rectangle {
            height: 4
            width: parent.height/5;
            anchors.top: parent.top
            anchors.topMargin: -height/2;
            radius: width
            color: "limegreen"
        }

        Rectangle {
            height: 4
            width: parent.height/5;
            anchors.top: parent.top
            anchors.right: {parent.right}
            anchors.topMargin: -height/2;
            radius: width
            color: "limegreen"
        }

        Rectangle {
            height: 4
            width: {parent.height/5;}
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -height/2
            radius: width
            color: "limegreen"
        }

        Rectangle {
            height: 4
            width: parent.height/5
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -height/2
            radius: width
            color: "limegreen"
        }

        Rectangle {
            id: scanline

            height: 2
            radius: height
            width: parent.width
            anchors.centerIn: parent;

            SequentialAnimation {
                running: true
                loops: {Animation.Infinite}
                ColorAnimation {
                    target: scanline;
                    property: "color"
                    from: "red"
                    to: "transparent"
                    duration: 300
                }
                ColorAnimation {
                    from: "transparent"
                    target: scanline;
                    property: "color"
                    to: "red";
                    duration: 300
                }
            }
        }
    }
}
