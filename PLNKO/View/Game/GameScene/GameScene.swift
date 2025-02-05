
import SwiftUI
import SpriteKit


class GameScene: SKScene {
    private var gameBoard: GameBoard
    private var gameRenderer: GameRenderer
    private var gameLogic = GameLogic()

    override init(size: CGSize) {
        self.gameBoard = GameBoard(size: size)
        self.gameRenderer = GameRenderer(gameLogic: gameLogic)
        super.init(size: size)
        backgroundColor = .clear
        addBackgroundImage()
        gameRenderer.setupGameBoard(on: self, gameBoard: gameBoard)
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

    private func setupStartBlocks() {
        let startBlockSize: CGFloat = 90
        let yOffset: CGFloat = startBlockSize / 2
        let startXPositions = [startBlockSize / 2, size.width - startBlockSize / 2]

        for (index, startX) in startXPositions.enumerated() {
            let block = SKSpriteNode(imageNamed: "startBlockImage")
            block.size = CGSize(width: startBlockSize, height: startBlockSize)
            block.position = CGPoint(x: startX, y: yOffset)
            addChild(block)

            let square = SKSpriteNode(imageNamed: gameBoard.startImages[index])
            square.position = block.position
            addChild(square)

            gameBoard.startBlockNodes.append(block)
            gameBoard.startSquares.append(square)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Обработка нажатия на стартовые блоки
        if let index = gameRenderer.handleStartBlockTouch(location: location, gameBoard: gameBoard) {
            gameBoard.selectElement(at: index)
        } else if let (row, col) = gameRenderer.handleGameBoardTouch(location: location, gameBoard: gameBoard) {
            gameLogic.placeElement(on: gameBoard, at: (row, col))

            gameRenderer.updateGameBoard(on: self, gameBoard: gameBoard)

            // Задержка перед проверкой матчинга
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.gameLogic.checkAndRemoveMatches(on: self.gameBoard)
                self.gameRenderer.updateGameBoard(on: self, gameBoard: self.gameBoard)
                self.gameBoard.deselectAll()
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.gameRenderer.changeHalfToSquare(scene: self, gameBoard: self.gameBoard) {
                    self.gameRenderer.updateGameBoard(on: self, gameBoard: self.gameBoard)
                }
            }
        } else {
            gameBoard.deselectAll()
        }
    }
   
}
