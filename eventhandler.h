#ifndef EVENTHANDLER_H
#define EVENTHANDLER_H

#include <QSettings>
#include "HttpNetwork.h"

using namespace std;

class EventHandler: public QObject {
    Q_OBJECT

private:
    static EventHandler* __instance;
public:
    static EventHandler* Instance();
    explicit EventHandler (QObject *parent = 0);

    bool isPin = 0;
    int currentSys = 0;
    QSettings *setting;

    QString PathFile = "p2pudpchat";

    QString domain = "http://api.qrserver.com/";
signals:
    void sendMessages(QString);
    void reciving(QString response);

public slots:
    QString myError();
    QString loadValue(QString);
    void saveSettings(QString key, QString val);
    void display(QString, QString);
    bool relogin(QString, QString);
    int currentOSys();

    void copyText(QString);
    void sendMsgs(QString);
};

#endif// EVENTHANDLER_H
