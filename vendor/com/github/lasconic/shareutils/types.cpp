#include "shareutils.h"

static void regiserQmlTypes() {
    qmlRegisterType<ShareUtils>("com.lasconic", 1, 0, "ShareUtils");
}

Q_COREAPP_STARTUP_FUNCTION(regiserQmlTypes)
