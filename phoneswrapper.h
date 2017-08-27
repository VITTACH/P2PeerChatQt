#ifndef WRAPPER_H
#define WRAPPER_H
#include <QObject>
#include <QString>
#if defined(Q_OS_IOS)
    #include <QUrl>
    #include <QDesktopServices>
    #elif defined(Q_OS_ANDROID)
    #include <QtAndroid>
    #include <QAndroidJniObject>
#endif

#include <QDesktopServices>
#include <QUrl>

class Wrapper: public QObject {
    Q_OBJECT
public:
    Q_INVOKABLE void directCall(QString number);
};

#endif // WRAPPER_H
