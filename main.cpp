#include <QtGui>
#include "server.h"
#include "client.h"
#include <QApplication>
#include <QInputDialog>
#include "mainwindow.h"
#include "httpnetwork.h"
#include "eventhandler.h"
#include "imageprocessor.h"

#include <QScreen>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQmlApplicationEngine>

int currentSys = 0;

#ifdef Q_OS_IOS
currentSys = 2;
#endif

#ifdef Q_OS_ANDROID
#include "quickandroid.h"
#include "qadrawableprovider.h"
#include "qasystemdispatcher.h"
#include <QtAndroidExtras/QAndroidJniObject>
#include <QtAndroidExtras/QAndroidJniEnvironment>

JNIEXPORT jint JNI_OnLoad(JavaVM * javm, void*) {
    Q_UNUSED(javm);
    currentSys = 1;
    QASystemDispatcher::registerNatives();
    QAndroidJniObject::callStaticMethod<void>("org/qtproject/example/vittachpeer/PushService","start", "()V");
    QAndroidJniObject::callStaticMethod<void>("quickandroid/QuickAndroidActivity","startUpNpForwards", "()V");
    return JNI_VERSION_1_6;
}
#endif

int main(int argc,char **argv)
{
    QApplication a(argc,argv);
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    EventHandler eventhandler;
    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:///");
    QQuickStyle::setStyle("P2PStyle");
    eventhandler.currentSys= currentSys;

    qmlRegisterType<ImageProcessor>("ImageProcessor",1,0,"ImageProcessor");

    QQmlContext *context = engine.rootContext();
    context->setContextProperty("event_handler", &eventhandler);

    #if !defined(Q_OS_ANDROID)
    Client client;
    httpnetwork httpBase;
    QUrl qurl("http://api.ipify.org");
    httpBase.setUrl(&qurl);
    QString name = httpBase.sendGet();
    qurl.setUrl("http://www.hoppernet.hol.es/");
    httpBase.setUrl(&qurl);

    QString buf= "READ=1&name="+ name;
    QByteArray biteUtf = buf.toUtf8();
    QString res= httpBase.sendPost(&biteUtf);
    int cp = res.indexOf('|');
    QString ip = res.right(res.length() - 1 - cp);
    QString pt = res.left(cp);

    client.connectedToIp(ip, pt);

    eventhandler.connect(&eventhandler, SIGNAL(sendMessages(QString)), &client, SLOT(startTransfer(QString)));
    eventhandler.connect(&client, SIGNAL(recieved(QString, QString)), &eventhandler, SLOT(display(QString, QString)));
    #endif
    /*----------------------------------------------------------------------------------------------------------------
    Client client;
    httpnetwork httpPost;

    client.connectedToIp("85.249.147.194","4447");
    QString macAddress = httpPost.getMacAddress();
    client.sendBroadcastDatagram(macAddress);
    // client.removeBroadcast();

    QThread::sleep(3);

    QUrl qurl("http://www.hoppernet.hol.es");
    httpPost.setUrl(&qurl);

    /*
    QInputDialog options;
    options.setLabelText("Enter nick name!");
    options.exec();

    QString buf= "READ=1&name=" + macAddress;//options.textValue();
    QByteArray biteUtf = buf.toUtf8();
    QString res= httpPost.sendPost(&biteUtf);
    int cp = res.indexOf('|');
    QString ip = res.right(res.length() - 1 - cp);
    QString pt = res.left(cp);

    client.connectedToIp(ip, pt);
    // Server server(pt);

    eventhandler.connect(&eventhandler, SIGNAL(sendMessages(QString)), &client, SLOT(sendBroadcastDatagram(QString)));
    eventhandler.connect(&client, SIGNAL(recieved(QString, QString)), &eventhandler, SLOT(display(QString, QString)));

    /*
    MainWindow window;
    window.connect(&server, SIGNAL(messageRecieved(QString, QString)), &window, SLOT(displayNewMsg(QString, QString)));

    window.connect(&window, SIGNAL(connectToChange(QString, QString)), &client, SLOT(connectedToIp(QString, QString)));

    window.connect(&window, SIGNAL(sendMessage(QString)), &client, SLOT(sendBroadcastDatagram(QString)));

    window.show();
    window.resize(540,320);
    window.setWindowTitle(window.windowTitle() + " (we are listen port -> " + options.textValue() + ")");
    */

    engine.load(QUrl("qrc:/load.qml"));
    QObject *root_obj = engine.rootObjects().first();
    QObject *loader = root_obj->findChild <QObject*> ("loader");
    loader->setProperty
    ("dpi",QApplication::screens().at(0)->logicalDotsPerInch());

    return a.exec();
}
