#include "eventhandler.h"

#include <QDir>
#include <QClipboard>
#include <QApplication>
#include <QStandardPaths>
#include <QCoreApplication>

int EventHandler::currentOSys() {
    return currentSys;
}

void EventHandler::sendMsgs(QString text) {
    emit sendMessages(text);
}

bool EventHandler::relogin(QString tel, QString pass) {
    return isPin;
}

void EventHandler::copyText(QString text) {
     QClipboard *clipboard = QApplication::clipboard();
     clipboard->clear();
     clipboard->setText(text);
}

void EventHandler::display(QString message, QString sender) {
    emit reciving(message);
    qDebug() << "Incoming message= " << message;
}

EventHandler::EventHandler(QObject*parent): QObject(parent) {
    if(!currentSys) {
    QString path = QStandardPaths::standardLocations(QStandardPaths::DataLocation).value(0);
    QDir dir(path);
    if (!dir.exists())
        dir.mkpath(path);
    if (!path.isEmpty() && !path.endsWith("/"))
        path += "/" + PathFile;
        PathFile = path;
    }
}
