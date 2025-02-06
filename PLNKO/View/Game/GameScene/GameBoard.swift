
import SpriteKit

class GameBoard {
    var size: CGSize
    
    init(size: CGSize) {
        self.size = size
    }
    
    var elements: [[[(String, CGPoint)]]] = [
        [[], [], [], [("whiteSquare", CGPoint(x: 0, y: 0))]],
        [[], [("blueQuarter",CGPoint(x: -19, y: 19))], [], []],
        [[], [], [], [("redVerticalHalf", CGPoint(x: -19, y: 0)), ("greenVerticalHalf", CGPoint(x: 19, y: 0))]],
        [[], [], [], [("orangeSquare", CGPoint(x: 0, y: 0))]]
    ]
    var elementNodes: [[[SKSpriteNode?]]] = Array(repeating: Array(repeating: [], count: 4), count: 4)
    var startBlockNodes: [SKSpriteNode] = []
    var startSquares: [SKSpriteNode] = []
    var startSquares1: [[SKSpriteNode]] = []
    var tappedSquareIndex: Int? = nil
    var selectedElement: (String, CGPoint)? = nil
    var selectedElement1: [(String, CGPoint)]? = nil
    let startImages = ["whiteSquare", "orangeSquare"]
    
    let startImages1 = [[("orangeQuarter",CGPoint(x: -19, y: -19)), ("redQuarter",CGPoint(x: 19, y: -19)), ("whiteQuarter",CGPoint(x: 19, y: 19)),
                         ("blueQuarter",CGPoint(x: -19, y: 19))], [ ("blueSquare", CGPoint(x: 0, y: 0))]]

    func selectElement(at index: Int) {
        if tappedSquareIndex == index {
            deselectAll()
        } else {
            tappedSquareIndex = index
            selectedElement1 = startImages1[index]
            startSquares1.forEach { $0.forEach{$0.setScale(1.0)} }
            startSquares1[index].forEach{$0.setScale(1.2)}
        }
    }
    
    func deselectAll() {
        tappedSquareIndex = nil
        selectedElement = nil
        startSquares1.forEach { $0.forEach{$0.setScale(1.0)} }
    }
    
    func placeElement(at position: (Int, Int)) {
        guard let elementsToAdd = selectedElement1 else { return } 
        for (name, offset) in elementsToAdd {
            elements[position.0][position.1].append((name, offset))
        }

        deselectAll()
    }

    func removeElements(at positions: [(Int, Int, String)]) {
        for (row, col, name) in positions {
            if let index = elements[row][col].firstIndex(where: { $0.0 == name }) {
                elements[row][col].remove(at: index)
            }
        }
    }
}


