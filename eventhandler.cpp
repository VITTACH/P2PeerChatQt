#include "eventhandler.h"

#include <QDir>
#include <QClipboard>
#include <QApplication>
#include <QStandardPaths>
#include <QCoreApplication>

#ifdef Q_OS_ANDROID
  #include <jni.h>
  #include <QtAndroidExtras/QAndroidJniObject>

  #ifdef __cplusplus
  extern "C" {
  #endif

  JNIEXPORT

  void JNICALL Java_quickandroid_UtilsForJavaNative_sendEventReceiveMsg(JNIEnv *env, jobject obj, jstring msg) {
      QString messages(env->GetStringUTFChars(msg, 0));
      EventHandler *instance =EventHandler::Instance();
      emit instance->reciving(messages);
  }

  #ifdef __cplusplus
  }
  #endif
#endif

QString EventHandler::myError() {
#ifdef Q_OS_ANDROID
     return QAndroidJniObject::callStaticObjectMethod("quickandroid/QuickAndroidActivity", "getStacTrace", "()Ljava/lang/String;").toString();
#endif
     return QString();
}

int EventHandler::currentOSys() {
    return currentSys;
}

EventHandler* EventHandler::__instance = NULL;
EventHandler* EventHandler::Instance() {
  if(__instance==0){
     __instance=new EventHandler;
  }
  return __instance;
}

void EventHandler::sendMsgs(QString msgtext) {
#ifdef Q_OS_ANDROID
    QAndroidJniObject msg=QAndroidJniObject::fromString(msgtext);
    QAndroidJniObject::callStaticMethod<void>("quickandroid/QuickAndroidActivity", "sendMsg", "(Ljava/lang/String;)V", msg.object<jstring>());
#else
    emit sendMessages(msgtext);
#endif
}

QString EventHandler::loadValue(QString key) {
    return setting->value(key).toString();
}

void EventHandler::saveSettings(QString key, QString value) {
    setting->setValue(key, value);
}

bool EventHandler::relogin(QString tel, QString pass) {
    return isPin;
}

void EventHandler::copyText(QString msgtext) {
     QClipboard *clipboard = QApplication::clipboard();
     clipboard->clear();
     clipboard->setText(msgtext);
}

void EventHandler::display(QString message, QString sender) {
    emit reciving(message);
    qDebug() << "Incoming text = " << message;
}

EventHandler::EventHandler(QObject*parent): QObject(parent) {
    setting = new QSettings("p2peerio",QSettings::IniFormat);
    if (currentSys == !1) {
        QString fullPath = QStandardPaths::standardLocations(QStandardPaths::DataLocation).value(0);
        QDir dir(fullPath);
        if (!dir.exists())
            dir.mkpath(fullPath);
        if (!fullPath.isEmpty() && !fullPath.endsWith("/")) {
            fullPath += "/" + PathFile;
        }
        PathFile =fullPath;
    }
}
