#ifndef __IOSSHAREUTILS_H__
#define __IOSSHAREUTILS_H__

#include "shareutils.h"

class IosShareUtils: public PlatformShareUtils {
    Q_OBJECT
public:
    explicit IosShareUtils(QQuickItem*parent=0);
    Q_INVOKABLE void share(const QString &text, const QUrl &url);
};

#endif
