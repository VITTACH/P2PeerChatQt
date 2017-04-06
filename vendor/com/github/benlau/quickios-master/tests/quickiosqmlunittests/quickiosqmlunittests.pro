#-------------------------------------------------
#
# Project created by QtCreator 2014-11-25T00:15:42
#
#-------------------------------------------------

QT       += testlib qmltest

QT       -= gui

TARGET = tst_quickiosqmlunittests
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app


SOURCES += main.cpp \
    testenv.cpp
DEFINES += SRCDIR=\\\"$$PWD/\\\"

include(../../quickios.pri)

OTHER_FILES += \
    tst_SegmentedControlTabView.qml

DISTFILES += \
    tst_ViewController_presentViewController.qml \
    tst_NavigationController.qml \
    SampleView.qml \
    tst_system.qml \
    tst_TableSection.qml \
    tst_ToolBar.qml \
    tst_BarButtonItem.qml \
    ViewControllerListener.qml \
    tst_NavigationController_gc.qml \
    tst_SegmentedViewController.qml \
    tst_NavigationBar.qml

HEADERS += \
    testenv.h
