// Module
// File: main.cpp   Version: 0.1.0   License: AGPLv3
// Created:taowang       2026-07-12 19:36:20
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

    const QUrl url("file:AeroplaneChess/main.qml");
    engine.load(url);

    return app.exec();
}