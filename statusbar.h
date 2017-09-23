#ifndef STATUSBAR_H
#define STATUSBAR_H

#include <QObject>
#include <QColor>

class StatusBar:public QObject{
    Q_OBJECT
    Q_PROPERTY(bool available READ isAvailable CONSTANT)
    Q_PROPERTY(QColor color  READ  color WRITE setColor)
    Q_PROPERTY(Theme  theme  READ  theme WRITE setTheme)

public:
    explicit StatusBar(QObject *parentObject = nullptr);

    bool isAvailable() const;

    QColor color() const;
    void setColor(const QColor &color);

    enum Theme { Light, Dark };
    Q_ENUM(Theme)

    Theme theme() const;
    void setTheme(Theme theme);

private:
    QColor m_color;
    Theme m_theme;
};

#endif // STATUSBAR_H
