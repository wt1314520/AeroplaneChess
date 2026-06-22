// Module
// File: main.qml   Version: 0.1.0   License: AGPLv3
// Created: hejiahuan      2026-06-22 14:42:47
// Description:
//
import QtQuick
import QtQuick.Controls
import QtQuick.Window

Window {
    width: 700
    height: 800
    title: "飞行棋"
    visible: true

    property var playerColors: ["red", "blue", "green", "yellow"]
    property var playerNames: ["红方", "蓝方", "绿方", "黄方"]

    Column {
        anchors.centerIn: parent
        spacing: 20

        // 标题
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "✈️ 飞行棋"
            font.pixelSize: 32
            font.bold: true
        }

        // 骰子显示
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 80
            height: 80
            radius: 10
            color: "white"
            border.color: "black"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: gameEngine.diceValue > 0 ? gameEngine.diceValue : "?"
                font.pixelSize: 36
                font.bold: true
            }
        }

        // 当前玩家提示
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "当前: " + playerNames[gameEngine.currentPlayer]
            font.pixelSize: 20
            color: playerColors[gameEngine.currentPlayer]
        }

        // 控制按钮
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15

            Button {
                text: "掷骰子"
                enabled: !gameEngine.gameOver
                onClicked: gameEngine.rollDice()
            }
            Button {
                text: "移动"
                enabled: !gameEngine.gameOver && gameEngine.diceValue > 0
                onClicked: gameEngine.moveCurrentPlayer()
            }
            Button {
                text: "重置"
                onClicked: gameEngine.resetGame()
            }
        }

        // 棋盘
        Rectangle {
            width: 560
            height: 560
            color: "#f5e6ca"
            border.color: "brown"
            border.width: 3
            radius: 10

            Grid {
                id: boardGrid
                rows: 8
                columns: 8
                spacing: 2
                anchors.centerIn: parent

                Repeater {
                    model: 64

                    Rectangle {
                        width: 65
                        height: 65
                        color: {
                            var idx = index
                            var row = Math.floor(idx / 8)
                            var col = idx % 8
                            // 棋盘边缘路径
                            if (row === 0 || row === 7 || col === 0 || col === 7) {
                                return "#d4a574"
                            }
                            // 四个角落
                            if ((row === 0 && col === 0) || (row === 0 && col === 7) ||
                                (row === 7 && col === 0) || (row === 7 && col === 7)) {
                                return "#c4956a"
                            }
                            return (row + col) % 2 === 0 ? "#f5e6ca" : "#e8d5b8"
                        }
                        border.color: "#b8956a"
                        border.width: 1
                        // 显示棋子
                        Item {
                            anchors.fill: parent
                            visible: {
                                var pos = getGridPosition(index)
                                return pos >= 0
                            }

                            function getGridPosition(gridIdx) {
                                // 将棋盘格子索引映射到玩家位置
                                // 简化：直接使用gridIdx作为位置
                                for (var p = 0; p < 4; p++) {
                                    if (gameEngine.getPlayerPosition(p) === gridIdx && !gameEngine.getPlayerFinished(p)) {
                                        return p
                                    }
                                }
                                return -1
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 40
                                height: 40
                                radius: 20
                                color: playerColors[parent.getGridPosition(index)]
                                border.color: "black"
                                border.width: 2

                                Text {
                                    anchors.centerIn: parent
                                    text: parent.parent.getGridPosition(index) + 1
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }
                }
            }
        }

        // 玩家状态
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 30

            Repeater {
                model: 4

                Column {
                    spacing: 2
                    Rectangle {
                        width: 60
                        height: 20
                        color: playerColors[index]
                        radius: 3
                    }
                    Text {
                        text: "位置: " + gameEngine.getPlayerPosition(index) +
                              (gameEngine.getPlayerFinished(index) ? " DUI" : "")
                        font.pixelSize: 12
                    }
                    Text {
                        text: gameEngine.getPlayerRank(index) > 0 ? "排名: " + gameEngine.getPlayerRank(index) : ""
                        font.pixelSize: 12
                        color: "green"
                    }
                }
            }
        }

        // 消息
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: gameEngine.message || "点击掷骰子开始游戏"
            font.pixelSize: 14
            color: "gray"
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            horizontalAlignment: Text.AlignHCenter
        }
    }
}