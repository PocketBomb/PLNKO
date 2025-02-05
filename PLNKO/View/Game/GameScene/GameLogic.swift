
import SpriteKit

class GameLogic {
    func placeElement(on gameBoard: GameBoard, at position: (Int, Int)) {
        gameBoard.placeElement(at: position)
    }

    func checkAndRemoveMatches(on gameBoard: GameBoard) {
        var toRemove: [(Int, Int, String)] = []

        for row in 0..<gameBoard.elements.count {
            for col in 0..<gameBoard.elements[row].count {
                guard !gameBoard.elements[row][col].isEmpty else { continue }

                let currentElement = gameBoard.elements[row][col][0]
                let currentName = currentElement.0
                let currentType = getType(from: currentName)
                let currentColor = getColor(from: currentName)
                let currentOffset = currentElement.1

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
                        if currentColor == neighborColor,
                           areElementsTouching(
                               currentType: currentType,
                               neighborType: neighborType,
                               direction: (dRow, dCol),
                               currentOffset: currentOffset,
                               neighborOffset: neighborOffset
                           ) {
                            
                            toRemove.append((row, col, currentName))
                            toRemove.append((neighborRow, neighborCol, neighborName))
                            print(toRemove)
                        }
                    }
                }
            }
        }

        gameBoard.removeElements(at: toRemove)
    }

    private func getType(from name: String) -> String {
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

    private func areElementsTouching(
        currentType: String,
        neighborType: String,
        direction: (Int, Int),
        currentOffset: CGPoint,
        neighborOffset: CGPoint
    ) -> Bool {
        
        if currentType.contains("Square") && neighborType.contains("Square") {
            return true
        }

        if currentType.contains("Square") && neighborType.contains("VerticalHalf") {
            if direction == (-1, 0) || direction == (1, 0) {
                return true
            } else if direction == (0, -1) {
                return neighborOffset.x > 0
            } else {
                return neighborOffset.x < 0
            }
        }

        if currentType.contains("Square") && neighborType.contains("HorizontalHalf") {
            if direction == (-1, 0) {
                return neighborOffset.y < 0
            } else if direction == (1, 0) {
                return neighborOffset.y > 0
            } else {
                return true
            }
        }

        return false
    }
}


