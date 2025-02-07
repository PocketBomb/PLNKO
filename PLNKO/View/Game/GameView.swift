import SwiftUI
import SpriteKit
struct GameView: View {
    @Environment(\.presentationMode) var presentationMode
    var currentLevel = 10
    var sceneSize = CGSize(width: 343, height: SizeConverter.isSmallScreen ? 450 : 558)
    @State private var isGameOver = false
    @State private var scene: GameScene!
    private let levelManager = LevelManager.shared
    @State private var matchCount: [String: Int] = [:]
    
    // Текущие данные уровня
    @State private var elements: [[[(String, CGPoint)]]] = []
    @State private var gameBoardCells: [[Bool]] = []
    @State private var goal: [String: Int] = [:]

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
                            
                            Image("level\(currentLevel)Label")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 133, alignment: .bottom)
                        }
                    }
                    .zIndex(2)
                    .frame(maxHeight: SizeConverter.isSmallScreen ? 115 : 125)
                    
                    GoalsView(goals: goal, matchCount: matchCount)
                        .padding(.top, SizeConverter.isSmallScreen ? 5 : 20)
                    
                    if let scene = self.scene {
                        SpriteView(scene: scene, options: [.allowsTransparency])
                            .frame(width: 343, height:SizeConverter.isSmallScreen ? 450 : 558)
                            .ignoresSafeArea()
                            .background(.clear)
                            .zIndex(3)
                            .id(scene)
                            .padding(.top, -2)
                    } else {
                        ProgressView("Загрузка уровня...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 343, height: 558)
                    }
                    
                    Spacer()
                }
                if isGameOver {
                    GameOverView(onRestart: {
                        isGameOver = false
                        reloadLevel()
                    })
                        .transition(.opacity) // Добавляем анимацию появления
                        .zIndex(15)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                // Загружаем данные уровня
                if let levelData = levelManager.getLevelData(levelNumber: currentLevel) {
                    self.elements = levelData.elements
                    self.gameBoardCells = levelData.gameBoardCells
                    self.goal = levelData.goal
                    
                    // Создаем экземпляр GameScene после загрузки данных
                    self.scene = GameScene(size: sceneSize, goal: goal, elements: elements, gameBoardCells: gameBoardCells)
                    self.scene?.scaleMode = .aspectFill
                } else {
                    print("Ошибка загрузки данных уровня!")
                }
                NotificationCenter.default.addObserver(forName: NSNotification.Name("MatchCountUpdated"), object: nil, queue: .main) { notification in
                        if let updatedMatchCount = notification.object as? [String: Int] {
                            self.matchCount = updatedMatchCount
                        }
                    }
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("GameOver"),
                    object: nil,
                    queue: .main
                ) { _ in
                    self.isGameOver = true // Показываем GameOverView
                }
            }
            .onDisappear {
                    // Отписываемся от уведомлений при выходе из экрана
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name("MatchCountUpdated"), object: nil)
                }
        }
    }
    
    
    func reloadLevel() {
        self.scene = GameScene(size: sceneSize, goal: goal, elements: elements, gameBoardCells: gameBoardCells)
        self.scene?.scaleMode = .aspectFill
    }
}
