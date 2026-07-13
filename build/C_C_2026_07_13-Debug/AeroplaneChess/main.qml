import QtQuick
import QtQuick.Controls
import QtQuick.Window

Window {
    width: 720
    height: 850
    title: "飞行棋 - 标准规则 (无图片)"
    visible: true

    property var playerColors: ["red", "blue", "green", "yellow"]
    property var playerNames: ["红方", "蓝方", "绿方", "黄方"]
    property var planeImages: [
        "/root/images/plane_red.png",
        "/root/images/plane_blue.png",
        "/root/images/plane_green.png",
        "/root/images/plane_yellow.png"
    ]
    property int pieceSize: 30
    // 修复：补充 pieceRadius 定义，由 pieceSize 自动计算
    property int pieceRadius: pieceSize / 2

    // ========== 坐标映射表（52个格子，索引0~51）==========
    property var gridPositions: [
        [50, 500], [85, 500], [120, 500], [155, 500], [190, 500], [225, 500], [260, 500], [295, 500], [330, 500], [365, 500], [400, 500], [435, 500], [470, 500], [505, 500],
        [505, 465], [505, 430], [505, 395], [505, 360], [505, 325], [505, 290], [505, 255], [505, 220], [505, 185], [505, 150], [505, 115], [505, 80], [505, 45],
        [470, 45], [435, 45], [400, 45], [365, 45], [330, 45], [295, 45], [260, 45], [225, 45], [190, 45], [155, 45], [120, 45], [85, 45], [50, 45],
        [50, 80], [50, 115], [50, 150], [50, 185], [50, 220], [50, 255], [50, 290], [50, 325], [50, 360], [50, 395], [50, 430], [50, 465]
    ]

    Column {
        anchors.centerIn: parent
        spacing: 12

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: " 飞行棋 (每人4子)"
            font.pixelSize: 28
            font.bold: true
        }

        // 骰子
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 70
            height: 70
            radius: 10
            color: "white"
            border.color: "black"
            border.width: 2

            TapHandler {
                onTapped: {
                    if (!gameEngine.gameOver) {
                        gameEngine.rollDice()
                    }
                }
            }

            TextInput {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: gameEngine.diceValue > 0 ? gameEngine.diceValue : "?"
                font.pixelSize: 32
                font.bold: true
            }
        }

        // 当前玩家
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            Rectangle {
                width: 20
                height: 20
                radius: 10
                color: playerColors[gameEngine.currentPlayer]
                border.color: "black"
            }
            Text {
                text: "当前: " + playerNames[gameEngine.currentPlayer]
                font.pixelSize: 18
                color: playerColors[gameEngine.currentPlayer]
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15

            // 掷骰子按钮
            Rectangle {
                width: 80
                height: 36
                radius: 6
                color: tapRoll.pressed ? "#d0d0d0" : "#f0f0f0"
                border.color: "#999"
                border.width: 1

                TapHandler {
                    id: tapRoll
                    onTapped: {
                        if (!gameEngine.gameOver) {
                            gameEngine.rollDice()
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: " 掷骰子"
                    font.pixelSize: 14
                }
            }

            // 移动按钮
            Rectangle {
                width: 80
                height: 36
                radius: 6
                color: tapMove.pressed ? "#d0d0d0" : "#f0f0f0"
                border.color: "#999"
                border.width: 1

                TapHandler {
                    id: tapMove
                    onTapped: {
                        if (!gameEngine.gameOver && gameEngine.diceValue > 0) {
                            gameEngine.moveCurrentPiece()
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: " 移动"
                    font.pixelSize: 14
                }
            }

            // 重置按钮
            Rectangle {
                width: 80
                height: 36
                radius: 6
                color: tapReset.pressed ? "#d0d0d0" : "#f0f0f0"
                border.color: "#999"
                border.width: 1

                TapHandler {
                    id: tapReset
                    onTapped: gameEngine.resetGame()
                }

                Text {
                    anchors.centerIn: parent
                    text: "重置"
                    font.pixelSize: 14
                }
            }
        }

        // 棋盘 (8x8)
        Rectangle {
            width: 580
            height: 580
            color: "#f5e6ca"
            border.color: "brown"
            border.width: 3
            radius: 8

            Grid {
                id: boardGrid
                rows: 8
                columns: 8
                spacing: 2
                anchors.centerIn: parent

                Repeater {
                    model: 64

                    Rectangle {
                        width: 66
                        height: 66
                        color: {
                            var idx = index
                            var row = Math.floor(idx / 8)
                            var col = idx % 8
                            if (row === 0 || row === 7 || col === 0 || col === 7)
                                return "#d4a574"
                            if ((row===0 && col===0) || (row===0 && col===7) ||
                                (row===7 && col===0) || (row===7 && col===7))
                                return "#c4956a"
                            return (row + col) % 2 === 0 ? "#f5e6ca" : "#e8d5b8"
                        }
                        border.color: "#b8956a"
                        border.width: 1

                        // 显示该格子上的所有棋子
                        Item {
                            anchors.fill: parent
                            property var piecesHere: []

                            function updatePieces() {
                                piecesHere = []
                                for (var p = 0; p < 4; ++p) {
                                    for (var i = 0; i < 4; ++i) {
                                        var pos = gameEngine.getPiecePosition(p, i)
                                        if (pos === index) {
                                            piecesHere.push({player: p, piece: i})
                                        }
                                    }
                                }
                            }

                            Connections {
                                target: gameEngine
                                function onBoardUpdated() {
                                    parent.updatePieces()
                                }
                            }

                            Component.onCompleted: updatePieces()

                            Repeater {
                                model: parent.piecesHere

                                Rectangle {
                                    width: pieceRadius * 2
                                    height: pieceRadius * 2
                                    radius: pieceRadius
                                    color: playerColors[modelData.player]
                                    border.color: "black"
                                    border.width: 1
                                    x: (model.index % 2) * (width + 2)
                                    y: Math.floor(model.index / 2) * (height + 2)

                                    // TapHandler 处理棋子点击（Input Handler 体系，不使用 MouseArea）
                                    TapHandler {
                                        onTapped: {
                                            console.log("选中棋子: 玩家" + (modelData.player+1) + " 第" + (modelData.piece+1) + "子")
                                            if (!gameEngine.gameOver && gameEngine.diceValue > 0
                                                && modelData.player === gameEngine.currentPlayer) {
                                                gameEngine.selectPiece(modelData.player, modelData.piece)
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: (modelData.player+1) + "-" + (modelData.piece+1)
                                        font.pixelSize: 10
                                        color: "white"
                                        style: Text.Outline
                                        styleColor: "black"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // 玩家状态显示
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            Repeater {
                model: 4
                Column {
                    spacing: 2
                    Rectangle {
                        width: 40
                        height: 16
                        color: playerColors[index]
                        radius: 4
                    }
                    Text {
                        text: "排名: " + (gameEngine.getPlayerRank(index) > 0 ? gameEngine.getPlayerRank(index) : "未完成")
                        font.pixelSize: 11
                    }
                    Row {
                        spacing: 3
                        Repeater {
                            model: 4
                            Rectangle {
                                width: 16
                                height: 16
                                radius: 8
                                color: {
                                    var pos = gameEngine.getPiecePosition(index, modelData)
                                    if (pos === -1) return "gray"
                                    if (pos === 52) return "gold"
                                    return playerColors[index]
                                }
                                border.color: "black"
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData + 1
                                    font.pixelSize: 8
                                    color: "white"
                                }
                            }
                        }
                    }
                    Text {
                        text: {
                            var allDone = true
                            for (var i=0; i<4; ++i) {
                                if (!gameEngine.isPieceFinished(index, i)) { allDone = false; break; }
                            }
                            return allDone ? " 完成" : ""
                        }
                        font.pixelSize: 10
                        color: "green"
                    }
                }
            }
        }

        // 消息框
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: gameEngine.message || "点击掷骰子开始"
            font.pixelSize: 13
            color: "gray"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width * 0.9
        }
    }
}

