
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
        print("aaaaaaaaa")
        print(gameBoard.elements)
        // Шаг 1: Создаем массив для хранения узлов, которые нужно удалить
        var nodesToRemove: [SKSpriteNode] = []
        
        // Шаг 2: Проходим по всем клеткам игрового поля
        for row in 0..<gameBoard.elements.count {
            for col in 0..<gameBoard.elements[row].count {
                // Удаляем старые узлы из текущей клетки
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
    
    
    
    func changeQuarterToHalf(gameBoard: GameBoard) -> Bool {
        var flag = false
        
        for row in 0..<gameBoard.elements.count {
            for col in 0..<gameBoard.elements[row].count {
                // Получаем все четвертинки в текущей клетке
                let quarters = gameBoard.elements[row][col].filter { $0.0.contains("Quarter") }
                
                if !quarters.isEmpty {
                    // Определяем, какие четвертинки отсутствуют
                    let missingQuarters = getMissingQuarters(from: gameBoard.elements[row][col])
                    
                    // Обрабатываем случай, когда остается одна или несколько четвертинок
                    if let newElements = convertQuartersToHalves(quarters: quarters, missingQuarters: missingQuarters, itemsInBlock: gameBoard.elements[row][col]) {
                        
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
    
    // Вспомогательная функция: преобразование четвертинок в половинки
    private func convertQuartersToHalves(quarters: [(String, CGPoint)], missingQuarters: [CGPoint], itemsInBlock: [(String, CGPoint)]) -> [(String, CGPoint)]? {
        if quarters.count == 3 {
            return mergeThreeQuartersToHalves(items: itemsInBlock, missingQuarters: missingQuarters)
        } else if itemsInBlock.count == 2 && missingQuarters.count == 1{
            return mergeQuarterAndHalfToTwoHalf(items: itemsInBlock, missingQuarters: missingQuarters)
        } else if missingQuarters.count == 2 && itemsInBlock.count == 2 {
            return mergeTwoQuartersToTwoHalfs(items: itemsInBlock, missingQuarters: missingQuarters)
        } else if missingQuarters.count == 3 && itemsInBlock.count == 1 {
            return mergeQuarterToHalf(items: itemsInBlock, missingQuarters: missingQuarters)
        }
        
        return nil
    }
    
    private func mergeQuarterToHalf(items: [(String, CGPoint)], missingQuarters: [CGPoint]) -> [(String, CGPoint)] {
        var newItems:[(String, CGPoint)] = []
        let item = items.first!
        let color = gameLogic.getColor(from: item.0)
        newItems.append((color+"HorizontalHalf", CGPoint(x: 0, y: item.1.y)))
        return newItems
    }
    
    private func mergeTwoQuartersToTwoHalfs(items: [(String, CGPoint)], missingQuarters: [CGPoint]) -> [(String, CGPoint)] {
        var newItems:[(String, CGPoint)] = []
        var color1 = ""
        var color2 = ""
        let item1 = items[0]
        let item2 = items[1]
        color1 = gameLogic.getColor(from: item1.0)
        color2 = gameLogic.getColor(from: item2.0)
        if item1.1.y == item2.1.y {
            
            newItems.append((color1+"VerticalHalf", CGPoint(x: item1.1.x, y: 0)))
            newItems.append((color2+"VerticalHalf", CGPoint(x: item2.1.x, y: 0)))
        } else if item1.1.x == item2.1.x {
            newItems.append((color1+"HorizontalHalf", CGPoint(x: 0, y: item1.1.y)))
            newItems.append((color2+"HorizontalHalf", CGPoint(x: 0, y: item2.1.y)))
        } else {
            newItems.append((color1+"VerticalHalf", CGPoint(x: item1.1.x, y: 0)))
            newItems.append((color2+"VerticalHalf", CGPoint(x: item2.1.x, y: 0)))
        }
        
        return newItems
    }
    
    private func mergeQuarterAndHalfToTwoHalf(items: [(String, CGPoint)], missingQuarters: [CGPoint]) -> [(String, CGPoint)] {
        guard let missingQuarter = missingQuarters.first else { return [] }
        var newItems = items
        var color = ""

        // Определяем, какую четвертинку преобразовать в половинку
        switch missingQuarter {
        case CGPoint(x: -19, y: -19): // Пропущен левый нижний угол
            if newItems.contains(where: {$0.0.contains("VerticalHalf")}) {
                let item = newItems.first(where: {$0.1 == CGPoint(x: -19, y: 19)})
                newItems.removeAll(where: {$0.1 == CGPoint(x: -19, y: 19)})
                color = gameLogic.getColor(from: item?.0 ?? "white")
                newItems.append((color+"VerticalHalf", CGPoint(x: -19, y: 0)))
            } else if newItems.contains(where: {$0.0.contains("HorizontalHalf")}) {
                let item = newItems.first(where: {$0.1 == CGPoint(x: 19, y: -19)})
                newItems.removeAll(where: {$0.1 == CGPoint(x: 19, y: -19)})
                color = gameLogic.getColor(from: item?.0 ?? "white")
                newItems.append((color+"HorizontalHalf", CGPoint(x: 0, y: -19)))
            }
        case CGPoint(x: 19, y: -19): // Пропущен правый нижний угол
            if newItems.contains(where: {$0.0.contains("VerticalHalf")}) {
                let item = newItems.first(where: {$0.1 == CGPoint(x: 19, y: 19)})
                newItems.removeAll(where: {$0.1 == CGPoint(x: 19, y: 19)})
                color = gameLogic.getColor(from: item?.0 ?? "white")
                newItems.append((color+"VerticalHalf", CGPoint(x: 19, y: 0)))
            } else if newItems.contains(where: {$0.0.contains("HorizontalHalf")}) {
                let item = newItems.first(where: {$0.1 == CGPoint(x: -19, y: -19)})
                newItems.removeAll(where: {$0.1 == CGPoint(x: -19, y: -19)})
                color = gameLogic.getColor(from: item?.0 ?? "white")
                newItems.append((color+"HorizontalHalf", CGPoint(x: 0, y: -19)))
            }
        case CGPoint(x: 19, y: 19): // Пропущен правый верхний угол
            if newItems.contains(where: {$0.0.contains("VerticalHalf")}) {
                let item = newItems.first(where: {$0.1 == CGPoint(x: 19, y: -19)})
                newItems.removeAll(where: {$0.1 == CGPoint(x: 19, y: -19)})
                color = gameLogic.getColor(from: item?.0 ?? "white")
                newItems.append((color+"VerticalHalf", CGPoint(x: 19, y: 0)))
            } else if newItems.contains(where: {$0.0.contains("HorizontalHalf")}) {
                let item = newItems.first(where: {$0.1 == CGPoint(x: -19, y: 19)})
                newItems.removeAll(where: {$0.1 == CGPoint(x: -19, y: 19)})
                color = gameLogic.getColor(from: item?.0 ?? "white")
                newItems.append((color+"HorizontalHalf", CGPoint(x: 0, y: 19)))
            }
        case CGPoint(x: -19, y: 19): // Пропущен левый верхний угол
            if newItems.contains(where: {$0.0.contains("VerticalHalf")}) {
                let item = newItems.first(where: {$0.1 == CGPoint(x: -19, y: -19)})
                newItems.removeAll(where: {$0.1 == CGPoint(x: -19, y: -19)})
                color = gameLogic.getColor(from: item?.0 ?? "white")
                newItems.append((color+"VerticalHalf", CGPoint(x: -19, y: 0)))
            } else if newItems.contains(where: {$0.0.contains("HorizontalHalf")}) {
                let item = newItems.first(where: {$0.1 == CGPoint(x: 19, y: 19)})
                newItems.removeAll(where: {$0.1 == CGPoint(x: 19, y: 19)})
                color = gameLogic.getColor(from: item?.0 ?? "white")
                newItems.append((color+"HorizontalHalf", CGPoint(x: 0, y: 19)))
            }
        default:
            newItems = items
        }
                            
        return newItems
    }

    // Преобразование трех четвертинок в половинки
    private func mergeThreeQuartersToHalves(items: [(String, CGPoint)], missingQuarters: [CGPoint]) -> [(String, CGPoint)] {
        guard let missingQuarter = missingQuarters.first else { return [] }
        var newItems = items
        var color = ""

        // Определяем, какую четвертинку преобразовать в половинку
        switch missingQuarter {
        case CGPoint(x: -19, y: -19): // Пропущен левый нижний угол
            let item = newItems.first(where: {$0.1 == CGPoint(x: -19, y: 19)})
            newItems.removeAll(where: {$0.1 == CGPoint(x: -19, y: 19)})
            color = gameLogic.getColor(from: item?.0 ?? "white")
            newItems.append((color+"VerticalHalf", CGPoint(x: -19, y: 0)))
            
        case CGPoint(x: 19, y: -19): // Пропущен правый нижний угол
            let item = newItems.first(where: {$0.1 == CGPoint(x: 19, y: 19)})
            newItems.removeAll(where: {$0.1 == CGPoint(x: 19, y: 19)})
            color = gameLogic.getColor(from: item?.0 ?? "white")
            newItems.append((color+"VerticalHalf", CGPoint(x: 19, y: 0)))
        case CGPoint(x: 19, y: 19): // Пропущен правый верхний угол
            let item = newItems.first(where: {$0.1 == CGPoint(x: 19, y: -19)})
            newItems.removeAll(where: {$0.1 == CGPoint(x: 19, y: -19)})
            color = gameLogic.getColor(from: item?.0 ?? "white")
            newItems.append((color+"VerticalHalf", CGPoint(x: 19, y: 0)))
        case CGPoint(x: -19, y: 19): // Пропущен левый верхний угол
            let item = newItems.first(where: {$0.1 == CGPoint(x: -19, y: -19)})
            newItems.removeAll(where: {$0.1 == CGPoint(x: -19, y: -19)})
            color = gameLogic.getColor(from: item?.0 ?? "white")
            newItems.append((color+"VerticalHalf", CGPoint(x: -19, y: 0)))
        default:
            newItems = items
        }
                            
        return newItems
    }

    
}
