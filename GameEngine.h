// Module
// File: GameEngine.h   Version: 0.1.0   License: AGPLv3
// Created: taowang      2026-06-22 11:48:32
// Description:
//
#include <QObject>
#include <QVector>
#include <QRandomGenerator>

class GameEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int currentPlayer READ currentPlayer NOTIFY currentPlayerChanged)
    Q_PROPERTY(int diceValue READ diceValue NOTIFY diceValueChanged)
    Q_PROPERTY(bool gameOver READ gameOver NOTIFY gameOverChanged)

public:
    explicit GameEngine(QObject *parent = nullptr);

    enum PlayerColor { Red = 0, Blue, Green, Yellow };
    Q_ENUM(PlayerColor)

    int currentPlayer() const { return m_currentPlayer; }
    int diceValue() const { return m_diceValue; }
    bool gameOver() const { return m_gameOver; }

    Q_INVOKABLE void rollDice();
    Q_INVOKABLE void moveCurrentPlayer();
    Q_INVOKABLE void resetGame();

    Q_INVOKABLE int getPlayerPosition(int playerIndex) const;
    Q_INVOKABLE bool getPlayerFinished(int playerIndex) const;
    Q_INVOKABLE int getPlayerRank(int playerIndex) const;

signals:
    void currentPlayerChanged();
    void diceValueChanged();
    void gameOverChanged();
    void boardUpdated();
    void message(QString msg);

private:
    void nextPlayer();
    void checkGameOver();
    int getNextPosition(int player, int steps) const;

    int m_currentPlayer = 0;
    int m_diceValue = 0;
    bool m_gameOver = false;
    int m_finishedCount = 0;

    QVector<int> m_positions;     // 每个玩家的当前位置 (0~51, 52表示到达终点)
    QVector<bool> m_finished;     // 是否已完成
    QVector<int> m_rank;          // 完成排名

    static constexpr int BOARD_SIZE = 52;
    static constexpr int WIN_POS = 52;
};
