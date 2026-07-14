// Module
// File: main.cpp   Version: 0.1.0   License: AGPLv3
// Created: hejiahuan wangtao     2026-07-14 12:13:11
// Description:
//
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Window {
    width: 720
    height: 850
    title: "飞行棋"
    visible: true

    // 玩家配置：红、蓝、黄、绿（对应四个角落基地）
    property var playerColors: ["#e74c3c", "#3498db", "#f1c40f", "#2ecc71"]
    property var playerNames: ["红方", "蓝方", "黄方", "绿方"]

    // 如有飞机图片可替换为相对路径，默认用彩色圆形
    property var planeImages: [
        "/root/images/plane_red.png",
        "/root/images/plane_blue.png",
        "/root/images/plane_yellow.png",
        "/root/images/plane_green.png"
    ]
    property int pieceSize: 32

    // 52个轨道格子的中心坐标（顺时针方向，0-51）
    property var gridPositions: [
        // 0-12: 下方横轨，右→左（红方起点开始）
        [460, 460], [430, 460], [400, 460], [370, 460], [340, 460], [310, 460], [280, 460],
        [250, 460], [220, 460], [190, 460], [160, 460], [130, 460], [100, 460],
        // 13-25: 左侧竖轨，下→上
        [100, 430], [100, 400], [100, 370], [100, 340], [100, 310], [100, 280], [100, 250],
        [100, 220], [100, 190], [100, 160], [100, 130], [100, 100], [100, 70],
        // 26-38: 上方横轨，左→右
        [130, 70], [160, 70], [190, 70], [220, 70], [250, 70], [280, 70], [310, 70],
        [340, 70], [370, 70], [400, 70], [430, 70], [460, 70], [490, 70],
        // 39-51: 右侧竖轨，上→下
        [490, 100], [490, 130], [490, 160], [490, 190], [490, 220], [490, 250], [490, 280],
        [490, 310], [490, 340], [490, 370], [490, 400], [490, 430], [490, 460]
    ]

    // 四个基地的停机位坐标（pos=-1时）：[player][pieceIndex] = [x,y]
    property var basePositions: [
        [[500, 500], [535, 500], [500, 535], [535, 535]], // 红方（右下）
        [[500, 45], [535, 45], [500, 80], [535, 80]],    // 蓝方（右上）
        [[45, 45], [80, 45], [45, 80], [80, 80]],        // 黄方（左上）
        [[45, 500], [80, 500], [45, 535], [80, 535]]     // 绿方（左下）
    ]

    // 终点位置坐标（pos=52时）：[player] = [x,y]
    property var finishPositions: [
        [290, 330], // 红方（中心下方）
        [330, 290], // 蓝方（中心右方）
        [290, 250], // 黄方（中心上方）
        [250, 290]  // 绿方（中心左方）
    ]

    Column {
        anchors.centerIn: parent
        spacing: 12

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "✈️ 飞行棋"
            font.pixelSize: 28
            font.bold: true
        }

        // 骰子显示（TapHandler 点击掷骰，Input Handler 体系）
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 70
            height: 70
            radius: 10
            color: "white"
            border.color: "#333"
            border.width: 2

            // Input Handler: TapHandler 处理指针点击
            TapHandler {
                onTapped: {
                    if (!gameEngine.gameOver && gameEngine.diceValue === 0) {
                        gameEngine.rollDice()
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: gameEngine.diceValue > 0 ? gameEngine.diceValue : "?"
                font.pixelSize: 32
                font.bold: true
                color: "#333"
            }
        }

        // 当前玩家提示
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            Rectangle {
                width: 30
                height: 30
                radius: 15
                color: playerColors[gameEngine.currentPlayer]
                border.color: "white"
                border.width: 2
            }
            Text {
                text: "当前: " + playerNames[gameEngine.currentPlayer]
                font.pixelSize: 18
                color: playerColors[gameEngine.currentPlayer]
                font.bold: true
            }
        }

        // 控制按钮（全部改用 Rectangle + TapHandler，不使用 Button/MouseArea）
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15

            // 掷骰子按钮
            Rectangle {
                width: 100
                height: 40
                radius: 6
                color: tapRoll.pressed ? "#d5dbdb" : "#ecf0f1"
                border.color: "#bdc3c7"
                border.width: 1

                TapHandler {
                    id: tapRoll
                    onTapped: {
                        if (!gameEngine.gameOver && gameEngine.diceValue === 0) {
                            gameEngine.rollDice()
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "🎲 掷骰子"
                    font.pixelSize: 16
                }
            }

            // 移动按钮
            Rectangle {
                width: 100
                height: 40
                radius: 6
                color: tapMove.pressed ? "#d5dbdb" : "#ecf0f1"
                border.color: "#bdc3c7"
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
                    text: "🚀 移动"
                    font.pixelSize: 16
                }
            }

            // 重置游戏按钮
            Rectangle {
                width: 110
                height: 40
                radius: 6
                color: tapReset.pressed ? "#d5dbdb" : "#ecf0f1"
                border.color: "#bdc3c7"
                border.width: 1

                TapHandler {
                    id: tapReset
                    onTapped: gameEngine.resetGame()
                }

                Text {
                    anchors.centerIn: parent
                    text: "🔄 重置游戏"
                    font.pixelSize: 16
                }
            }
        }

        // 棋盘容器
        Rectangle {
            id: boardContainer
            width: 580
            height: 580
            color: "transparent"
            border.color: "#8B4513"
            border.width: 3
            radius: 5

            // 棋盘背景图（如有请替换为相对路径）
            Image {
                id: boardImage
                anchors.fill: parent
                source: "/root/images/board.png"
                fillMode: Image.PreserveAspectFit
                asynchronous: true

                // 图片加载失败时显示纯色棋盘背景
                Rectangle {
                    anchors.fill: parent
                    color: "#f5e6d3"
                    visible: boardImage.status === Image.Error
                    // 绘制简易基地
                    Rectangle { x:0; y:0; width:140; height:140; color:"#f1c40f"; radius:10 }
                    Rectangle { x:440; y:0; width:140; height:140; color:"#3498db"; radius:10 }
                    Rectangle { x:0; y:440; width:140; height:140; color:"#2ecc71"; radius:10 }
                    Rectangle { x:440; y:440; width:140; height:140; color:"#e74c3c"; radius:10 }
                    // 绘制中心十字
                    Rectangle { x:275; y:140; width:30; height:300; color:"#ddd" }
                    Rectangle { x:140; y:275; width:300; height:30; color:"#ddd" }
                    Rectangle { x:260; y:260; width:60; height:60; color:"#f39c12"; radius:5 }
                }
            }

            // 棋子层
            Item {
                id: pieceLayer
                anchors.fill: parent

                Repeater {
                    model: 16 // 4玩家 * 4棋子
                    delegate: Item {
                        id: pieceDelegate

                        // 修复：player和piece定义在delegate内部，可正确访问index
                        readonly property int player: Math.floor(index / 4)
                        readonly property int piece: index % 4

                        width: pieceSize
                        height: pieceSize

                        // 依赖updateTick触发位置和可见性刷新
                        readonly property int refreshTick: gameEngine.updateTick
                        readonly property int currentPos: gameEngine.getPiecePosition(player, piece)
                        readonly property bool isFinished: gameEngine.isPieceFinished(player, piece)

                        // 计算棋子目标坐标
                        readonly property real targetX: {
                            refreshTick // 触发绑定刷新
                            if (currentPos === -1) { // 基地
                                return basePositions[player][piece][0] - pieceSize/2
                            } else if (currentPos === 52) { // 终点
                                return finishPositions[player][0] - pieceSize/2
                            } else if (currentPos >=0 && currentPos < 52) { // 轨道上
                                var offset = getSameGridOffset()
                                return gridPositions[currentPos][0] - pieceSize/2 + offset.x
                            }
                            return -100 // 隐藏
                        }

                        readonly property real targetY: {
                            refreshTick // 触发绑定刷新
                            if (currentPos === -1) { // 基地
                                return basePositions[player][piece][1] - pieceSize/2
                            } else if (currentPos === 52) { // 终点
                                return finishPositions[player][1] - pieceSize/2
                            } else if (currentPos >=0 && currentPos < 52) { // 轨道上
                                var offset = getSameGridOffset()
                                return gridPositions[currentPos][1] - pieceSize/2 + offset.y
                            }
                            return -100 // 隐藏
                        }

                        x: targetX
                        y: targetY

                        // 平滑移动动画
                        Behavior on x {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutQuad
                            }
                        }
                        Behavior on y {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutQuad
                            }
                        }

                        // 棋子显示：圆形（优先用图片，图片不存在则用纯色圆）
                        Image {
                            id: pieceImg
                            anchors.fill: parent
                            source: planeImages[player]
                            fillMode: Image.PreserveAspectFit
                            visible: status !== Image.Error

                            // Input Handler: TapHandler 处理棋子点击选中（替代 MouseArea）
                            TapHandler {
                                onTapped: {
                                    console.log("选中棋子: " + playerNames[pieceDelegate.player] + " 第" + (piece+1) + "子")
                                    if (!gameEngine.gameOver && gameEngine.diceValue > 0
                                        && pieceDelegate.player === gameEngine.currentPlayer) {
                                        gameEngine.selectPiece(pieceDelegate.player, piece)
                                    }
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: pieceSize/2
                                color: playerColors[player]
                                border.color: "white"
                                border.width: 2
                                visible: pieceImg.status === Image.Error

                                // 棋子编号
                                Text {
                                    anchors.centerIn: parent
                                    text: piece + 1
                                    font.pixelSize: 12
                                    color: "white"
                                    font.bold: true
                                }
                            }
                        }

                        // 计算同一格子内多个棋子的偏移，避免重叠
                        function getSameGridOffset() {
                            var count = 0
                            var order = 0
                            for (var pp = 0; pp < 4; ++pp) {
                                for (var pi2 = 0; pi2 < 4; ++pi2) {
                                    if (gameEngine.getPiecePosition(pp, pi2) === currentPos) {
                                        if (pp === player && pi2 === piece) {
                                            order = count
                                        }
                                        count++
                                    }
                                }
                            }
                            var offsetStep = 8
                            var row = Math.floor(order / 2)
                            var col = order % 2
                            return Qt.point(col * offsetStep - (count>1?offsetStep/2:0),
                                            row * offsetStep - (count>2?offsetStep/2:0))
                        }
                    }
                }
            }
        }

        // 玩家状态栏
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 25
            Repeater {
                model: 4
                Column {
                    spacing: 3
                    Rectangle {
                        width: 26
                        height: 26
                        radius: 13
                        color: playerColors[index]
                        border.color: "white"
                        border.width: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: playerNames[index]
                        font.pixelSize: 12
                        font.bold: true
                        color: playerColors[index]
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "排名: " + (gameEngine.getPlayerRank(index) > 0 ? gameEngine.getPlayerRank(index) : "进行中")
                        font.pixelSize: 11
                    }
                    // 四个棋子状态
                    Row {
                        spacing: 4
                        Repeater {
                            model: 4
                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                color: {
                                    var pos = gameEngine.getPiecePosition(index, modelData)
                                    if (pos === -1) return "#bbb" // 基地灰色
                                    if (pos === 52) return "#f1c40f" // 终点金色
                                    return playerColors[index] // 棋盘上彩色
                                }
                                border.color: "#333"
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData + 1
                                    font.pixelSize: 9
                                    color: "white"
                                }
                            }
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            var allDone = true
                            for (var i=0; i<4; ++i) {
                                if (!gameEngine.isPieceFinished(index, i)) { allDone = false; break; }
                            }
                            return allDone ? "✅ 完成" : ""
                        }
                        font.pixelSize: 10
                        color: "#27ae60"
                    }
                }
            }
        }

        // 消息提示
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: gameEngine.message || "点击掷骰子开始游戏"
            font.pixelSize: 14
            color: "#555"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width * 0.9
            font.bold: true
        }
    }
}
