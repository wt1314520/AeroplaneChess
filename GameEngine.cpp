// Module
// File: GameEngine.cpp   Version: 0.1.0   License: AGPLv3
// Created:taowang       2026-06-23 10:21:09
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
    m_finishedPlayers = 0;
    m_rank = QVector<int>(4, -1);

    m_pieces.clear();
    m_finished.clear();
    for (int p = 0; p < 4; ++p) {
        QVector<int> positions(PIECES_PER_PLAYER, BASE_POS);
        QVector<bool> fins(PIECES_PER_PLAYER, false);
        m_pieces.append(positions);
        m_finished.append(fins);
    }

    m_message = "游戏已重置，红方先手";
    emit messageChanged();
    emit boardUpdated();
    emit currentPlayerChanged();
    emit gameOverChanged();
}

void GameEngine::rollDice()
{
    if (m_gameOver) {
        m_message = "游戏已结束，请点击重置";
        emit messageChanged();
        return;
    }

    m_diceValue = QRandomGenerator::global()->bounded(1, 7);
    emit diceValueChanged();

    m_message = QString("玩家 %1 掷出了 %2").arg(m_currentPlayer + 1).arg(m_diceValue);
    emit messageChanged();

    // 检查是否有棋子可动，若无可动则提示
    if (!hasAnyMovablePiece(m_currentPlayer, m_diceValue)) {
        m_message += "，没有棋子可移动，请点击'移动'无效，将自动换人";
        emit messageChanged();
        // 这里不自动换人，等用户点击移动时再判断
    }
}

void GameEngine::moveCurrentPiece()
{
    if (m_gameOver) {
        m_message = "游戏已结束";
        emit messageChanged();
        return;
    }
    if (m_diceValue == 0) {
        m_message = "请先掷骰子";
        emit messageChanged();
        return;
    }

    int pieceIdx = findFirstMovablePiece(m_currentPlayer, m_diceValue);
    if (pieceIdx == -1) {
        m_message = "没有棋子可移动，换人";
        emit messageChanged();
        nextPlayer();
        return;
    }

    movePiece(m_currentPlayer, pieceIdx, m_diceValue);

    // 如果掷出6，奖励再掷一次（不换人）
    if (m_diceValue == 6) {
        m_message += "，掷出6！再掷一次";
        emit messageChanged();
        // 不换人，骰子值保留，等待用户再次掷骰
    } else {
        nextPlayer();
    }
}

void GameEngine::movePiece(int player, int pieceIndex, int steps)
{
    int &pos = m_pieces[player][pieceIndex];
    if (pos == BASE_POS) {
        // 出基地（必须 steps==6）
        pos = START_POS[player];
        m_message = QString("玩家 %1 的棋子 %2 从基地出发！").arg(player + 1).arg(pieceIndex + 1);
    } else {
        int newPos = pos + steps;
        if (newPos >= WIN_POS) {
            pos = WIN_POS;
            m_finished[player][pieceIndex] = true;
            m_message = QString("玩家 %1 的棋子 %2 到达终点！").arg(player + 1).arg(pieceIndex + 1);

            // 检查该玩家是否所有棋子都完成
            bool allFinished = true;
            for (int i = 0; i < PIECES_PER_PLAYER; ++i) {
                if (!m_finished[player][i]) { allFinished = false; break; }
            }
            if (allFinished) {
                m_rank[player] = ++m_finishedPlayers;
                m_message += QString(" 玩家 %1 全部完成！排名第 %2").arg(player + 1).arg(m_finishedPlayers);
                checkGameOver();
            }
        } else {
            // 检查目标位置是否有其他玩家的棋子（非终点）
            bool occupied = false;
            int targetPlayer = -1;
            int targetPiece = -1;
            for (int p = 0; p < 4; ++p) {
                if (p == player) continue;
                for (int i = 0; i < PIECES_PER_PLAYER; ++i) {
                    if (!m_finished[p][i] && m_pieces[p][i] == newPos) {
                        occupied = true;
                        targetPlayer = p;
                        targetPiece = i;
                        break;
                    }
                }
                if (occupied) break;
            }
            if (occupied) {
                m_pieces[targetPlayer][targetPiece] = BASE_POS;
                m_finished[targetPlayer][targetPiece] = false;
                m_message += QString("，撞到了玩家 %1 的棋子 %2，打回基地！").arg(targetPlayer + 1).arg(targetPiece + 1);
            }
            pos = newPos;
        }
    }
    emit boardUpdated();
    emit messageChanged();
}

bool GameEngine::canMovePiece(int player, int pieceIndex, int steps) const
{
    int pos = m_pieces[player][pieceIndex];
    if (m_finished[player][pieceIndex]) return false;
    if (pos == BASE_POS) {
        return steps == 6;
    }
    return (pos + steps <= WIN_POS);
}

bool GameEngine::hasAnyMovablePiece(int player, int steps) const
{
    for (int i = 0; i < PIECES_PER_PLAYER; ++i) {
        if (canMovePiece(player, i, steps)) return true;
    }
    return false;
}

int GameEngine::findFirstMovablePiece(int player, int steps) const
{
    for (int i = 0; i < PIECES_PER_PLAYER; ++i) {
        if (canMovePiece(player, i, steps)) return i;
    }
    return -1;
}

void GameEngine::nextPlayer()
{
    if (m_gameOver) return;
    int next = (m_currentPlayer + 1) % 4;
    int count = 0;
    while (m_rank[next] != -1 && count < 4) {
        next = (next + 1) % 4;
        count++;
    }
    if (count >= 4) {
        checkGameOver();
        return;
    }
    m_currentPlayer = next;
    emit currentPlayerChanged();
    m_message = QString("轮到玩家 %1").arg(m_currentPlayer + 1);
    emit messageChanged();
}

void GameEngine::checkGameOver()
{
    if (m_finishedPlayers >= 4) {
        m_gameOver = true;
        emit gameOverChanged();
        m_message = " 游戏结束！所有玩家已完成！";
        emit messageChanged();
    }
}

int GameEngine::getPiecePosition(int player, int pieceIndex) const
{
    if (player < 0 || player >= 4 || pieceIndex < 0 || pieceIndex >= PIECES_PER_PLAYER)
        return -2;
    return m_pieces[player][pieceIndex];
}

bool GameEngine::isPieceFinished(int player, int pieceIndex) const
{
    if (player < 0 || player >= 4 || pieceIndex < 0 || pieceIndex >= PIECES_PER_PLAYER)
        return false;
    return m_finished[player][pieceIndex];
}

int GameEngine::getPlayerRank(int player) const
{
    if (player < 0 || player >= 4) return -1;
    return m_rank[player];
}