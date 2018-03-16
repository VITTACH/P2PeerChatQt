#include "HttpNetwork.h"
#include <QNetworkInterface>

void HttpNetwork::waiting() {
    QEventLoop loop;
    QObject::connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
    loop.exec();
}

void HttpNetwork::setUrl(QUrl *qUrl) {
    request=new QNetworkRequest(*qUrl);
}

HttpNetwork::HttpNetwork(QObject *parent): QObject(parent)
{}

void HttpNetwork::httpsettsessionID() {
    QList<QByteArray> headerList = reply->rawHeaderList();
    foreach(QByteArray head, headerList) {
        if (head == "Set-Cookie") {
            QString cookieString = reply->rawHeader(head);
            if (cookieString.size()!= 0)
            {
                QStringList keyValPairs=cookieString.split(";");
                foreach (QString encodedPair, keyValPairs) {
                    QStringList keyVal = encodedPair.split("=");
                    if (keyVal.at(0)=="laravel_session")
                        sessID = keyVal.at(1).toStdString();
                }
            }
        }
    }
}

QString HttpNetwork::getMacAddress() {
    foreach(QNetworkInterface netInterface, QNetworkInterface::allInterfaces())
    {
        if (!(netInterface.flags() & QNetworkInterface::IsLoopBack))
            return netInterface.hardwareAddress();
    }
    return QString();
}

QString HttpNetwork::sendGet() {
    request->setRawHeader("Content-Type", "application/x-www-form-urlencoded");
    if (sessID.length() != 0)
        request->setRawHeader("Cookie", ("laravel_session=" + sessID).c_str());
    reply = manager.get(*request);

    waiting();
    this->httpsettsessionID();
    return reply -> readAll();
}

QString HttpNetwork::sendPost(QByteArray *requestString) {
    request->setRawHeader("Content-Type", "application/x-www-form-urlencoded");
    if (sessID.length() != 0)
        request->setRawHeader("Cookie", ("laravel_session=" + sessID).c_str());
    reply = manager.post(*request, *requestString);

    waiting();
    this->httpsettsessionID();
    return reply -> readAll();
}

QString HttpNetwork::sendAvatar(QFile *file) {
    QHttpPart imagePart;
    QHttpMultiPart *multiPart=new QHttpMultiPart(QHttpMultiPart::FormDataType);
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("image/png"));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"avatar\""));
    if(file->open(QIODevice::ReadOnly)) {
    qDebug() << "opening picture is correct!";
    imagePart.setBodyDevice(file);
    file->setParent(multiPart);

    multiPart->append(imagePart);
    reply = manager.post(*request, multiPart);

    waiting();
    this->httpsettsessionID();
    }
    return reply -> readAll();
}
