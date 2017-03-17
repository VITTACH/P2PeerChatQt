#ifndef CLIENT_H
#define CLIENT_H

#include <QObject>
#include <QTcpSocket>
#include <QUdpSocket>

class Client : public QObject {
Q_OBJECT
public:
    /*
    void removeBroadcast();
    void updateAddresses();
    */
    Client(QObject *parent= 0);
private:
    QTcpSocket iosocket;
    QUdpSocket broadcastSocket;
    QList<QHostAddress>ipAddresses,broadcastAddresses;
public slots:
    void startRead();
    void readBroadcastDatagram();
    void connectedToIp(QString address, QString port);
    void slotSoketError(QAbstractSocket::SocketError);
    void startTransfer(QString message);
    void sendBroadcastDatagram(QString);
signals:
    void recieved(QString m, QString u);
};

#endif // CLIENT_H
