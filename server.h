#ifndef SERVER_H
#define SERVER_H

#include <QObject>
#include <QtNetwork>
#include <QTcpServer>
#include <QTcpSocket>

class Server: public QObject
{
Q_OBJECT
public:
    ~Server();
    Server(QString port, QObject*parent=0);
public slots:
    void acceptConnection();
    void startRead();
signals:
    void recieved(QString msg, QString us);
private:
    QTcpSocket *client;
    QTcpServer server;
};

#endif
