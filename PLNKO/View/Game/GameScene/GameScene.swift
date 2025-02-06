
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
        let startBlockSize: CGFloat = 75
        let yOffset: CGFloat = startBlockSize / 2
        let startXPositions = [startBlockSize / 2, size.width - startBlockSize / 2]

        for (index, startX) in startXPositions.enumerated() {
            let block = SKSpriteNode(imageNamed: "startBlockImage")
            block.size = CGSize(width: startBlockSize, height: startBlockSize)
            block.position = CGPoint(x: startX, y: yOffset)
            addChild(block)

            gameBoard.startBlockNodes.append(block)
            var squareGroup = [SKSpriteNode]() // Группа элементов для текущего стартового блока

            for (name, offset) in gameBoard.startImages1[index] { // Используем startImages1
                let square = SKSpriteNode(imageNamed: name)
                square.position = CGPoint(x: block.position.x + offset.x, y: block.position.y + offset.y)
                square.name = name
                addChild(square)
                squareGroup.append(square)
            }

            gameBoard.startSquares1.append(squareGroup)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Обработка нажатия на стартовые блоки
        if let index = gameRenderer.handleStartBlockTouch(location: location, gameBoard: gameBoard) {
            gameBoard.selectElement(at: index)
        } else if let (row, col) = gameRenderer.handleGameBoardTouch(location: location, gameBoard: gameBoard) {
            // Размещаем элемент на игровом поле
            gameLogic.placeElement(on: gameBoard, at: (row, col))
            gameRenderer.updateGameBoard(on: self, gameBoard: gameBoard)
            // Запускаем процесс матчинга и обновления поля
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.startMatchCycle(row: row, col: col, iteration: 0)
            }
        } else {
            gameBoard.deselectAll()
        }
    }
    
    private func startMatchCycle(row: Int, col: Int, iteration: Int) {
        guard iteration < 8 else {
            print("Превышено максимальное количество итераций матчинга")
            return // Останавливаем цикл, если достигнут лимит итераций
        }

        let dispatchGroup = DispatchGroup() // Создаем группу для координации задач

        // Шаг 1: Проверяем матчи и удаляем элементы
        gameLogic.checkAndRemoveMatches(on: gameBoard)

        // Шаг 2: Обновляем игровое поле
        dispatchGroup.enter() // Входим в группу
        DispatchQueue.main.async {
            self.gameRenderer.updateGameBoard(on: self, gameBoard: self.gameBoard)
            dispatchGroup.leave() // Выходим из группы после обновления
        }

        // Шаг 3: Преобразуем половинки в квадраты
        dispatchGroup.notify(queue: .main) { // Ждем завершения предыдущего шага
            dispatchGroup.enter()
            if self.gameRenderer.changeHalfToSquare(scene: self, gameBoard: self.gameBoard) {
//                dispatchGroup.enter() // Входим в группу
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.gameRenderer.updateGameBoard(on: self, gameBoard: self.gameBoard)
                    dispatchGroup.leave() // Выходим из группы после обновления
                }
            } else {
                dispatchGroup.leave() // Если нет изменений, сразу выходим
            }
        }

        // Шаг 4: Преобразуем четвертинки в половинки
        dispatchGroup.notify(queue: .main) { // Ждем завершения предыдущего шага
            dispatchGroup.enter()
            if self.gameRenderer.changeQuarterToHalf(gameBoard: self.gameBoard) {
//                dispatchGroup.enter() // Входим в группу
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.gameRenderer.updateGameBoard(on: self, gameBoard: self.gameBoard)
                    dispatchGroup.leave() // Выходим из группы после обновления
                }
            } else {
                dispatchGroup.leave() // Если нет изменений, сразу выходим
            }
        }

        // Шаг 5: Проверяем, остались ли матчи
        dispatchGroup.notify(queue: .main) { // Ждем завершения всех предыдущих шагов
            if self.gameLogic.hasMatches(on: self.gameBoard) {
                // Если матчи есть, продолжаем цикл через небольшую задержку
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.startMatchCycle(row: row, col: col, iteration: iteration + 1)
                }
            } else {
                // Если матчей больше нет, завершаем процесс
                print("Матчинг завершен после \(iteration) итераций")
            }
        }
    }
   
}
