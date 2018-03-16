#ifndef IMAGEPROCESSOR_H
#define IMAGEPROCESSOR_H

#include <QDebug>
#include <QObject>
#include "HttpNetwork.h"

class ImageProcessor : public QObject {
    Q_OBJECT
public:
    explicit ImageProcessor(QObject *p = 0);

signals:
    void resultScanToQML(QString response);

public slots:
    void scanQr(QImage *);
    void rgbImg(QString path);
    void result(QNetworkReply *);
    void delCaptureImage(QString path);
    void processImage(const QString& image);

    QByteArray build(QImage*,QString bound);
};
#endif // IMAGEPROCESSOR_H
