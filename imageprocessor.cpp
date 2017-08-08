#include "imageprocessor.h"

#include <QBuffer>
#include <QQmlEngine>
#include <QQmlContext>
#include <QtQuick/QQuickImageProvider>

void ImageProcessor::processImage(const QString& path) {
    QUrl u(path);
    QQmlEngine *engine = QQmlEngine::contextForObject(this)->engine();
    QQmlImageProviderBase *imageProviderBase = engine->imageProvider(u.host());
    QQuickImageProvider *imageProvider = static_cast<QQuickImageProvider*>(imageProviderBase);

    QSize imageSize;
    QString imageId = u.path().remove(0, 1);
    QImage image = imageProvider->requestImage(imageId, &imageSize, imageSize);

    if(image.isNull()==false)scanQr(&image);
}

void ImageProcessor::rgbImg(QString ipath) {
    QImage img(ipath);
    scanQr(&img);
}

void ImageProcessor::scanQr(QImage *img) {
    QString bound = "margin";
    QByteArray postData = QByteArray(build(img, bound));
    QUrl ResultsURL = QUrl("http://api.qrserver.com/v1/read-qr-code/");
    QNetworkAccessManager*netManager = new QNetworkAccessManager(this);
    QNetworkRequest request(ResultsURL);
    request.setRawHeader("Content-Length", QString::number(postData.length()).toLatin1());
    request.setRawHeader("Content-Type", "multipart/form-data; boundary=" + bound.toLatin1());
    connect(netManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(result(QNetworkReply*)));
    netManager->post(request, postData);
}

void ImageProcessor::delCaptureImage(QString pth) {
    QFile ifile(pth);
    ifile.setPermissions(QFile::ReadOther | QFile::WriteOther);
    ifile.remove();
}

void ImageProcessor::result(QNetworkReply *reply) {
    emit resultScanToQML(reply->readAll());
}

ImageProcessor::ImageProcessor(QObject *parnt):QObject(parnt){}

QByteArray ImageProcessor::build(QImage *image,QString bound) {
    QByteArray ba;
    QBuffer buffer(&ba);
    buffer.open(QIODevice::WriteOnly);
    image->save(&buffer, "PNG");

    QString imageName = "1.png";
    QByteArray data(QString("--" + bound + "\r\n").toLatin1());
    data.append("Content-Disposition: form-data; name=\"file\"; filename=\"");
    data.append(imageName);
    data.append("\"\r\n");
    data.append("Content-Type: text/xml\r\n\r\n");
    data.append(ba);
    data.append("\r\n");
    data.append("--" + bound + "--\r\n");
    return data;
}
