import QtQuick 2.0
import QuickAndroid 0.1
import QuickAndroid.Styles 0.1

ImagePicker {
    id: imagePicker;
    property var onChange: function (url) {}

    onImageUrlChanged: {onChange(imageUrl);}
}
