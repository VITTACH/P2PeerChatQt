#ifndef SHAREUTILS_H
#define SHAREUTILS_H

#include <QQuickItem>

class PlatformShareUtils: public QQuickItem {
public:
    PlatformShareUtils(QQuickItem*parent=0): QQuickItem(parent){}
    virtual ~PlatformShareUtils() {}
    virtual void share(const QString &anytext, const QUrl &url) {
        qDebug() << anytext << url;
    }
};

class ShareUtils: public QQuickItem {
    Q_OBJECT
    PlatformShareUtils* _pShareUtils;
public:
    explicit ShareUtils(QQuickItem *param = 0);
    Q_INVOKABLE void share(const QString &text, const QUrl &url);
};

#endif //SHAREUTILS_H
