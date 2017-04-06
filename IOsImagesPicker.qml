import QtQuick 2.0
import QuickIOS 0.1

ImagePicker {
    id: imagePicker;
    property var onChange: function (url) {}

    onMediaUrlChanged: {onChange(mediaUrl);}
}
