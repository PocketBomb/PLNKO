
import SwiftUI
import SpriteKit

class GameScene: SKScene {
    private var gameBoard: GameBoard
    private var gameRenderer: GameRenderer
    var gameBoardCells: [[Bool]]
    var elements: [[[(String, CGPoint)]]]
    var goal: [String: Int]
    var timerLabel: SKLabelNode!
    
    private var remainingTime: Int = 90
    var timer: Timer?
    private var gameLogic = GameLogic()
    var removeButton: SKSpriteNode!
    var changeButton: SKSpriteNode!
    
    //boosts
    private var isRemoveModeActive = false
    private var isChangeModeActive = false
    private var firstSelectedCell: (Int, Int)? = nil
    
    
    init(size: CGSize, goal: [String: Int], elements: [[[(String, CGPoint)]]], gameBoardCells: [[Bool]]) {
        self.goal = goal
        self.elements = elements
        self.gameBoardCells = gameBoardCells
        self.gameBoard = GameBoard(size: size, elements: elements, isCellAvailable: gameBoardCells)
        self.gameRenderer = GameRenderer(gameLogic: gameLogic, isCellAvailable: gameBoardCells)
        super.init(size: size)
        backgroundColor = .clear
        gameBoard.startImages[0] = gameBoard.getStartBlock()
        gameBoard.startImages[1] = gameBoard.getStartBlock()
        addBackgroundImage()
        gameRenderer.setupGameBoard(on: self, gameBoard: gameBoard)
        setupStartBlocks()
        startTimer()
        addTimerLabel()
        setupRemoveButton()
        setupChangeButton()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChangeButton() {
        let multi = SizeConverter.isSmallScreen ? 0.7 : 1
        if LightningManager.shared.currentLightnings < 300 {
            changeButton = SKSpriteNode(imageNamed: "changeButtonNoMoney")
        } else {
            changeButton = SKSpriteNode(imageNamed: "changeButton")
        }
        changeButton.size = CGSize(width: 65*multi, height: 72.22*multi)
        changeButton.position = CGPoint(x: SizeConverter.isSmallScreen ? 35 : 50, y: SizeConverter.isSmallScreen ? 57 : 140)
        changeButton.zPosition = 1
        changeButton.name = "changeButton"
        addChild(changeButton)
    }
    
    private func setupRemoveButton() {
        let multi = SizeConverter.isSmallScreen ? 0.7 : 1
        if LightningManager.shared.currentLightnings < 500 {
            removeButton = SKSpriteNode(imageNamed: "removeButtonNoMoney")
        } else {
            removeButton = SKSpriteNode(imageNamed: "removeButton")
        }
        removeButton.size = CGSize(width: 65*multi, height: 72.22*multi)
        removeButton.position = CGPoint(x: size.width - (SizeConverter.isSmallScreen ? 35 : 50), y: SizeConverter.isSmallScreen ? 57 : 140)
        removeButton.zPosition = 1
        removeButton.name = "removeButton"
        addChild(removeButton)
    }
    
    public func startTimer() {
            // Создаем таймер, который уменьшает оставшееся время каждую секунду
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.remainingTime > 0 {
                self.remainingTime -= 1
                self.updateTimerLabel()
            } else {
                self.endGameDueToTimeout()
            }
        }
    }
        
