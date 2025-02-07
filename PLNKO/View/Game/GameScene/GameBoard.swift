
import SpriteKit

class GameBoard {
    var size: CGSize
    var elements: [[[(String, CGPoint)]]]
    var isCellAvailable: [[Bool]]
    
    init(size: CGSize, elements: [[[(String, CGPoint)]]], isCellAvailable: [[Bool]]) {
        self.size = size
        self.elements = elements
        self.isCellAvailable = isCellAvailable
    }
    
    var matchCount: [String: Int] = [
        "white": 0,
        "blue": 0,
        "red": 0,
        "green": 0,
        "orange": 0,
        "pink": 0,
        "purple": 0,
        "yellow": 0
    ] {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("MatchCountUpdated"), object: matchCount)
        }
    }
    
    var elementNodes: [[[SKSpriteNode?]]] = Array(repeating: Array(repeating: [], count: 4), count: 4)
    var startBlockNodes: [SKSpriteNode] = []
    var startSquares: [[SKSpriteNode]] = []
    var tappedSquareIndex: Int? = nil
    var selectedElement: [(String, CGPoint)]? = nil
    
    var startImages = [[("orangeQuarter",CGPoint(x: -19, y: -19)), ("redQuarter",CGPoint(x: 19, y: -19)), ("whiteQuarter",CGPoint(x: 19, y: 19)),
                         ("blueQuarter",CGPoint(x: -19, y: 19))], [ ("blueSquare", CGPoint(x: 0, y: 0))]]
    

    var colors = ["orange", "blue", "white", "red", "green", "pink", "purple", "yellow"]
    var usedColors = Set<String>()

    func getStartBlock() -> [(String, CGPoint)] {
        let randomElem = Int.random(in: 1...4)
        var squareArray: [(String, CGPoint)] = []
        switch randomElem {
        case 1: //square
            let color = getRandomColor2()
            squareArray.append(("\(color)Square", CGPoint(x: 0, y: 0)))
        case 2: //half + 2 quarters
            let color1 = getRandomColor2()
            let color2 = getRandomColor2()
            let color3 = getRandomColor2()
            
            let randomCase = Int.random(in: 1...4)
            switch randomCase {
            case 1: //2 quarters + low horizontal
                squareArray.append(("\(color1)HorizontalHalf", CGPoint(x: 0, y: -19)))
                squareArray.append(("\(color2)Quarter",CGPoint(x: 19, y: 19)))
                squareArray.append(("\(color3)Quarter",CGPoint(x: -19, y: 19)))
            case 2: //2 quarters + high horizontal
                squareArray.append(("\(color1)HorizontalHalf", CGPoint(x: 0, y: 19)))
                squareArray.append(("\(color2)Quarter",CGPoint(x: 19, y: -19)))
                squareArray.append(("\(color3)Quarter",CGPoint(x: -19, y: -19)))
            case 3: //2 quarters + left vertical
                squareArray.append(("\(color1)VerticalHalf", CGPoint(x: -19, y: 0)))
                squareArray.append(("\(color2)Quarter",CGPoint(x: 19, y: -19)))
                squareArray.append(("\(color3)Quarter",CGPoint(x: 19, y: 19)))
            default:
                squareArray.append(("\(color1)VerticalHalf", CGPoint(x: 19, y: 0)))
                squareArray.append(("\(color2)Quarter",CGPoint(x: -19, y: -19)))
                squareArray.append(("\(color3)Quarter",CGPoint(x: -19, y: 19)))
            }
        case 3: //four quartes
            let color1 = getRandomColor2()
            let color2 = getRandomColor2()
            let color3 = getRandomColor2()
            let color4 = getRandomColor2()
            squareArray.append(("\(color1)Quarter",CGPoint(x: -19, y: -19)))
            squareArray.append(("\(color2)Quarter",CGPoint(x: -19, y: 19)))
            squareArray.append(("\(color3)Quarter",CGPoint(x: 19, y: 19)))
            squareArray.append(("\(color4)Quarter",CGPoint(x: 19, y: -19)))
        
        default: //half + half
            let color1 = getRandomColor2()
            let color2 = getRandomColor2()
            let randomCase = Int.random(in: 1...2)
            if randomCase == 1 {
                squareArray.append(("\(color1)VerticalHalf", CGPoint(x: 19, y: 0)))
                squareArray.append(("\(color2)VerticalHalf", CGPoint(x: -19, y: 0)))
            } else {
                squareArray.append(("\(color1)HorizontalHalf", CGPoint(x: 0, y: 19)))
                squareArray.append(("\(color2)HorizontalHalf", CGPoint(x: 0, y: -19)))
            }
        }
        usedColors = []
        colors.shuffle()
        
        return squareArray
    }
    
    private func getRandomColor2() -> String {
        if usedColors.count == colors.count {
            usedColors = [] // Очищаем Set
            colors.shuffle()
        }
        var randomColor: String
        repeat {
            randomColor = colors.randomElement()!
        } while usedColors.contains(randomColor)
        usedColors.insert(randomColor)
        return randomColor
    }

    func selectElement(at index: Int) {
        if tappedSquareIndex == index {
            deselectAll()
        } else {
            tappedSquareIndex = index
            selectedElement = startImages[index]
            startSquares.forEach { $0.forEach{$0.setScale(1.0)} }
            startSquares[index].forEach{$0.setScale(1.2)}
        }
    }
    
    func deselectAll() {
        tappedSquareIndex = nil
        selectedElement = nil
        startSquares.forEach { $0.forEach{$0.setScale(1.0)} }
    }
    
    func placeElement(at position: (Int, Int), scene: GameScene) -> Bool{
        var flag = false
        guard let elementsToAdd = selectedElement else { return false}
        if isCellAvailable[position.0][position.1] == false {
            deselectAll()
            return false
        }
        if elements[position.0][position.1].isEmpty {
            for (name, offset) in elementsToAdd {
                elements[position.0][position.1].append((name, offset))
            }
            flag = true
            let randomStartBlock = getStartBlock()
            changeStartBlock(newBlock: randomStartBlock, scene: scene)
        }
        
        deselectAll()
        
        return flag
    }
    
    func updateStartBlock(scene: GameScene) {
        // Обновляем графическое представление стартовых блоков
        for (index, block) in startBlockNodes.enumerated() {
            // Удаляем старые узлы
            startSquares[index].forEach { $0.removeFromParent() }
            startSquares[index].removeAll()

            // Добавляем новые узлы для стартового блока
            for (name, offset) in startImages[index] {
                let square = SKSpriteNode(imageNamed: name)
                square.position = CGPoint(x: block.position.x + offset.x, y: block.position.y + offset.y)
                square.name = name
                scene.addChild(square)
                startSquares[index].append(square)
            }
        }
    }
    
    func changeStartBlock(newBlock: [(String, CGPoint)], scene: GameScene) {
        guard let tappedSquareIndex = tappedSquareIndex else { return }
        
        // Обновляем логические данные
        startImages[tappedSquareIndex] = newBlock
        
        // Обновляем графическое представление
        updateStartBlock(scene: scene) // Передаем текущую сцену
    }

    func removeElements(at positions: [(Int, Int, String)], gameLogic: GameLogic) {
        for (row, col, name) in positions {
            if let index = elements[row][col].firstIndex(where: { $0.0 == name }) {
                let color = gameLogic.getColor(from: name)
                matchCount[color, default: 0] += 1
                elements[row][col].remove(at: index)
            }
        }
    }
}


