import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QuickIOS 0.1

Window {
    id: window
    height: 640 // For desktop
    width: 480
    visible: true

    NavigationController {
        id : navigation
        anchors.fill: parent

        navigationBar.titleAttributes: NavigationBarTitleAttributes {
            textColor : "#ff0000"
        }

        initialViewController: ViewController {
            id: rootView
            title : "Quick iOS Example Program"

            ScrollView {
                anchors.fill: parent
                flickableItem.interactive: true
                flickableItem.flickableDirection : Flickable.VerticalFlick

                TableSection {
                    width: rootView.width

                    headerTitle: "System Components"
                    model: ListModel {
                        ListElement { title : "Alert View" ; file : "alertview/AlertViewDemo.qml" }
                        ListElement { title : "Action Sheet" ; file : "actionSheet/ActionSheetDemo.qml"}
                        ListElement { title : "Image Picker" ; file :"imagePicker/ImagePickerDemo.qml" }
                        ListElement { title : "Tool Bar"; file : "toolBar/ToolBarDemo.qml" }
                        ListElement { title : "Activity Indicator" }
                        ListElement { title : "Status Bar"; file :"statusBar/StatusBarDemo.qml"; present:true}
                        ListElement { title : "Segmented Control"; file:"segment/SegmentedControlDemo.qml"}
                    }

                    onSelected: {
                        switch (index) {
                        case 4:
                            activityIndicator.startAnimation();
                            activityIndicatorTimer.start();
                            break;
                        default:
                            var item = model.get(index);
                            if (item.present) {
                                rootView.present(Qt.resolvedUrl(item.file));
                            } else {
                                rootView.navigationController.push(Qt.resolvedUrl(item.file));
                            }
                            break;
                        }
                    }
                }
            }

        }

        onPopped: {
            console.log(viewController.title + " is popped");
        }
    }

    ActionSheet {
        id : pickerAction
        title : "Pick Photo"
        otherButtonTitles : ["Photo Library","Camera","Saved Album"];
        onClicked: {
            picker.sourceType = index;
            picker.show();
        }
    }

    ActivityIndicator {
        id : activityIndicator

        Timer {
            id : activityIndicatorTimer;
            interval : 3000
            onTriggered: {
                activityIndicator.stopAnimation();
                activityIndicator.style++;
                activityIndicator.style = activityIndicator.style % 3;
            }
        }
    }

    ImagePicker {
        id : picker
    }

    Component.onCompleted: {
//        navigation.push(rootView,false);
    }

}
