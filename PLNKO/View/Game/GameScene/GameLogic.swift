
import SpriteKit

class GameLogic {
    
    func placeElement(on gameBoard: GameBoard, at position: (Int, Int), scene: GameScene) {
        gameBoard.placeElement(at: position, scene: scene)
    }
    
    func hasMatches(on gameBoard: GameBoard) -> Bool {
        for row in 0..<gameBoard.elements.count {
            for col in 0..<gameBoard.elements[row].count {
                guard !gameBoard.elements[row][col].isEmpty else { continue }
                let currentOffset = gameBoard.elements[row][col][0].1
                let currentElementName = gameBoard.elements[row][col][0].0
                let currentElementType = getType(from: currentElementName)
                let currentElementColor = getColor(from: currentElementName)
                
                for (dRow, dCol) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                    let neighborRow = row + dRow
                    let neighborCol = col + dCol
                    
                    if neighborRow < 0 || neighborRow >= gameBoard.elements.count ||
                       neighborCol < 0 || neighborCol >= gameBoard.elements[row].count {
                        continue
                    }
                    
                    guard !gameBoard.elements[neighborRow][neighborCol].isEmpty else { continue }
                    
                    for neighbor in gameBoard.elements[neighborRow][neighborCol] {
                        let neighborName = neighbor.0
                        let neighborType = getType(from: neighborName)
                        let neighborColor = getColor(from: neighborName)
                        let neighborOffset = neighbor.1
                        
                        if currentElementColor == neighborColor,
                           areElementsTouching(
                               currentType: currentElementType,
                               neighborType: neighborType,
                               direction: (dRow, dCol),
                               currentOffset: currentOffset,
                               neighborOffset: neighborOffset
                           ) {
                            return true // Найден матч
                        }
                    }
                }
            }
        }
        return false // Матчей нет
    }
    
    func checkAndRemoveMatches(on gameBoard: GameBoard) {
        var toRemove: [(Int, Int, String)] = []
        var visitedCells = Set<String>() // Множество посещенных клеток

        for row in 0..<gameBoard.elements.count {
            for col in 0..<gameBoard.elements[row].count {
                guard !gameBoard.elements[row][col].isEmpty else { continue }
                if !gameBoard.isCellAvailable[row][col]{
                    continue
                }
                for currentElem in gameBoard.elements[row][col] {
                    let currentOffset = currentElem.1
                    let currentElementName = currentElem.0
                    let currentElementType = getType(from: currentElementName)
                    let currentElementColor = getColor(from: currentElementName)
                    for (dRow, dCol) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                        let neighborRow = row + dRow
                        let neighborCol = col + dCol

                        if neighborRow < 0 || neighborRow >= gameBoard.elements.count ||
                           neighborCol < 0 || neighborCol >= gameBoard.elements[row].count {
                            continue
                        }

                        guard !gameBoard.elements[neighborRow][neighborCol].isEmpty else { continue }

                        for neighbor in gameBoard.elements[neighborRow][neighborCol] {
                            let neighborName = neighbor.0
                            let neighborType = getType(from: neighborName)
                            let neighborColor = getColor(from: neighborName)
                            let neighborOffset = neighbor.1
                            if currentElementColor == neighborColor,
                               
                               areElementsTouching(
                                   currentType: currentElementType,
                                   neighborType: neighborType,
                                   direction: (dRow, dCol),
                                   currentOffset: currentOffset,
                                   neighborOffset: neighborOffset
                               ) {
                                let cellKey = "\(row)-\(col)-\(currentElementName)"
                                if !visitedCells.contains(cellKey) {
                                    toRemove.append((row, col, currentElementName))
                                    visitedCells.insert(cellKey)
                                }

                                let neighborCellKey = "\(neighborRow)-\(neighborCol)-\(neighborName)"
                                if !visitedCells.contains(neighborCellKey) {
                                    toRemove.append((neighborRow, neighborCol, neighborName))
                                    visitedCells.insert(neighborCellKey)
                                }
                            }
                        }
                    }
                }
                
            }
        }

        gameBoard.removeElements(at: toRemove, gameLogic: self)
    }
    
   

     func getType(from name: String) -> String {
        if name.contains("Square") {
            return "Square"
        } else if name.contains("HorizontalHalf") {
            return "HorizontalHalf"
        } else if name.contains("VerticalHalf") {
            return "VerticalHalf"
        } else if name.contains("Quarter") {
            return "Quarter"
        }
        return ""
    }

    public func getColor(from name: String) -> String {
        var modifiedString = name
        if modifiedString.hasSuffix("Square") {
            modifiedString = modifiedString.replacingOccurrences(of: "Square", with: "")
        } else if modifiedString.hasSuffix("HorizontalHalf") {
            modifiedString = modifiedString.replacingOccurrences(of: "HorizontalHalf", with: "")
        } else if modifiedString.hasSuffix("VerticalHalf") {
            modifiedString = modifiedString.replacingOccurrences(of: "VerticalHalf", with: "")
        } else if modifiedString.hasSuffix("Quarter") {
            modifiedString = modifiedString.replacingOccurrences(of: "Quarter", with: "")
        }
        return modifiedString.trimmingCharacters(in: .whitespaces)
    }
    
    public func isHalfBlock(_ name: String) -> Bool {
        if name.contains("HorizontalHalf") {
            return true
        } else if name.contains("VerticalHalf") {
            return true
        } else {
            return false
        }
    }

    func areElementsTouching(
        currentType: String,
        neighborType: String,
        direction: (Int, Int),
        currentOffset: CGPoint,
        neighborOffset: CGPoint
    ) -> Bool {

        if currentType.contains("Square") && neighborType.contains("Square") {
            return true // Квадрат всегда соприкасается с другим квадратом
        } else if currentType.contains("Square") && neighborType.contains("VerticalHalf") {
            if direction == (-1, 0) || direction == (1, 0) {
                return true // Вертикальные половинки соприкасаются с квадратом сверху/снизу
            } else if direction == (0, -1) {
                return neighborOffset.x > 0 // Слева — сосед должен быть справа
            } else {
                return neighborOffset.x < 0 // Справа — сосед должен быть слева
            }
        } else if currentType.contains("Square") && neighborType.contains("HorizontalHalf") {
            if direction == (-1, 0) {
                return neighborOffset.y < 0 // Сверху — сосед должен быть снизу
            } else if direction == (1, 0) {
                return neighborOffset.y > 0 // Снизу — сосед должен быть сверху
            } else {
                return true // По горизонтали — всегда соприкасаются
            }
        } else if currentType.contains("Square") && neighborType.contains("Quarter") {
            if direction == (0, -1) {
                return neighborOffset.x > 0
            } else if direction == (-1, 0) {
                return neighborOffset.y < 0
            } else if direction == (0, 1) {
                return neighborOffset.x < 0
            } else if direction == (1, 0) {
                return neighborOffset.y > 0
            }
        }else if currentType.contains("HorizontalHalf") && neighborType.contains("HorizontalHalf") {
            // Проверяем, что обе половинки находятся на одной стороне клетки
            if direction == (0, 1) || direction == (0, -1) {
                return currentOffset.y == neighborOffset.y // Они должны быть на одном уровне
            } else if direction == (-1, 0) {
                return currentOffset.y > neighborOffset.y
            } else if direction == (1, 0) {
                return currentOffset.y < neighborOffset.y
            }
        }else if currentType.contains("HorizontalHalf") && neighborType.contains("VerticalHalf") {
            if direction == (0, -1) {
                return currentOffset.x < neighborOffset.x
            } else if direction == (1, 0) {
                return neighborOffset.y < 0
            } else if direction == (-1, 0) {
                return currentOffset.y > 0
            } else if direction == (0, 1) {
                return neighborOffset.x < 0
            }
        } else if currentType.contains("HorizontalHalf") && neighborType.contains("Quarter") {
            if (currentOffset.y > 0 && neighborOffset.y > 0) || (currentOffset.y < 0 && neighborOffset.y < 0){
                if direction == (0, -1) {
                    return neighborOffset.x > 0
                } else if direction == (0, 1) {
                    return neighborOffset.x < 0
                }
            } else {
                if direction == (-1, 0) {
                    return currentOffset.y > 0 && neighborOffset.y < 0
                } else if direction == (1, 0) {
                    return currentOffset.y < 0 && neighborOffset.y > 0
                }
            }
        } else if currentType.contains("VerticalHalf") && neighborType.contains("HorizontalHalf") {
            if direction == (0, -1) {
                return currentOffset.x < neighborOffset.x
            } else if direction == (-1, 0) {
                return neighborOffset.y < 0
            } else if direction == (1, 0) {
                return neighborOffset.y > 0
            } else if direction == (0, 1) {
                return currentOffset.x > 0
            }
        } else if currentType.contains("VerticalHalf") && neighborType.contains("Quarter") {
            if direction == (0, -1) {
                return currentOffset.x < 0 && neighborOffset.x > 0 
            } else if direction == (0, 1) {
                return currentOffset.x > 0 && neighborOffset.x < 0
            } else if direction == (1, 0) {
                if (currentOffset.x < 0 && neighborOffset.x < 0) || (currentOffset.x > 0 && neighborOffset.x > 0) {
                    return neighborOffset.y > 0
                }
            } else if direction == (-1, 0) {
                if (currentOffset.x < 0 && neighborOffset.x < 0) || (currentOffset.x > 0 && neighborOffset.x > 0) {
                    return neighborOffset.y < 0
                }
            }
        } else if currentType.contains("VerticalHalf") && neighborType.contains("VerticalHalf") {
            // Проверяем, что обе половинки находятся на одной стороне клетки
            if direction == (-1, 0) || direction == (1, 0) {
                return currentOffset.x == neighborOffset.x // Они должны быть на одном уровне
            } else if direction == (0, 1) {
                return currentOffset.x > 0 && neighborOffset.x < 0
            } else if direction == (0, -1) {
                return currentOffset.x < 0 && neighborOffset.x > 0
            }
        } else if currentType.contains("Quarter") && neighborType.contains("Quarter") {
            if (currentOffset.y > 0 && neighborOffset.y > 0) || (currentOffset.y < 0 && neighborOffset.y < 0) {
                if direction == (0, 1) {
                    return currentOffset.x > 0 && neighborOffset.x < 0
                } else if direction == (0, -1) {
                    return currentOffset.x < 0 && neighborOffset.x > 0
                }
            } else {
                if direction == (-1, 0) && currentOffset.y > 0 && neighborOffset.y < 0{
                    return (currentOffset.x < 0 && neighborOffset.x < 0) || (currentOffset.x > 0 && neighborOffset.x > 0)
                } else if direction == (1, 0) && currentOffset.y < 0 && neighborOffset.y > 0 {
                    return (currentOffset.x < 0 && neighborOffset.x < 0) || (currentOffset.x > 0 && neighborOffset.x > 0)
                }
            }
            
        }

        return false
    }
    
    public func convertQuartersToHalves(quarters: [(String, CGPoint)], missingQuarters: [CGPoint], itemsInBlock: [(String, CGPoint)]) -> [(String, CGPoint)]? {
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
        let color = getColor(from: item.0)
        newItems.append((color+"HorizontalHalf", CGPoint(x: 0, y: item.1.y)))
        return newItems
    }
    
    private func mergeTwoQuartersToTwoHalfs(items: [(String, CGPoint)], missingQuarters: [CGPoint]) -> [(String, CGPoint)] {
        var newItems:[(String, CGPoint)] = []
        var color1 = ""
        var color2 = ""
        let item1 = items[0]
        let item2 = items[1]
        color1 = getColor(from: item1.0)
        color2 = getColor(from: item2.0)
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
                color = getColor(from: item?.0 ?? "white")
                newItems.append((color+"VerticalHalf", CGPoint(x: -19, y: 0)))
            } else if newItems.contains(where: {$0.0.contains("HorizontalHalf")}) {
                let item = newItems.first(where: {$0.1 == CGPoint(x: 19, y: -19)})
                newItems.removeAll(where: {$0.1 == CGPoint(x: 19, y: -19)})
                color = getColor(from: item?.0 ?? "white")
                newItems.append((color+"HorizontalHalf", CGPoint(x: 0, y: -19)))
            }
        case CGPoint(x: 19, y: -19): // Пропущен правый нижний угол
            if newItems.contains(where: {$0.0.contains("VerticalHalf")}) {
                let item = newItems.first(where: {$0.1 == CGPoint(x: 19, y: 19)})
                newItems.removeAll(where: {$0.1 == CGPoint(x: 19, y: 19)})
                color = getColor(from: item?.0 ?? "white")
                newItems.append((color+"VerticalHalf", CGPoint(x: 19, y: 0)))
            } else if newItems.contains(where: {$0.0.contains("HorizontalHalf")}) {
                let item = newItems.first(where: {$0.1 == CGPoint(x: -19, y: -19)})
                newItems.removeAll(where: {$0.1 == CGPoint(x: -19, y: -19)})
                color = getColor(from: item?.0 ?? "white")
                newItems.append((color+"HorizontalHalf", CGPoint(x: 0, y: -19)))
            }
        case CGPoint(x: 19, y: 19): // Пропущен правый верхний угол
            if newItems.contains(where: {$0.0.contains("VerticalHalf")}) {
                let item = newItems.first(where: {$0.1 == CGPoint(x: 19, y: -19)})
                newItems.removeAll(where: {$0.1 == CGPoint(x: 19, y: -19)})
                color = getColor(from: item?.0 ?? "white")
                newItems.append((color+"VerticalHalf", CGPoint(x: 19, y: 0)))
            } else if newItems.contains(where: {$0.0.contains("HorizontalHalf")}) {
                let item = newItems.first(where: {$0.1 == CGPoint(x: -19, y: 19)})
                newItems.removeAll(where: {$0.1 == CGPoint(x: -19, y: 19)})
                color = getColor(from: item?.0 ?? "white")
                newItems.append((color+"HorizontalHalf", CGPoint(x: 0, y: 19)))
            }
        case CGPoint(x: -19, y: 19): // Пропущен левый верхний угол
            if newItems.contains(where: {$0.0.contains("VerticalHalf")}) {
                let item = newItems.first(where: {$0.1 == CGPoint(x: -19, y: -19)})
                newItems.removeAll(where: {$0.1 == CGPoint(x: -19, y: -19)})
                color = getColor(from: item?.0 ?? "white")
                newItems.append((color+"VerticalHalf", CGPoint(x: -19, y: 0)))
            } else if newItems.contains(where: {$0.0.contains("HorizontalHalf")}) {
                let item = newItems.first(where: {$0.1 == CGPoint(x: 19, y: 19)})
                newItems.removeAll(where: {$0.1 == CGPoint(x: 19, y: 19)})
                color = getColor(from: item?.0 ?? "white")
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
            color = getColor(from: item?.0 ?? "white")
            newItems.append((color+"VerticalHalf", CGPoint(x: -19, y: 0)))
            
        case CGPoint(x: 19, y: -19): // Пропущен правый нижний угол
            let item = newItems.first(where: {$0.1 == CGPoint(x: 19, y: 19)})
            newItems.removeAll(where: {$0.1 == CGPoint(x: 19, y: 19)})
            color = getColor(from: item?.0 ?? "white")
            newItems.append((color+"VerticalHalf", CGPoint(x: 19, y: 0)))
        case CGPoint(x: 19, y: 19): // Пропущен правый верхний угол
            let item = newItems.first(where: {$0.1 == CGPoint(x: 19, y: -19)})
            newItems.removeAll(where: {$0.1 == CGPoint(x: 19, y: -19)})
            color = getColor(from: item?.0 ?? "white")
            newItems.append((color+"VerticalHalf", CGPoint(x: 19, y: 0)))
        case CGPoint(x: -19, y: 19): // Пропущен левый верхний угол
            let item = newItems.first(where: {$0.1 == CGPoint(x: -19, y: -19)})
            newItems.removeAll(where: {$0.1 == CGPoint(x: -19, y: -19)})
            color = getColor(from: item?.0 ?? "white")
            newItems.append((color+"VerticalHalf", CGPoint(x: -19, y: 0)))
        default:
            newItems = items
        }
                            
        return newItems
    }
}


