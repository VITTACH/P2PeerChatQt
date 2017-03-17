#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QWidget>

class Client;
class QString;
class QTextEdit;
class QLineEdit;
class QPushButton;

class MainWindow: public QWidget {
    Q_OBJECT
public:
    MainWindow();
signals:
    void sendMessage(QString message);
    void connectToChange(QString address, QString port);
private slots:
    void sendMessage();
    void displayNewMsg(QString message, QString sender);
    void connectionChange();
private:
    QLineEdit *input;
    QTextEdit *chatBox;
    QPushButton *submitButton;

    // This will be better, for now its just easier way:
    QLineEdit *ipField;
    QLineEdit *portField;
};


#endif // MAINWINDOW_H
