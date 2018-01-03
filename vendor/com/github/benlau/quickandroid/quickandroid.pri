QML_IMPORT_PATH += $$PWD

INCLUDEPATH += $$PWD
RESOURCES += $$PWD/QuickAndroid/quickandroid.qrc

HEADERS += \
    $$PWD/qaline.h \
    $$PWD/qatimer.h \
    $$PWD/qaunits.h \
    $$PWD/qadevice.h \
    $$PWD/priv/qasystemdispatcherproxy.h \
    $$PWD/quickandroid.h \
    $$PWD/qamousesensor.h \
    $$PWD/qaimagewriter.h \
    $$PWD/qadrawableprovider.h \
    $$PWD/qasystemdispatcher.h

SOURCES += \
    $$PWD/qaline.cpp \
    $$PWD/qaunits.cpp \
    $$PWD/qatimer.cpp \
    $$PWD/quickandroid.cpp \
    $$PWD/qamousesensor.cpp \
    $$PWD/qaimagewriter.cpp \
    $$PWD/priv/qasystemdispatcherproxy.cpp \
    $$PWD/qadevice.cpp \
    $$PWD/qaqmltypes.cpp \
    $$PWD/qadrawableprovider.cpp \
    $$PWD/qasystemdispatcher.cpp

QuickAndroidJavaDir = $$PWD/java

android {
    QT += androidextras

    isEmpty(ANDROID_PACKAGE_SOURCE_DIR) {
        message(ANDROID_PACKAGE_SOURCE_DIR is not defined)
    }

    # For project not using gradle
    QA_JAVASRC.path = /src/quickandroid
    QA_JAVASRC.files += \
    $$PWD/java/quickandroid/QuickAndroidActivity.java \
    $$PWD/java/quickandroid/UPForward.java \
    $$PWD/java/quickandroid/RsaEncrypt.java \
    $$PWD/java/quickandroid/PesrRequest.java \
    $$PWD/java/quickandroid/ImagePicker.java \
    $$PWD/java/quickandroid/httpRequest.java \
    $$PWD/java/quickandroid/SystemDispatcher.java

    INSTALLS += QA_JAVASRC
}

DISTFILES += \
    $$PWD/java/quickandroid/QuickAndroidActivity.java \
    $$PWD/java/quickandroid/UPForward.java \
    $$PWD/java/quickandroid/RsaEncrypt.java \
    $$PWD/java/quickandroid/PesrRequest.java \
    $$PWD/java/com/lasconic/QShareUtils.java \
    $$PWD/java/quickandroid/ImagePicker.java \
    $$PWD/java/quickandroid/httpRequest.java \
    $$PWD/java/quickandroid/SystemDispatcher.java \
    $$PWD/gradle.properties.in

