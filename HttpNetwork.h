#ifndef HTTPNETWORK_H
#define HTTPNETWORK_H

#include <QFile>
#include <QHttpPart>
#include <QEventLoop>
#include <QtNetwork/QNetworkReply>

using namespace std;

class HttpNetwork: public QObject {
    //Q_OBJECT

public:
    string sessID ="";
    QNetworkReply * reply;
    QNetworkRequest * request;
    QNetworkAccessManager manager;
    explicit HttpNetwork(QObject *parent = 0);

    void waiting();
    void setUrl(QUrl*);
    void httpsettsessionID();

public slots:
    QString sendGet();
    QString getMacAddress();
    QString sendAvatar(QFile *);
    QString sendPost(QByteArray *);
};

#endif // HTTPNETWORK_H
