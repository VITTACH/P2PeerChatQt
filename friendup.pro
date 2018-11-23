QT += qml quick quickcontrols2 network multimedia
CONFIG += c++11 qml_debug warn_on qmltestcase

qnx: target.path = /tmp/$${TARGET}/bin
else: unix: !android: target.path =/opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

android {
    QT += webview androidextras
    ANDROID_PACKAGE_SOURCE_DIR= $$PWD/android-sources
    OTHER_FILES+=$$PWD/android-sources/java/com/lasconic/QShareUtils.java
    include($$PWD/vendor/com/github/benlau/quickandroid/quickandroid.pri)
    # Additional import path used to resolve QML modules in Qt Creator' s
    QML_IMPORT_PATH += $$PWD/vendor/com/github/benlau/quickandroid/
}

ios {
    QT += webview
    include($$PWD/vendor/com/github/benlau/quickios-master/quickios.pri)
    # Additional import path used to resolve QML modules in Qt Creator' s
    QML_IMPORT_PATH += $$PWD/vendor/com/github/benlau/quickios-master/
}

include(QZXING/QZXING.pri)
include(vendor/vendor.pri)

HEADERS += \
    client.h \
    statusbar.h \
    HttpNetwork.h \
    eventhandler.h \
    PHoneswrapper.h \
    imageprocessor.h \
    cameracontroler.h

test_conf {
    SOURCES += \
        tst_friendupqml.cpp
} else {
    SOURCES += \
        main.cpp\
        client.cpp \
        statusbar.cpp \
        HttpNetwork.cpp \
        eventhandler.cpp \
        PHoneswrapper.cpp \
        imageprocessor.cpp
}

RESOURCES += \
    qml.qrc

DISTFILES += \
    QZXING/QZXING.pri \
    android-sources/gradlew \
    android-sources/gradlew.bat \
    android-sources/build.gradle \
    android-sources/gradle.properties \
    android-sources/gradle/wrapper/gradle-wrapper.jar \
    android-sources/java/quickandroid/PushService.java\
    android-sources/gradle/wrapper/gradle-wrapper.properties \
    android-sources/java/quickandroid/MyFirebaseMessagingService.java \
    android-sources/java/quickandroid/MyFirebaseInstanceIDService.java\
    android-sources/androidManifest.xml \
    android-sources/res/values/libs.xml \
    android-sources/google-services.json \
    android-sources/libs/jsons-1.1.1.jar \
    android-sources/libs/stuns-0.7.3.jar \
    android-sources/res/drawable/icon.png \
    android-sources/libs/slf4j-api.16.jar \
    android-sources/libs/cling-core-2.1.1.jar \
    android-sources/libs/slf4j-jdk14-1.5.6.jar \
    android-sources/libs/Seamless-Xml-1.1.1.jar \
    android-sources/libs/cling-support-2.1.1.jar\
    android-sources/libs/seamless-http-1.1.1.jar\
    android-sources/libs/Seamless-UTil-1.1.1.jar\
    android-sources/java/com/lasconic/QShareUtils.java\
    android-sources/res/drawable/splash.xml \
    android-sources/libs/jetty-SerVer.821106.jar \
    android-sources/libs/jetty-http.81121106.jar \
    android-sources/libs/jetty-Client-8.22016.jar \
    android-sources/libs/jetty-continuation.8.jar \
    android-sources/libs/jetty-io.8.1.8121106.jar \
    android-sources/libs/jetty-security.21106.jar \
    android-sources/libs/jetty-servLet.1.1106.jar \
    android-sources/libs/jetty-Util.8.1121106.jar \
    android-sources/libs/servlet-api-3.0.jar \
    tests/tst_login.qml

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = \
        $$PWD/ssl/libcrypto.so \
        $$PWD/ssl/libssl.so
}

SOURCES += \
    cameracontroler.cpp
