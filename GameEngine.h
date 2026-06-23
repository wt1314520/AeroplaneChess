// Module
// File: GameEngine.h   Version: 0.1.0   License: AGPLv3
// Created:  taowang     2026-06-23 10:20:53
// Description:
//

#pragma once
#include<QtQml/qqmlregistration.h>
#include <QObject>
#include <QVector>
#include <QRandomGenerator>

class GameEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int currentPlayer READ currentPlayer NOTIFY currentPlayerChanged)
    Q_PROPERTY(int diceValue READ diceValue NOTIFY diceValueChanged)
    Q_PROPERTY(bool gameOver READ gameOver NOTIFY gameOverChanged)
    Q_PROPERTY(QString message READ message NOTIFY messageChanged)
    QML_ELEMENT
public:
    explicit GameEngine(QObject *parent = nullptr);

    enum PlayerColor { Red = 0, Blue, Green, Yellow };
    Q_ENUM(PlayerColor)

    int currentPlayer() const { return m_currentPlayer; }
    int diceValue() const { return m_diceValue; }
    bool gameOver() const { return m_gameOver; }
    QString message() const { return m_message; }

    // QML可调用的方法
    Q_INVOKABLE void rollDice();           // 仅掷骰，不移动
    Q_INVOKABLE void moveCurrentPiece();   // 移动第一个可动棋子
    Q_INVOKABLE void resetGame();

    // 查询棋子状态
    Q_INVOKABLE int getPiecePosition(int player, int pieceIndex) const;
    Q_INVOKABLE bool isPieceFinished(int player, int pieceIndex) const;
    Q_INVOKABLE int getPlayerRank(int player) const;

signals:
    void currentPlayerChanged();
    void diceValueChanged();
    void gameOverChanged();
    void messageChanged();
    void boardUpdated();

private:
    void nextPlayer();
    void checkGameOver();
    void movePiece(int player, int pieceIndex, int steps);
    bool canMovePiece(int player, int pieceIndex, int steps) const;
    bool hasAnyMovablePiece(int player, int steps) const;
    int findFirstMovablePiece(int player, int steps) const;

    int m_currentPlayer = 0;
    int m_diceValue = 0;
    bool m_gameOver = false;
    QString m_message;

    QVector<QVector<int>> m_pieces;        // [player][pieceIndex] = position
    QVector<QVector<bool>> m_finished;     // 每个棋子是否到达终点
    QVector<int> m_rank;                   // 每个玩家的总排名
    int m_finishedPlayers = 0;

    static constexpr int PIECES_PER_PLAYER = 4;
    static constexpr int BOARD_SIZE = 52;
    static constexpr int WIN_POS = 52;
    static constexpr int BASE_POS = -1;
    static constexpr int START_POS[4] = {0, 13, 26, 39};
};
