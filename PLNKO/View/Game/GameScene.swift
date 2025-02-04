
import SwiftUI
import SpriteKit

class GameScene: SKScene {
    var elements: [[[(String, CGPoint)]]] = [
        [[], [], [], [("whiteSquare", CGPoint(x: 0, y: 0))]],
        [[], [("redHorizontalHalf", CGPoint(x: 0, y: 19)), ("orangeHorizontalHalf", CGPoint(x: 0, y: -19))], [], []],
        [[], [], [], [("redVerticalHalf", CGPoint(x: -19, y: 0)), ("greenVerticalHalf", CGPoint(x: 19, y: 0))]],
        [[], [], [("orangeVerticalHalf", CGPoint(x: -19, y: 0)), ("purpleVerticalHalf", CGPoint(x: 19, y: 0))], [("blueSquare", CGPoint(x: 0, y: 0))]]
    ]

    var elementNodes: [[SKSpriteNode?]] = Array(repeating: Array(repeating: nil, count: 4), count: 4)

    var startBlockNodes: [SKSpriteNode] = []
    var startSquares: [SKSpriteNode] = []
    var tappedSquareIndex: Int? = nil
    var selectedElement: (String, CGPoint)? = nil
    var startImages = ["whiteSquare", "orangeSquare"]

    let columns = 4
    let rows = 4
    let blockSize: CGFloat = 75
    let spacing: CGFloat = 8

    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = .clear
        addBackgroundImage()
        setupGameBoard()
        setupStartBlocks()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addBackgroundImage() {
        let background = SKSpriteNode(imageNamed: "gameSceneBack")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }

    private func setupGameBoard() {
        let startX = (self.size.width - (249)) / 2
        let startY = size.height - 60

        for row in 0..<rows {
            for col in 0..<columns {
                let xPos = startX + CGFloat(col) * (blockSize + spacing)
                let yPos = startY - CGFloat(row) * (blockSize + spacing)

                let block = SKSpriteNode(imageNamed: "gameBoardBlock")
                block.size = CGSize(width: blockSize, height: blockSize)
                block.position = CGPoint(x: xPos, y: yPos)
                addChild(block)

                for (imageName, offset) in elements[row][col] {
                    let element = SKSpriteNode(imageNamed: imageName)
                    element.position = CGPoint(x: xPos + offset.x, y: yPos + offset.y)
                    addChild(element)
                    elementNodes[row][col] = element
                }
            }
        }
    }

    private func setupStartBlocks() {
        let startBlockSize: CGFloat = 90
        let yOffset: CGFloat = startBlockSize / 2
        let startXPositions = [startBlockSize / 2, size.width - startBlockSize / 2]

        for (index, startX) in startXPositions.enumerated() {
            let block = SKSpriteNode(imageNamed: "startBlockImage")
            block.size = CGSize(width: startBlockSize, height: startBlockSize)
            block.position = CGPoint(x: startX, y: yOffset)
            addChild(block)
            startBlockNodes.append(block)

            let square = SKSpriteNode(imageNamed: startImages[index])
            square.position = block.position
            addChild(square)
            startSquares.append(square)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        for (index, block) in startBlockNodes.enumerated() {
            if block.contains(location) {
                if tappedSquareIndex == index {
                    startSquares[index].setScale(1.0)
                    tappedSquareIndex = nil
                    selectedElement = nil
                } else {
                    tappedSquareIndex = index
                    selectedElement = (startImages[index], CGPoint(x: 0, y: 0))
                    startSquares[index].setScale(1.2)
                }
            }
        }

        let startX = (self.size.width - (249)) / 2
        let startY = size.height - 60

        for row in 0..<rows {
            for col in 0..<columns {
                let xPos = startX + CGFloat(col) * (blockSize + spacing)
                let yPos = startY - CGFloat(row) * (blockSize + spacing)
                let blockRect = CGRect(x: xPos - blockSize / 2, y: yPos - blockSize / 2, width: blockSize, height: blockSize)

                if blockRect.contains(location), elements[row][col].isEmpty, let selected = selectedElement {
                    guard let index = tappedSquareIndex else { return }

                    elements[row][col].append((startImages[index], CGPoint(x: 0, y: 0)))

                    let elementNode = SKSpriteNode(imageNamed: startImages[index])
                    elementNode.position = CGPoint(x: xPos, y: yPos)
                    addChild(elementNode)

                    elementNodes[row][col] = elementNode

                    startSquares[index].setScale(1.0)
                    tappedSquareIndex = nil
                    selectedElement = nil

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.checkAndRemoveMatches()
                    }
                }
            }
        }
    }

