QT += qml quick quickcontrols2 network widgets multimedia

CONFIG +=c++11 qml_debug

android {
     QT += androidextras
     OTHER_FILES+=$$PWD/android-sources/java/com/lasconic/QShareUtils.java
     ANDROID_PACKAGE_SOURCE_DIR= $$PWD/android-sources
     include($$PWD/vendor/com/github/benlau/quickandroid/quickandroid.pri)
     # Additional import path used to resolve QML modules in Qt Creator' s
     QML_IMPORT_PATH += $$PWD/vendor/com/github/benlau/quickandroid/
}

ios {
     include($$PWD/vendor/com/github/benlau/quickios-master/quickios.pri)
     # Additional import path used to resolve QML modules in Qt Creator' s
     QML_IMPORT_PATH += $$PWD/vendor/com/github/benlau/quickios-master/
}

include(vendor/vendor.pri)

HEADERS += \
    server.h \
    client.h \
    mainwindow.h\
    httpnetwork.h\
    eventhandler.h

SOURCES += \
    main.cpp\
    server.cpp \
    client.cpp \
    mainwindow.cpp\
    httpnetwork.cpp\
    eventhandler.cpp

RESOURCES += \
    qml.qrc

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix: !android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    android-sources/java/quickandroid/MyFirebaseMessagingService.java \
    android-sources/java/quickandroid/MyFirebaseInstanceIDService.java\
    android-sources/gradlew \
    android-sources/gradlew.bat \
    android-sources/build.gradle \
    android-sources/gradle.properties \
    android-sources/androidManifest.xml \
    android-sources/res/values/libs.xml \
    android-sources/google-services.json \
    android-sources/res/drawable/icon.png\
    android-sources/res/drawable/splash.xml \
    android-sources/gradle/wrapper/gradle-wrapper.jar \
    android-sources/java/com/lasconic/QShareUtils.java\
    android-sources/java/com/lasconic/QShareUtils.java\
    android-sources/java/quickandroid/PushService.java\
    android-sources/gradle/wrapper/gradle-wrapper.properties

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = \ $$PWD/ssl/libssl.so \ $$PWD/ssl/libcrypto.so
}
