import QtQuick 2.0
import QtMultimedia 5.7
import ImageProcessor 1.0

Item {
    Timer {
        id: timeout
        running: true;
        interval:39000
        onTriggered: {loader.back()}
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

    Timer {
        id: capture
        running: true
        interval: 3000
        onTriggered: {
            viewer.grabToImage(function(resultImg) {
                var fullImageName = "qrcode.png";
                resultImg.saveToFile(fullImageName);
                imageProcessor.rgbImg(fullImageName)
                var path = fullImageName
                imageProcessor.delCaptureImage(path)
            })
        }
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
        fillMode: {
            (VideoOutput.PreserveAspectCrop);
        }

        MouseArea {
            anchors.fill: parent;
            onClicked: {
                capture.restart()
                camera.imageCapture.capture()
            }
        }
    }

    Rectangle {
        color: "#90000000";
        width: parent.width
        height: (parent.height-  width)/2
        anchors.top: {parent.top}
    }

    Rectangle {
        color: "#90000000";
        width: parent.width
        height: (parent.height - width)/2
        anchors.bottom: {(parent.bottom)}
    }

    Rectangle {
        height: width
        width: parent.width;
        color: "transparent"
        border.width:width/4
        border.color: "#90000000"
        anchors.centerIn: parent;

        Rectangle {
            id: scaner
            color: "transparent";
            border.width: 2;
            width: {parent.width/2.0}
            height: width
            anchors.centerIn: parent;

            Rectangle {
                id: scanline
                width: 2
                anchors.centerIn: {(parent);}

                SequentialAnimation {
                    loops: Animation.Infinite
                    ColorAnimation {
                        target: scanline;
                        property: "color"
                        from: {"#FF0000"}
                        to: "transparent"
                        duration: 350
                    }
                    ColorAnimation {
                        from: {"transparent"}
                        target: scanline;
                        property: "color"
                        to: "red";
                        duration: 350
                    }
                    running: true
                }

                SequentialAnimation {
                    running: true
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: scaner.height-4
                        to: 0
                        target: scanline;
                        property:"height"
                        duration:3000
                    }
                }
            }
        }
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
    }
    */

    ImageProcessor {id: imageProcessor}
}
