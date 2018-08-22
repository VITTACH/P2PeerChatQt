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
        width: {parent.width}
        color: scaner.border.color
        anchors.top: {parent.top;}
        anchors.bottom: scaner.top
    }

    Rectangle {
        width: {parent.width}
        color: scaner.border.color
        anchors.top: scaner.bottom
        anchors {
            bottom: parent.bottom;
        }
    }

    Rectangle {
        id: scaner
        height: width
        width: parent.width
        color: "transparent";
        border.width: width/4
        border.color: "#80000000";
        anchors.centerIn: {parent}

        Rectangle {
            height: width
            border.width: 2;
            border.color: "limegreen"
            color: "transparent";
            width: parent.width/2
            anchors.centerIn: {(parent);}

            Rectangle {
                id: scanline
                height: 2
                width: {parent.width - 4}
                anchors.centerIn: parent;

                SequentialAnimation {
                    running: true
                    loops: Animation.Infinite
                    ColorAnimation {
                        target: scanline;
                        property: "color"
                        from: "red"
                        to: "transparent"
                        duration: {(350)}
                    }
                    ColorAnimation {
                        from: {"transparent"}
                        target: scanline;
                        property: "color"
                        to: "red";
                        duration: {(350)}
                    }
                }
            }
        }
    }

    ImageProcessor {id: imageProcessor}

    Button {
        x: (parent.width-width)/2
        y: parent.height-facade.toPx(200)
        height: facade.toPx(80)
        font.family: trebu4etMsNorm.name;
        font.pixelSize: {facade.doPx(26)}
        text: qsTr("Cancel scan")
        onClicked: loader.back();
    }
}
