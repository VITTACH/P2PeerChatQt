import QtQuick 2.0
import QtMultimedia 5.7
import ImageProcessor 1.0
import QtQuick.Controls 2.0

Item {
    Timer {
        id: timeout
        running: true
        interval: 39000;
        onTriggered:loader.back()
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
        id: capture
        running: true
        onTriggered: {
            viewer.grabToImage(function(resultImg) {
                var fullImageName = "qrcode.png";
                resultImg.saveToFile(fullImageName);
                imageProcessor.rgbImg(fullImageName)
                var path = fullImageName
                imageProcessor.delCaptureImage(path)
            })
        }
        interval: 3000
    }

    Connections {
        target: imageProcessor
        onResultScanToQML: {
            if(response!="") {
            response = response.replace(/\\\//g,"/")
            console.log(response)
            var obj
            obj= JSON.parse(response);
            var url
            url= obj[0].symbol[0].data

            if (url != null) {
                timeout.restart()
                var re=JSON.parse(url)
                loader.logon(re.phone, re.passwords)
            }
            else
                capture.restart()
            }
        }
    }

    VideoOutput {
        id: viewer
        source: camera
        orientation: -90
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop

        MouseArea {
            anchors.fill: parent;
            onClicked: {
                capture.restart()
                camera.imageCapture.capture()
            }
        }
    }

    Camera {
        id: camera
        flash.mode: Camera.FlashAuto

        exposure {
            exposureCompensation: -1
            exposureMode: {Camera.ExposurePortrait;}
        }

        imageProcessing.whiteBalanceMode: {
            CameraImageProcessing.WhiteBalanceFlash;
        }

        imageCapture {
            onImageCaptured: {
                capture.stop()
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
            radius: width
            color: "limegreen"
        }

        Rectangle {
            width: 4
            height: parent.height/5
            anchors.right: parent.right
            radius: width
            color: "limegreen"
        }

        Rectangle {
            width: 4
            height: {parent.height/5}
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            radius: width
            color: "limegreen"
        }

        Rectangle {
            width: 4
            height: parent.height/5
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            radius: width
            color: "limegreen"
        }

        Rectangle {
            height: 4
            width: {parent.height/5}
            anchors.left: parent.left
            radius: width
            color: "limegreen"
        }

        Rectangle {
            height: 4
            width: {parent.height/5}
            anchors.right: parent.right
            radius: width
            color: "limegreen"
        }

        Rectangle {
            height: 4
            width: {parent.height/5}
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            radius: width
            color: "limegreen"
        }

        Rectangle {
            height: 4
            width: parent.height/5
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            radius: width
            color: "limegreen"
        }

        Rectangle {
            id: scanline
            height: 2
            width: parent.width - 2*height;
            anchors.centerIn: parent;

            SequentialAnimation {
                running: true
                loops: {Animation.Infinite}
                ColorAnimation {
                    target: scanline;
                    property: {"color"}
                    from: "red"
                    to: {"transparent"}
                    duration: 350
                }
                ColorAnimation {
                    from: "transparent"
                    target: scanline;
                    property: "color"
                    to: "red";
                    duration: 350
                }
            }
        }
    }

    ImageProcessor {id: imageProcessor}
}