    private func checkAndRemoveMatches() {
        var visited = Set<String>() // Чтобы не проверять одну и ту же клетку дважды
        var groups: [[(Int, Int, String)]] = [] // Группы элементов, которые должны удалиться

        for row in 0..<rows {
            for col in 0..<columns {
                guard !elements[row][col].isEmpty else { continue }

                let elementName = elements[row][col][0].0
                let elementColor = getColor(from: elementName)

                let key = "\(row)-\(col)-\(elementName)"
                if visited.contains(key) { continue }

                // Найти всю связанную группу
                var toCheck = [(row, col, elementName)]
                var connectedGroup: [(Int, Int, String)] = []

                while !toCheck.isEmpty {
                    let (curRow, curCol, curElement) = toCheck.removeLast()
                    let curKey = "\(curRow)-\(curCol)-\(curElement)"

                    if visited.contains(curKey) { continue }
                    visited.insert(curKey)

                    connectedGroup.append((curRow, curCol, curElement))

                    let curType = getType(from: curElement)
                    let curOffset = elements[curRow][curCol][0].1

                    for (dRow, dCol) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                        let neighborRow = curRow + dRow
                        let neighborCol = curCol + dCol

                        if neighborRow < 0 || neighborRow >= rows || neighborCol < 0 || neighborCol >= columns {
                            continue
                        }

                        guard !elements[neighborRow][neighborCol].isEmpty else { continue }

                        for neighbor in elements[neighborRow][neighborCol] {
                            let neighborName = neighbor.0
                            let neighborType = getType(from: neighborName)
                            let neighborColor = getColor(from: neighborName)
                            let neighborOffset = neighbor.1

                            let neighborKey = "\(neighborRow)-\(neighborCol)-\(neighborName)"
                        
                            if neighborColor == elementColor, !visited.contains(neighborKey),
                                areElementsTouching(
                                    currentType: curType,
                                    neighborType: neighborType,
                                    direction: (dRow, dCol),
                                    currentOffset: curOffset,
                                    neighborOffset: neighborOffset
                                ) {
                                toCheck.append((neighborRow, neighborCol, neighborName))
                            }
                        }
                    }
                }

                if connectedGroup.count > 1 {
                    groups.append(connectedGroup)
                }
            }
        }
//        print(groups)
        // Удаляем только связанные группы
        print(elementNodes)
        for group in groups {
            for (row, col, elementName) in group {
                print(elementName)
                if let index = elements[row][col].firstIndex(where: { $0.0 == elementName }) {
                    elements[row][col].remove(at: index)
                }
//                print(elementNodes)
                if let node = elementNodes[row][col]{
                    print(node)
                    node.run(SKAction.fadeOut(withDuration: 0.2)) {
                        node.removeFromParent()
                        self.elementNodes[row][col] = nil
                    }
                }
            }
        }
//        print(elements)
    }



    // Функция для определения типа элемента
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
    
    func getColor(from name: String) -> String {
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
        return modifiedString.trimmingCharacters(in: .whitespaces) // Удаляем лишние пробелы
    }

    // Функция для проверки соприкосновения элементов
    private func areElementsTouching(
        currentType: String,
        neighborType: String,
        direction: (Int, Int),
        currentOffset: CGPoint,
        neighborOffset: CGPoint
    ) -> Bool {
        print("CALL: - areElementsTouching")
        print(currentType, neighborType, direction, currentOffset, neighborOffset)
        // Если один из элементов — квадрат, он полностью соприкасается с соседями
        if currentType.contains("Square") && neighborType.contains("Square") {
            return true
        }

//        // Если оба элемента вертикальные половинки
//        if currentType.contains("VerticalHalf") && neighborType.contains("VerticalHalf") {
//            if direction.0 == 1 { // Сосед снизу
//                return currentOffset.y < 0 && neighborOffset.y > 0
//            } else if direction.0 == -1 { // Сосед сверху
//                return currentOffset.y > 0 && neighborOffset.y < 0
//            }
//        }

//        // Если текущий элемент - вертикальная половинка и сосед - квадрат
//        if currentType.contains("VerticalHalf") && neighborType.contains("Square") {
//            if direction.0 == 1 { // Сосед снизу
//                return currentOffset.y < 0
//            } else if direction.0 == -1 { // Сосед сверху
//                return currentOffset.y > 0
//            }
//        }

        // Если текущий элемент - квадрат и сосед - вертикальная половинка
        if currentType.contains("Square") && neighborType.contains("VerticalHalf") {
            if direction == (-1, 0) { //сверху
                return true
            } else if direction == (1, 0) { //внизу
                return true
            } else if direction == (0, -1) { //слева
                return neighborOffset.x > 0
            } else { //справа
                return neighborOffset.x < 0
            }
        }

        // Если текущий элемент - квадрат и сосед - горизонтальная половинка
        if currentType.contains("Square") && neighborType.contains("HorizontalHalf") {
            if direction.1 == 1 { // Сосед справа
                return neighborOffset.x > 0
            } else if direction.1 == -1 { // Сосед слева
                return neighborOffset.x < 0
            }
        }

//        // Если оба элемента - четвертинки, они должны совпадать по расположению
//        if currentType.contains("Quarter") && neighborType.contains("Quarter") {
//            return currentOffset == neighborOffset
//        }

        return false
    }


}

