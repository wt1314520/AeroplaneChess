// Module
// File: main.cpp   Version: 0.1.0   License: AGPLv3
// Created:taowang       2026-07-12 19:36:20 update hejiahuan 7-13 15:31:53
// Description:
//
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "GameEngine.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    GameEngine gameEngine;
    engine.rootContext()->setContextProperty("gameEngine", &gameEngine);

    //const QUrl url(u"qrc:/qml/main.qml"_s);
    const QUrl url("file:shishi2/main.qml");  // 相对路径
    engine.load(url);

    return app.exec();
}