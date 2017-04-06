#include "shareutils.h"

#ifdef Q_OS_IOS
#include "ios/iosshareutils.h"
#endif

#ifdef Q_OS_ANDROID
#include "android/androidshareutils.h"
#endif

void ShareUtils::share(const QString &text, const QUrl &url)
{
    _pShareUtils->share(text, url);
}

ShareUtils::ShareUtils(QQuickItem *param): QQuickItem(param)
{
#if defined(Q_OS_IOS)
    _pShareUtils = new IosShareUtils(this);
#elif defined(Q_OS_ANDROID)
    _pShareUtils = new AndroidShareUtils(this);
#else
    _pShareUtils = new PlatformShareUtils(this);
#endif
}
