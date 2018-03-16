#include <QString>
#include <QtNetwork>
#include <QTcpSocket>
#include <QByteArray>
#include <QHostAddress>
#include "client.h"

static int broadcastPort= 4444;

void Client::readBroadcastDatagram() {
    while (!!broadcastSocket.hasPendingDatagrams()) {
        quint16 senderPort;
        QByteArray datagram;
        QHostAddress senderIp;
        datagram.resize(broadcastSocket.pendingDatagramSize());
        if (broadcastSocket.readDatagram(datagram.data(), datagram.size(), &senderIp, &senderPort)==-1)
            continue;
        QString sender(senderIp.toString() + "|" + QString::number(senderPort));
        emit recieved(QString(datagram), sender);
        qDebug() << "read datagram " << datagram;
    }
}

void Client::sendBroadcastDatagram(QString message) {
    QByteArray datagram;
    datagram.append(message);
    bool validBroadcastAddresses = true;
    foreach (QHostAddress addr, broadcastAddresses) {
        if(broadcastSocket.writeDatagram(datagram, addr, broadcastPort) == -1) {
            validBroadcastAddresses = false;
        }
    }
    qDebug() << "sendBroadcastDatagram= " << message << validBroadcastAddresses;
}

void Client::connectedToIp(QString address, QString port) {
    if (iosocket.isOpen()) {iosocket.close();}
    qDebug()<< "Try connceting " << address << "|" << port;

    QHostAddress addr(address);
    iosocket.connectToHost(addr,port.toInt());
}

Client::Client(QObject *parent1): QObject(parent1) {
    connect(&iosocket,SIGNAL(error(QAbstractSocket::SocketError)),this,SLOT(slotSoketError(QAbstractSocket::SocketError)));
    connect(&iosocket,SIGNAL(readyRead()),this,SLOT(startRead()));
}

void Client::startRead() {
    qDebug() << "Starting reading data...";

    char readerBuffer[16384]={0};
    iosocket.read(readerBuffer, iosocket.bytesAvailable());

    QString msg(readerBuffer);
    QString sender(iosocket.peerAddress().toString() +"-" +iosocket.peerName() +"-" +QString::number(iosocket.peerPort()));

    emit recieved(msg,sender);
}

void Client::slotSoketError(QAbstractSocket::SocketError) {
    qDebug() <<broadcastSocket.errorString();
}

void Client::startTransfer(QString message)
{
    if (!iosocket.isValid())qDebug() << "Socket not ready";
    qDebug() << "Starting transfer data..";
    QByteArray messageArray;
    messageArray.append(message);

    if (iosocket.write(messageArray) == -1)
        qDebug() << iosocket.errorString();
}
