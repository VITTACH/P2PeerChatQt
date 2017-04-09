#include <QString>
#include <QtNetwork>
#include <QTcpSocket>
#include <QByteArray>
#include <QHostAddress>

#include "client.h"

static int broadcastPort= 4444;

/*
void Client::removeBroadcast(){
    broadcastAddresses.clear();
    broadcastSocket.close();
}
*/

void Client::connectedToIp(QString address, QString port) {
    if (iosocket.isOpen()) {iosocket.close();}
    qDebug()<< "Try connceting " << address << "|" << port;

    QHostAddress addr(address);
    iosocket.connectToHost(addr,port.toInt());
    /*
    broadcastPort=port.toInt();
    broadcastAddresses.clear();
    broadcastAddresses << addr;
    */
}

Client::Client(QObject *parent1): QObject(parent1) {
    connect(&iosocket,SIGNAL(error(QAbstractSocket::SocketError)),this,SLOT(slotSoketError(QAbstractSocket::SocketError)));
    connect(&iosocket,SIGNAL(readyRead()),this,SLOT(startRead()));

    /*
    broadcastSocket.bind(QHostAddress("192.168.1.104"), 4444, QUdpSocket :: ShareAddress | QUdpSocket :: ReuseAddressHint);
    QObject::connect(&broadcastSocket,SIGNAL(readyRead()),
                     this, SLOT(readBroadcastDatagram()));
                     */
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

/*
void Client::updateAddresses() {
    ipAddresses.clear();
    broadcastAddresses.clear();
    QHostAddress broadcastAddress;
    foreach (QNetworkInterface interface, QNetworkInterface::allInterfaces()) {
        foreach (QNetworkAddressEntry curr_entry, interface.addressEntries()) {
            broadcastAddress = curr_entry.broadcast();
            if (broadcastAddress != QHostAddress::Null && curr_entry.ip() != QHostAddress::LocalHost) {
                broadcastAddresses<< broadcastAddress;
                ipAddresses << curr_entry.ip();

                qDebug() << "adres with mask= " << broadcastAddress.toString();
                qDebug() << "ip= " << curr_entry.ip().toString();
            }
        }
    }
}
*/

void Client::readBroadcastDatagram() {
    while(broadcastSocket.hasPendingDatagrams()){
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

    // if (!validBroadcastAddresses) updateAddresses();
    qDebug() << "sendBroadcastDatagram= " << message << validBroadcastAddresses;
}
