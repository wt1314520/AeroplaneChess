// Module
// File: GameEngine.cpp   Version: 0.1.0   License: AGPLv3
// Created:taowang       2026-06-22 11:21:47
// Description:
//
#include "GameEngine.h"
#include <QDebug>

GameEngine::GameEngine(QObject *parent)
    : QObject(parent)
{
    resetGame();
}

void GameEngine::resetGame()
{
    m_currentPlayer = 0;
    m_diceValue = 0;
    m_gameOver = false;
    m_finishedCount = 0;
    m_positions = QVector<int>(4, 0);
    m_finished = QVector<bool>(4, false);
    m_rank = QVector<int>(4, -1);

    emit boardUpdated();
    emit currentPlayerChanged();
    emit gameOverChanged();
    emit message("游戏已重置，红方先手");
}

void GameEngine::rollDice()
{
    if (m_gameOver) {
        emit message("游戏已结束，请点击重置");
        return;
    }

    m_diceValue = QRandomGenerator::global()->bounded(1, 7);
    emit diceValueChanged();

    emit message(QString("玩家 %1 掷出了 %2")
                     .arg(m_currentPlayer + 1)
                     .arg(m_diceValue));

    // 如果掷出6，可以再掷一次（简化规则：掷出6直接移动并保持当前玩家回合）
    // 这里实现为：掷出6后自动再掷一次（连续掷）
    if (m_diceValue == 6) {
        emit message("掷出6！再掷一次");

    }
}

void GameEngine::moveCurrentPlayer()
{
    if (m_gameOver) return;
    if (m_finished[m_currentPlayer]) {
        nextPlayer();
        return;
    }

    int steps = m_diceValue;
    if (steps == 0) {
        nextPlayer();
        return;
    }


    // 如果掷出6，继续当前玩家回合
    if (m_diceValue == 6) {
        emit message("掷出6，再掷一次");

        return;
    }

    nextPlayer();
}

void GameEngine::nextPlayer()
{
    if (m_gameOver) return;

    // 找下一个未完成的玩家
    int next = (m_currentPlayer + 1) % 4;
    int count = 0;
    while (m_finished[next] && count < 4) {
        next = (next + 1) % 4;
        count++;
    }
    if (count >= 4 || m_finishedCount >= 4) {
        checkGameOver();
        return;
    }
    m_currentPlayer = next;
    emit currentPlayerChanged();
    emit message(QString("轮到玩家 %1").arg(m_currentPlayer + 1));
}

void GameEngine::checkGameOver()
{
    if (m_finishedCount >= 4) {
        m_gameOver = true;
        emit gameOverChanged();
        emit message("🎉 游戏结束！所有玩家已到达终点！");
    }
}

int GameEngine::getNextPosition(int player, int steps) const
{
    int pos = m_positions[player];
    if (pos >= WIN_POS) return WIN_POS;
    int newPos = pos + steps;
    return newPos;
}

int GameEngine::getPlayerPosition(int playerIndex) const
{
    if (playerIndex < 0 || playerIndex >= 4) return 0;
    return m_positions[playerIndex];
}

bool GameEngine::getPlayerFinished(int playerIndex) const
{
    if (playerIndex < 0 || playerIndex >= 4) return false;
    return m_finished[playerIndex];
}

int GameEngine::getPlayerRank(int playerIndex) const
{
    if (playerIndex < 0 || playerIndex >= 4) return -1;
    return m_rank[playerIndex];
}