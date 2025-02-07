
import SpriteKit
import Foundation

class GameRenderer {
    
    var gameLogic: GameLogic
    let blockSize: CGFloat = 75
    let spacing: CGFloat = 8
    var isCellAvailable: [[Bool]]
    
    init(gameLogic: GameLogic, isCellAvailable: [[Bool]]) {
        self.gameLogic = gameLogic
        self.isCellAvailable = isCellAvailable
    }
    
    func setupGameBoard(on scene: SKScene, gameBoard: GameBoard) {
        let startX = (scene.size.width - 249) / 2
        let startY = scene.size.height - 60
        let blockSize: CGFloat = 75
        let spacing: CGFloat = 8
        
        for row in 0..<gameBoard.elements.count {
            for col in 0..<gameBoard.elements[row].count {
                if isCellAvailable[row][col] == false {
                    continue
                }
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
        print(location)
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
    
    func handleRemoveBoostTouch(location: CGPoint, gameBoard: GameBoard) -> (Int, Int)? {
        let startX = (gameBoard.size.width - 249) / 2
        let startY = gameBoard.size.height - 60
        
        for row in 0..<gameBoard.elements.count {
            for col in 0..<gameBoard.elements[row].count {
                let xPos = startX + CGFloat(col) * (blockSize + spacing)
                let yPos = startY - CGFloat(row) * (blockSize + spacing)
                let blockRect = CGRect(x: xPos - blockSize / 2, y: yPos - blockSize / 2, width: blockSize, height: blockSize)
                if blockRect.contains(location) {
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
                if !gameBoard.isCellAvailable[row][col]{
                    continue
                }
                gameBoard.elementNodes[row][col].forEach { $0?.removeFromParent() }
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
                        gameBoard.elements[row][col].append((color+"Square", CGPoint(x: 0, y: 0)))
                        flag = true
                    }
                }
            }
        }
        return flag
    }
    
    
    
    func changeQuarterToHalf(gameBoard: GameBoard, gameLogic: GameLogic) -> Bool {
        var flag = false
        
        for row in 0..<gameBoard.elements.count {
            for col in 0..<gameBoard.elements[row].count {
                // Получаем все четвертинки в текущей клетке
                let quarters = gameBoard.elements[row][col].filter { $0.0.contains("Quarter") }
                
                if !quarters.isEmpty {
                    // Определяем, какие четвертинки отсутствуют
                    let missingQuarters = getMissingQuarters(from: gameBoard.elements[row][col])
                    
                    // Обрабатываем случай, когда остается одна или несколько четвертинок
                    if let newElements = gameLogic.convertQuartersToHalves(quarters: quarters, missingQuarters: missingQuarters, itemsInBlock: gameBoard.elements[row][col]) {
                        
                        gameBoard.elements[row][col] = []
                        
                        // Добавляем новые половинки в данные
                        gameBoard.elements[row][col].append(contentsOf: newElements)
                        flag = true
                    }
                }
            }
        }
        
        return flag
    }
    
    // Вспомогательная функция: определение отсутствующих четвертинок
    func getMissingQuarters(from elements: [(String, CGPoint)]) -> [CGPoint] {
        // Полный набор позиций четвертинок
        let allQuarterPositions: [CGPoint] = [
            CGPoint(x: -19.0, y: -19.0), // Левый нижний угол
            CGPoint(x: 19.0, y: -19.0), // Правый нижний угол
            CGPoint(x: 19.0, y: 19.0),  // Правый верхний угол
            CGPoint(x: -19.0, y: 19.0)  // Левый верхний угол
        ]

        // Массив занятых позиций
        var occupiedPositions: [CGPoint] = []

        for element in elements {
            let name = element.0
            let offset = element.1

            if name.contains("Quarter") {
                // Если элемент — четвертинка, добавляем его позицию
                occupiedPositions.append(offset)
            } else if name.contains("HorizontalHalf") {
                // Если элемент — горизонтальная половинка, добавляем две позиции
                if offset.y > 0 { // Верхняя половина
                    occupiedPositions.append(CGPoint(x: -19.0, y: 19.0))
                    occupiedPositions.append(CGPoint(x: 19.0, y: 19.0))
                } else { // Нижняя половина
                    occupiedPositions.append(CGPoint(x: -19.0, y: -19.0))
                    occupiedPositions.append(CGPoint(x: 19.0, y: -19.0))
                }
            } else if name.contains("VerticalHalf") {
                // Если элемент — вертикальная половинка, добавляем две позиции
                if offset.x > 0 { // Правая половина
                    occupiedPositions.append(CGPoint(x: 19.0, y: -19.0))
                    occupiedPositions.append(CGPoint(x: 19.0, y: 19.0))
                } else { // Левая половина
                    occupiedPositions.append(CGPoint(x: -19.0, y: -19.0))
                    occupiedPositions.append(CGPoint(x: -19.0, y: 19.0))
                }
            }
        }

        // Находим пропущенные позиции
        let missingQuarters = allQuarterPositions.filter { !occupiedPositions.contains($0) }

        return missingQuarters
    }
    
}
