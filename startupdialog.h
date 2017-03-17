#ifndef STARTUPDIALOG_H
#define STARTUPDIALOG_H

#include <QDialog>

class StartupDialog : QDialog
{
public:
    StartupDialog();
private:
    quint16 port;
};

#endif // STARTUPDIALOG_H
