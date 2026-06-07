#pragma once

#include <QObject>

class FlightLogic : public QObject
{
    Q_OBJECT
public:
    explicit FlightLogic(QObject *parent = nullptr);
};

