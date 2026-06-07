#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "flightlogic.h"
#include "player.h"

using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<FlightLogic>("FlightLogic", 1, 0, "FlightLogic");
    qmlRegisterType<Player>("FlightLogic", 1, 0, "Player");

    QQmlApplicationEngine engine;
    engine.load(u"qrc:/FlightChess/qml/main.qml"_s);

    return app.exec();
}
