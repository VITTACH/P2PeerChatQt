#ifndef CAMERACONTROLER_H
#define CAMERACONTROLER_H

#include <QZXING/QZXing.h>
#include <QObject>

class CameraControler: public QObject {
    Q_OBJECT
public:
    explicit CameraControler(QObject *p=0);

signals:
    void errorMessage(QString message);
    void decodingStarted();
    void decodingFinished(bool succeeded);
    void tagFound(QString idScanned);

public slots:
    void decodeQMLImage(QObject *imageObj);

private:
    QZXing m_zxing;
};

#endif // CAMERACONTROLER_H
