import SwiftUI
import SpriteKit

struct GameView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var scene: GameScene = {
        let scene = GameScene(size: CGSize(width: 343, height: 558))
        scene.scaleMode = .aspectFill
        return scene
    }()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Фоновое изображение
                Image(Resources.Game.Views.gameBackground)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(0)
                
                VStack(spacing: 0) {
                    // Верхняя часть с кнопкой назад и заголовком
                    ZStack(alignment: .top) {
                        Image(Resources.Welcome.Views.infoTopView)
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: UIScreen.main.bounds.width)
                            .padding(.bottom, 0)
                        
                        VStack(spacing: -50) {
                            HStack {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Image(Resources.Game.Buttons.backButton)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 49, height: 41)
                                }
                                
                                Spacer()
                                
                                Button(action: {}) {
                                    Image(Resources.Game.Buttons.pauseButton)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 49, height: 41)
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: SizeConverter.isSmallScreen ? 107 : 115, alignment: .bottom)
                            
                            Image("level1Label")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 133, alignment: .bottom)
                        }
                    }
                    .zIndex(2)
                    .frame(maxHeight: 125)
                    
                    Spacer(minLength: 100)
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .frame(width: 343, height: 558)
                        .ignoresSafeArea()
                        .background(.clear)
                        .zIndex(3)
                        .id(scene)
                    
                    Spacer()
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
    }
}

class GameScene: SKScene {
    
    var elements: [[[(String, CGPoint)]]] = [
        [[], [], [], [("whiteSquare", CGPoint(x: 0, y: 0))]],
        [[], [("redHorizontalHalf", CGPoint(x: 0, y: 19)), ("orangeHorizontalHalf", CGPoint(x: 0, y: -19))], [], []],
        [[], [], [], [("redVerticalHalf", CGPoint(x: -19, y: 0)), ("greenVerticalHalf", CGPoint(x: 19, y: 0))]],
        [[], [], [("orangeVerticalHalf", CGPoint(x: -19, y: 0)), ("purpleVerticalHalf", CGPoint(x: 19, y: 0))], [("blueSquare", CGPoint(x: 0, y: 0))]]
    ]
    
    var startBlockNodes: [SKSpriteNode] = []
    var startSquares: [SKSpriteNode] = []
    var tappedSquareIndex: Int? = nil // Индекс тапнутого квадратика
    var selectedElement: (String, CGPoint)? = nil // Храним выбранный элемент
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

    override func didMove(to view: SKView) {}

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

    // Обработчик прикосновений
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Проверяем, на какой стартовый блок был сделан клик
        for (index, block) in startBlockNodes.enumerated() {
            if block.contains(location) {
                if let tappedIndex = tappedSquareIndex {
                    if tappedIndex == index {
                        // Если тот же квадратик уже тапнут, уменьшаем его
                        startSquares[tappedIndex].setScale(1.0)
                        tappedSquareIndex = nil
                        selectedElement = nil
                    } else {
                        // Если новый квадратик, то уменьшаем старый и увеличиваем новый
                        startSquares[tappedIndex].setScale(1.0)
                        startSquares[index].setScale(1.2)
                        tappedSquareIndex = index
                        selectedElement = (startSquares[index].texture!.description, CGPoint(x: 0, y: 0)) // Храним выбранный элемент
                    }
                } else {
                    // Если еще нет тапнутого квадратика, увеличиваем текущий
                    startSquares[index].setScale(1.2)
                    tappedSquareIndex = index
                    selectedElement = (startSquares[index].texture!.description, CGPoint(x: 0, y: 0)) // Храним выбранный элемент
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
                
                if blockRect.contains(location) {
                    // Если ячейка пустая, вставляем элемент
                    if elements[row][col].isEmpty, let selected = selectedElement {
                        guard let index = tappedSquareIndex else {return}
                        elements[row][col].append((startImages[index], CGPoint(x: 0, y: 0)))
                        let elementNode = SKSpriteNode(imageNamed: startImages[index])
                        elementNode.position = CGPoint(x: xPos + selected.1.x, y: yPos + selected.1.y)
                        addChild(elementNode)
                        print(elements)
                        // Уменьшаем размер квадратика в старте
                        startSquares[tappedSquareIndex!].setScale(1.0)
                        tappedSquareIndex = nil
                        selectedElement = nil
                    } else {
                        // Если ячейка занята, уменьшаем квадратик
                        guard let index = tappedSquareIndex else {return}
                        startSquares[index].setScale(1.0)
                        tappedSquareIndex = nil
                        selectedElement = nil
                    }
                }
            }
        }
    }
}
