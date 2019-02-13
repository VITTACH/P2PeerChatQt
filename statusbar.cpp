#include "statusbar.h"

#ifdef Q_OS_ANDROID
#include<QtAndroid>

// View
#define  SYSTEM_UI_FLAG_LIGHT_STATUS_BAR  0x00002000

// WindowManager.LayoutParams
#define FLAG_TRANSLUCENT_STATUS 0x04000000
#define FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS 0x80000000

static QAndroidJniObject getAndroidWindow() {
    QAndroidJniObject window = QtAndroid::androidActivity().callObjectMethod("getWindow", "()Landroid/view/Window;");
    window.callMethod<void>("addFlags", "(I)V", FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
    window.callMethod<void>("clearFlags", "(I)V", FLAG_TRANSLUCENT_STATUS);
    return window;
}
#endif

StatusBar::StatusBar(QObject *parent) : QObject(parent), m_theme(Light) { }

QColor StatusBar::color() const {
    return m_color;
}

void StatusBar::setColor(const QColor &color)
{
    m_color =color;

#ifdef Q_OS_ANDROID
    if (QtAndroid::androidSdkVersion() <= 20)
        return;

    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject window = getAndroidWindow();
        window.callMethod<void>("setStatusBarColor", "(I)V", color.rgba());
        window.callMethod<void>("setNavigationBarColor", "(I)V", QColor(102, 102, 102).rgba());
    });
#endif
}

StatusBar::Theme  StatusBar::theme() const {
    return m_theme;
}

void StatusBar::setTheme(Theme theme){
    m_theme =theme;

#ifdef Q_OS_ANDROID
    if (QtAndroid::androidSdkVersion() < 23)
        return;

    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject window = getAndroidWindow();
        QAndroidJniObject view = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
        int visibility=view.callMethod<int>("getSystemUiVisibility","()I");
        if (theme == Light)
            visibility |= SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
        else
            visibility &=~SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
        view.callMethod<void>("setSystemUiVisibility", "(I)V", visibility);
    });
#endif
}

bool StatusBar::isAvailable() const {
#ifdef Q_OS_ANDROID
    return QtAndroid::androidSdkVersion() >= 21;
#else
    return false;
#endif
}
