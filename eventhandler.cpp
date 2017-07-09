#include "eventhandler.h"

#include <QDir>
#include <QClipboard>
#include <QApplication>
#include <QStandardPaths>
#include <QCoreApplication>

int EventHandler::currentOSys() {
    return currentSys;
}

void EventHandler::sendMsgs(QString msgtext) {
    emit sendMessages(msgtext);
}

QString EventHandler::loadValue(QString key) {
    return setting->value(key).toString();
}

void EventHandler::saveSet(QString key, QString vals) {
    setting->setValue(key, vals);
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
    qDebug() << "Incoming message= " << message;
}

EventHandler::EventHandler(QObject*parent): QObject(parent) {
    setting = new QSettings("p2peerio",QSettings::IniFormat);
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
