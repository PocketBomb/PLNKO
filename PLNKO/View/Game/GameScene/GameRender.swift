
import SpriteKit
import Foundation

class GameRenderer {
    
    var gameLogic: GameLogic
    let blockSize: CGFloat = 75
    let spacing: CGFloat = 8
    
    init(gameLogic: GameLogic) {
        self.gameLogic = gameLogic
    }
    
    func setupGameBoard(on scene: SKScene, gameBoard: GameBoard) {
        let startX = (scene.size.width - 249) / 2
        let startY = scene.size.height - 60
        let blockSize: CGFloat = 75
        let spacing: CGFloat = 8

        for row in 0..<gameBoard.elements.count {
            for col in 0..<gameBoard.elements[row].count {
                let xPos = startX + CGFloat(col) * (blockSize + spacing)
                let yPos = startY - CGFloat(row) * (blockSize + spacing)
                let block = SKSpriteNode(imageNamed: "gameBoardBlock")
                block.size = CGSize(width: blockSize, height: blockSize)
                block.position = CGPoint(x: xPos, y: yPos)
                scene.addChild(block)

                for (name, offset) in gameBoard.elements[row][col] {
                    let element = SKSpriteNode(imageNamed: name)
                    element.name = name
                    element.position = CGPoint(x: xPos + offset.x, y: yPos + offset.y)
                    scene.addChild(element)
                    gameBoard.elementNodes[row][col].append(element)
                }
            }
        }
    }

    func handleStartBlockTouch(location: CGPoint, gameBoard: GameBoard) -> Int? {
        for (index, block) in gameBoard.startBlockNodes.enumerated() {
            if block.contains(location) {
                return index
            }
        }
        return nil
    }

    func handleGameBoardTouch(location: CGPoint, gameBoard: GameBoard) -> (Int, Int)? {
        let startX = (gameBoard.size.width - 249) / 2
        let startY = gameBoard.size.height - 60

        for row in 0..<gameBoard.elements.count {
            for col in 0..<gameBoard.elements[row].count {
                let xPos = startX + CGFloat(col) * (blockSize + spacing)
                let yPos = startY - CGFloat(row) * (blockSize + spacing)
                let blockRect = CGRect(x: xPos - blockSize / 2, y: yPos - blockSize / 2, width: blockSize, height: blockSize)
                if blockRect.contains(location) && gameBoard.elements[row][col].isEmpty {
                    return (row, col)
                }
            }
        }
        return nil
    }

    func updateGameBoard(on scene: SKScene, gameBoard: GameBoard) {
        let startX = (scene.size.width - 249) / 2
        let startY = scene.size.height - 60
        let blockSize: CGFloat = 75
        let spacing: CGFloat = 8

        // Шаг 1: Создаем массив для хранения узлов, которые нужно удалить
        var nodesToRemove: [SKSpriteNode] = []

        // Шаг 2: Проходим по всем клеткам игрового поля
        for row in 0..<gameBoard.elements.count {
            for col in 0..<gameBoard.elements[row].count {
                // Удаляем старые узлы из текущей клетки
                for node in gameBoard.elementNodes[row][col] {
                    if let node = node {
                        nodesToRemove.append(node)
                    }
                }

                // Очищаем массив узлов для данной клетки
                gameBoard.elementNodes[row][col].removeAll()

                // Добавляем новые элементы
                for (name, offset) in gameBoard.elements[row][col] {
                    let element = SKSpriteNode(imageNamed: name)
                    element.name = name
                    let xPos = startX + CGFloat(col) * (blockSize + spacing)
                    let yPos = startY - CGFloat(row) * (blockSize + spacing)
                    element.position = CGPoint(x: xPos + offset.x, y: yPos + offset.y)
                    
                    // Добавляем элемент на сцену
                    scene.addChild(element)

                    // Сохраняем ссылку на узел в массиве
                    gameBoard.elementNodes[row][col].append(element)
                }
            }
        }

        // Шаг 3: Удаляем старые узлы с анимацией
        
        if !nodesToRemove.isEmpty {
            let fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
            let removeAction = SKAction.removeFromParent()

            for node in nodesToRemove {
                node.run(SKAction.sequence([fadeOutAction, removeAction]))
            }
        }
        
    }
    
    func changeHalfToSquare(scene: SKScene, gameBoard: GameBoard) -> Bool {
        var flag = false
        for row in 0..<gameBoard.elements.count {
            for col in 0..<gameBoard.elements[row].count {
                if gameBoard.elementNodes[row][col].count == 1 {
                    guard let node = gameBoard.elementNodes[row][col].first! else {return false}
                    if gameLogic.isHalfBlock(node.name ?? "") {
                        node.run(SKAction.fadeOut(withDuration: 0.2)) {
                            node.removeFromParent()
                            gameBoard.elementNodes[row][col].removeAll(where: { $0?.name == node.name })
                        }
                        gameBoard.elements[row][col].removeFirst()
                        let color = gameLogic.getColor(from: node.name!)
                        let element = SKSpriteNode(imageNamed: color+"Square")
                        element.name = color+"Square"
                        gameBoard.elementNodes[row][col].append(element)
                        gameBoard.elements[row][col].append((color+"Square", CGPoint(x: 0, y: 0)))
                        flag = true
                    }
                }
            }
        }
        return flag
    }
}
