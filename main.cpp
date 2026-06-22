// Module
// File: main.cpp   Version: 0.1.0   License: AGPLv3
// Created:taowang       2026-06-22 11:22:03
// Description:
//
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "GameEngine.h"
#include <QString>
int main(int argc, char *argv[])
{
    using namespace Qt::StringLiterals;
    QGuiApplication app(argc, argv);

    qmlRegisterType<GameEngine>("AeroplaneChess", 1, 0, "GameEngine");

    QQmlApplicationEngine engine;

    GameEngine gameEngine;
    engine.rootContext()->setContextProperty("gameEngine", &gameEngine);

    //const QUrl url(u"qrc:/qml/main.qml"_s);
    const QUrl url("file:shishi2/main.qml");  // 相对路径
    engine.load(url);

    return app.exec();
}
