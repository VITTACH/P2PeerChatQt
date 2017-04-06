#ifndef ANDROIDSHAREUTILS_H
#define ANDROIDSHAREUTILS_H

#include "../shareutils.h"

class AndroidShareUtils: public PlatformShareUtils {
public:
    AndroidShareUtils(QQuickItem* parent = 0);
    void share(const QString &text, const QUrl &url) override;
};

#endif//ANDROIDSHAREUTILS_H
