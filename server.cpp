#include <QString>
#include "server.h"

Server::~Server() {
    server.close();
}

Server::Server(QString port, QObject *parent): QObject(parent) {
    connect(&server, SIGNAL(newConnection()), this, SLOT(acceptConnection()));

    server.listen(QHostAddress::Any, 4444);
    qDebug() << "Listening on port: " << port;
}

void Server::acceptConnection() {
    client = server.nextPendingConnection();
    connect(client,SIGNAL(readyRead()),this, SLOT(startRead()));
}

void Server::startRead() {
    qDebug() << "Starting reading...";

    char qtBuffer[1024] = {0};
    client->read(qtBuffer, client->bytesAvailable());

    QString msg(qtBuffer);
    QString sender(client->peerAddress().toString() + " -" + client->peerName() + " -" + QString::number(client->peerPort()));

    emit recieved(msg,sender);
}
