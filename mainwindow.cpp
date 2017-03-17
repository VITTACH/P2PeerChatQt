#include "client.h"
#include "mainwindow.h"

#include <QTextEdit>
#include <QLineEdit>
#include <QVBoxLayout>
#include <QPushButton>

MainWindow::MainWindow() {
    chatBox=new QTextEdit();
    chatBox->setReadOnly(1);

    input = new QLineEdit();
    connect(input, SIGNAL(returnPressed()), this, SLOT(sendMessage()));

    submitButton = new QPushButton("Send...");
    connect(submitButton,SIGNAL(clicked()), this, SLOT(sendMessage()));

    ipField = new QLineEdit("127.0.0.1");
    connect(ipField, SIGNAL(returnPressed()), this, SLOT(connectionChange()));

    portField = new QLineEdit("9000");
    connect(portField,SIGNAL(returnPressed()),this, SLOT(connectionChange()));

    setWindowTitle("P2P updChat dev:VITTACH");

    QVBoxLayout *mainLayout=new QVBoxLayout();
    QHBoxLayout *testLayout=new QHBoxLayout();

    testLayout->addWidget(ipField);
    testLayout->addWidget(portField);

    mainLayout->addLayout(testLayout);
    mainLayout->addWidget(chatBox);
    mainLayout->addWidget(input);
    mainLayout->addWidget(submitButton);

    setLayout(mainLayout);
}

void MainWindow::sendMessage() {
    emit sendMessage(input->text());
    chatBox->append("My: " + input->text());
}

void MainWindow::displayNewMsg(QString msg, QString sender) {
    QString newmsg("<b>" + sender + "</b>");
    newmsg.append(": "+msg);
    chatBox->append(newmsg);
}

void MainWindow::connectionChange() {
    emit connectToChange(ipField->text(), portField->text());
}
