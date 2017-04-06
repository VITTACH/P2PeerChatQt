QT += qml quick widgets

QML_IMPORT_PATH += $$PWD

INCLUDEPATH += $$PWD

RESOURCES += $$PWD/QuickIOS/quickios.qrc

HEADERS += $$PWD/quickios.h \
    $$PWD/qiviewdelegate.h \
    $$PWD/qialertview.h \
    $$PWD/qidevice.h \
    $$PWD/qiactionsheet.h \
    $$PWD/qiimagepicker.h \
    $$PWD/qiactivityindicator.h \
    $$PWD/qisystemdispatcher.h

SOURCES += $$PWD/quickios.cpp \
    $$PWD/qialertview.cpp \
    $$PWD/qidevice.cpp \
    $$PWD/qiactionsheet.cpp \
    $$PWD/qiimagepicker.cpp \
    $$PWD/qiactivityindicator.cpp \
    $$PWD/qisystemdispatcher.cpp

ios {
    QT += gui-private

    QMAKE_CXXFLAGS += -fobjc-arc

    OBJECTIVE_SOURCES += \
        $$PWD/qisystemutils.mm \
        $$PWD/qiviewdelegate.mm \
        $$PWD/qidevice.mm

    # QuickIOS do not link static plugin since Qt 5.7

    QMAKE_POST_LINK += /usr/libexec/PlistBuddy -c \"Add :UIViewControllerBasedStatusBarAppearance bool false\" $${OUT_PWD}/Info.plist
}