    private func addTimerLabel() {
        // Создаем текстовый узел для отображения времени
        if SizeConverter.isSmallScreen {
            timerLabel = SKLabelNode(text: "\(remainingTime)s")
        } else {
            timerLabel = SKLabelNode(text: "Time: \(remainingTime)s")
        }
        timerLabel.fontName = Resources.Fonts.jomhuria
        timerLabel.fontSize = 33
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: size.width / 2, y: SizeConverter.isSmallScreen ? 80 : 140)
        addChild(timerLabel)
    }
    
    private func updateTimerLabel() {
        // Обновляем текст таймера
        if SizeConverter.isSmallScreen {
            timerLabel.text = "\(remainingTime)s"
        } else {
            timerLabel.text = "Time: \(remainingTime)s"
        }
    }

    private func addBackgroundImage() {
        let background = SKSpriteNode(imageNamed: SizeConverter.isSmallScreen ? "gameSceneBackSmall" :"gameSceneBack")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }
    
    private func setupStartBlocks() {
        let startBlockSize: CGFloat = 75
        let yOffset: CGFloat = startBlockSize / 2 + 20
        let startXPositions = [startBlockSize / 2 + (SizeConverter.isSmallScreen ? 65 : 40), size.width - startBlockSize / 2-(SizeConverter.isSmallScreen ? 65 : 40)]

        for (index, startX) in startXPositions.enumerated() {
            let block = SKSpriteNode(imageNamed: "startBlockImage")
            block.size = CGSize(width: startBlockSize*1.3, height: startBlockSize*1.3)
            block.position = CGPoint(x: startX, y: yOffset)
            addChild(block)

            gameBoard.startBlockNodes.append(block)
            var squareGroup = [SKSpriteNode]() // Группа элементов для текущего стартового блока

            for (name, offset) in gameBoard.startImages[index] { // Используем startImages1
                let square = SKSpriteNode(imageNamed: name)
                square.position = CGPoint(x: block.position.x + offset.x, y: block.position.y + offset.y)
                square.name = name
                addChild(square)
                squareGroup.append(square)
            }

            gameBoard.startSquares.append(squareGroup)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let node = atPoint(location) as? SKSpriteNode, node.name == "removeButton" && !isChangeModeActive && LightningManager.shared.currentLightnings >= 500 {
            let _ = LightningManager.shared.subtractLightnings(500)
            if LightningManager.shared.currentLightnings < 300 {
                changeButton.texture = SKTexture(imageNamed: "changeButtonNoMoney")
            }
            isRemoveModeActive = true
            print("Активирован режим удаления!")
            removeButton.setScale(1.2)
            return
        }
        if let node = atPoint(location) as? SKSpriteNode, node.name == "changeButton"  && !isRemoveModeActive && LightningManager.shared.currentLightnings >= 300{
            let _ = LightningManager.shared.subtractLightnings(300)
            if LightningManager.shared.currentLightnings < 500 {
                removeButton.texture = SKTexture(imageNamed: "removeButtonNoMoney")
            }
            changeButton.setScale(1.2)
            isChangeModeActive = true
            firstSelectedCell = nil
            return
        }
        if isChangeModeActive {
            if let (row, col) = gameRenderer.handleRemoveBoostTouch(location: location, gameBoard: gameBoard) {
                if firstSelectedCell == nil {
                    firstSelectedCell = (row, col)
                } else {
                    let secondSelectedCell = (row, col)
                    print("Вторая клетка выбрана: \(secondSelectedCell)")
                    swapCells(first: firstSelectedCell!, second: secondSelectedCell)
                    isChangeModeActive = false // Отключаем режим замены
                    firstSelectedCell = nil
                    if LightningManager.shared.currentLightnings < 300 {
                        changeButton.texture = SKTexture(imageNamed: "changeButtonNoMoney")
                    }
                    changeButton.setScale(1.0)
                }
            }
            return
        }
        if isRemoveModeActive {
            if let (row, col) = gameRenderer.handleRemoveBoostTouch(location: location, gameBoard: gameBoard) {
                clearCell(at: (row, col))
                isRemoveModeActive = false // Отключаем режим удаления после очистки клетки
                if LightningManager.shared.currentLightnings < 500 {
                    removeButton.texture = SKTexture(imageNamed: "removeButtonNoMoney")
                }
                removeButton.setScale(1.0)
            }
            return
        }
        
        // Обработка нажатия на стартовые блоки
        if let index = gameRenderer.handleStartBlockTouch(location: location, gameBoard: gameBoard) {
            gameBoard.selectElement(at: index)
        } else if let (row, col) = gameRenderer.handleGameBoardTouch(location: location, gameBoard: gameBoard) {
            // Размещаем элемент на игровом поле
            gameLogic.placeElement(on: gameBoard, at: (row, col), scene: self)
            gameRenderer.updateGameBoard(on: self, gameBoard: gameBoard)
            // Запускаем процесс матчинга и обновления поля
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.startMatchCycle(row: row, col: col, iteration: 0)
                
                if self.isGoalCompleted() {
                    self.endGame()
                }
            }
        } else {
            gameBoard.deselectAll()
        }
    }
    
    private func swapCells(first: (Int, Int), second: (Int, Int)) {
       guard first != second else {
           print("Нельзя выбрать одну и ту же клетку дважды!")
           return
       }

       // Временно сохраняем содержимое первой клетки
       let tempElements = gameBoard.elements[first.0][first.1]

       // Меняем содержимое клеток местами
       gameBoard.elements[first.0][first.1] = gameBoard.elements[second.0][second.1]
       gameBoard.elements[second.0][second.1] = tempElements

       // Обновляем графическое представление
       gameRenderer.updateGameBoard(on: self, gameBoard: gameBoard)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.startMatchCycle(row: first.0, col: first.1, iteration: 0)
            
            if self.isGoalCompleted() {
                self.endGame()
            }
        }

       print("Содержимое клеток \(first) и \(second) было успешно поменяно местами!")
   }
    
    private func clearCell(at position: (Int, Int)) {
        print(position)
        guard !gameBoard.elements[position.0][position.1].isEmpty else {
            print("Клетка уже пуста!")
            return
        }
        
        // Добавляем элементы в matchCount
        for element in gameBoard.elements[position.0][position.1] {
            gameBoard.removeElements(at: [(position.0, position.1, element.0)], gameLogic: gameLogic)
        }


        // Обновляем графическое представление
        gameRenderer.updateGameBoard(on: self, gameBoard: gameBoard)
        if self.isGoalCompleted() {
            self.endGame()
        }
        print("Клетка очищена! Текущее состояние matchCount: \(gameBoard.matchCount)")
    }
    
    private func isGoalCompleted() -> Bool {
        for (color, targetValue) in goal {
            if let matchCountValue = gameBoard.matchCount[color], matchCountValue < targetValue {
                return false // Если хотя бы один цвет не достиг цели, игра продолжается
            }
        }
        return true // Все цвета достигли целей
    }
    
    private func endGameDueToTimeout() {
            // Останавливаем таймер
        timer?.invalidate()
        
        print("Игра завершена по истечении времени!")
        
        // Удаляем все элементы с поля
        for row in 0..<gameBoard.elements.count {
            for col in 0..<gameBoard.elements[row].count {
                gameBoard.elementNodes[row][col].forEach { $0?.removeFromParent() }
                gameBoard.elementNodes[row][col].removeAll()
                gameBoard.elements[row][col].removeAll()
            }
        }
        self.isPaused = true
        // Показываем GameOverView
        NotificationCenter.default.post(name: NSNotification.Name("GameOver"), object: nil)
    }

    private func endGame() {
        print("Цель достигнута! Игра завершена!")

        for row in 0..<gameBoard.elements.count {
            for col in 0..<gameBoard.elements[row].count {
                gameBoard.elementNodes[row][col].forEach { $0?.removeFromParent() }
                gameBoard.elementNodes[row][col].removeAll()
                gameBoard.elements[row][col].removeAll()
            }
        }

        self.isPaused = true
        gameBoard.deselectAll()
        LightningManager.shared.addLightnings(100)
        NotificationCenter.default.post(name: NSNotification.Name("UserWin"), object: nil)
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
            if self.gameRenderer.changeQuarterToHalf(gameBoard: self.gameBoard, gameLogic: self.gameLogic) {
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
