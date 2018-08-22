#include <QtGui>
#include "client.h"
#include <QApplication>
#include <QInputDialog>
#include "HttpNetwork.h"
#include "eventhandler.h"
#include "imageprocessor.h"

#include <QScreen>
#include <QQmlContext>
#include <QQuickStyle>
#include <statusbar.h>
#include <PHoneswrapper.h>
#include <QQmlApplicationEngine>

int currentSys = 0;

#ifdef Q_OS_IOS
currentSys = 2;
#endif

#ifdef Q_OS_ANDROID
#include"quickandroid.h"
#include"qadrawableprovider.h"
#include"qasystemdispatcher.h"
#include<QtAndroidExtras/QAndroidJniObject>
#include<QtAndroidExtras/QAndroidJniEnvironment>

JNIEXPORT jint JNI_OnLoad(JavaVM *javm, void*) {
    Q_UNUSED(javm);
    currentSys = 1;
    QASystemDispatcher::registerNatives();
    QAndroidJniObject::callStaticMethod<void>("org/qtproject/example/friendup/PushService", "start", "()V");
    QAndroidJniObject::callStaticMethod<void>("quickandroid/QuickAndroidActivity","startUpNpForwards", "()V");
    return JNI_VERSION_1_6;
}
#endif

int main(int argc,char **argv)
{
    QApplication a(argc,argv);
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    EventHandler *eventhandler = EventHandler::Instance();
    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:///");
    QQuickStyle::setStyle("P2PStyle");
    eventhandler->currentSys = currentSys;

    qmlRegisterType<StatusBar>("StatusBar", 0 , 1, "StatusBar");
    qmlRegisterType<ImageProcessor>("ImageProcessor", 1, 0, "ImageProcessor");

    QQmlContext *context = engine.rootContext();
    Wrapper jwr;
    context->setContextProperty("caller", &jwr);
    context->setContextProperty("event_handler",  eventhandler);

    #if !defined(Q_OS_ANDROID)
    Client client;
    HttpNetwork httpBase;
    QUrl qurl("http://api.ipify.org");
    httpBase.setUrl(&qurl);
    QString name = httpBase.sendGet();
    qurl.setUrl("http://www.hoppernet.hol.es/");
    httpBase.setUrl(&qurl);

    QString buf= "READ=1&name="+ name;
    QByteArray biteUtf = buf.toUtf8();
    QString res= httpBase.sendPost(&biteUtf);
    int cp = res.indexOf('|');
    QString ip = res.right(res.length() - 1-cp);
    QString pt = res.left(cp);

    client.connectedToIp(ip, pt);

    eventhandler->connect(eventhandler, SIGNAL(sendMessages(QString)), &client, SLOT(startTransfer(QString)));
    eventhandler->connect(&client, SIGNAL(recieved(QString, QString)), eventhandler, SLOT(display(QString, QString)));
    #endif

    engine.load(QUrl("qrc:/load.qml"));
    QObject *root_obj = engine.rootObjects().first();
    QObject *loader = root_obj->findChild <QObject*> ("loader");
    loader->setProperty
    ("dpi",QApplication::screens().at(0)->logicalDotsPerInch());

    return a.exec();
}
