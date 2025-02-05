
import SpriteKit

class GameBoard {
    var size: CGSize
    
    init(size: CGSize) {
        self.size = size
    }
    var elements: [[[(String, CGPoint)]]] = [
        [[], [], [], [("whiteSquare", CGPoint(x: 0, y: 0))]],
        [[], [("redHorizontalHalf", CGPoint(x: 0, y: 19)), ("orangeHorizontalHalf", CGPoint(x: 0, y: -19))], [], []],
        [[], [], [], [("redVerticalHalf", CGPoint(x: -19, y: 0)), ("greenVerticalHalf", CGPoint(x: 19, y: 0))]],
        [[], [], [("orangeVerticalHalf", CGPoint(x: -19, y: 0)), ("purpleVerticalHalf", CGPoint(x: 19, y: 0))], [("blueSquare", CGPoint(x: 0, y: 0))]]
    ]
    var elementNodes: [[[SKSpriteNode?]]] = Array(repeating: Array(repeating: [], count: 4), count: 4)
    var startBlockNodes: [SKSpriteNode] = []
    var startSquares: [SKSpriteNode] = []
    var tappedSquareIndex: Int? = nil
    var selectedElement: (String, CGPoint)? = nil
    let startImages = ["whiteSquare", "orangeSquare"]
    
    let startImages1 = [[[("redHorizontalHalf", CGPoint(x: 0, y: 19)), ("orangeHorizontalHalf", CGPoint(x: 0, y: -19))], [("whiteSquare", CGPoint(x: 0, y: 0))]]]

    func selectElement(at index: Int) {
        if tappedSquareIndex == index {
            startSquares[index].setScale(1.0)
            tappedSquareIndex = nil
            selectedElement = nil
        } else {
            tappedSquareIndex = index
            selectedElement = (startImages[index], CGPoint(x: 0, y: 0))
            startSquares[index].setScale(1.2)
            if index == 1 {
                startSquares[0].setScale(1.0)
            } else {
                startSquares[1].setScale(1.0)
            }
        }
    }
    
    func deselectAll() {
        tappedSquareIndex = nil
        selectedElement = nil
        startSquares[0].setScale(1.0)
        startSquares[1].setScale(1.0)
    }

    func placeElement(at position: (Int, Int)) {
        if let (name, offset) = selectedElement {
            elements[position.0][position.1].append((name, offset))
            selectedElement = nil
        }
    }

    func removeElements(at positions: [(Int, Int, String)]) {
        for (row, col, name) in positions {
            if let index = elements[row][col].firstIndex(where: { $0.0 == name }) {
                elements[row][col].remove(at: index)
            }
        }
    }
}


