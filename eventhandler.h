#ifndef EVENTHANDLER_H
#define EVENTHANDLER_H

#include "httpnetwork.h"

using namespace std;

class EventHandler: public QObject {
    Q_OBJECT

public:
    explicit EventHandler (QObject *parent = 0);

    bool isPin = 0;
    int currentSys = 0;

    QString PathFile = "p2pudpchat";

    QString domain = "http://api.qrserver.com/";
signals:
    void sendMessages(QString);
    void reciving(QString response);

public slots:
    void display(QString , QString);
    bool relogin(QString , QString);
    int currentOSys();

    void copyText(QString);
    void sendMsgs(QString);
};

#endif// EVENTHANDLER_H
