import SwiftUI
import SpriteKit
struct GameView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var levelManager = LevelManager.shared
    @State var replayCounter = 0
    @State var currentLevel: Int
    var sceneSize = CGSize(width: 343, height: SizeConverter.isSmallScreen ? 450 : 558)
    @State private var isGameOver = false
    @State private var isUserWin = false
    @State private var isPaused = false
    @State private var isInfo = false
    @State private var isSwap = false
    @State private var scene: GameScene!
    @State private var matchCount: [String: Int] = [:]
    
    // Текущие данные уровня
    @State private var elements: [[[(String, CGPoint)]]] = []
    @State private var gameBoardCells: [[Bool]] = []
    @State private var goal: [String: Int] = [:]
    @State private var currentAchievementIndex: Int? = nil
    @State private var showAchievement = false

//    @State var isFirstLounch = true
    @AppStorage("isFirstLounch") private var isFirstLounch: Bool = true

    var body: some View {
        if isFirstLounch {
            FirstLounchInfoView(onBack: {
                presentationMode.wrappedValue.dismiss()
            }, onPlay: {
                isFirstLounch = false
            })
            
        } else {
            GeometryReader { geometry in
                ZStack {
                    // Фоновое изображение
                    Image(Resources.Game.Views.gameBackground)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .zIndex(0)
                    if isSwap {
                        Text("Swap two squares with a simple tap ")
                            .font(.custom(Resources.Fonts.jomhuria, size: 34))
                            .foregroundStyle(.yellow)
                            .position(CGPoint(x: UIScreen.main.bounds.width / 2, y:
                                                UIScreen.main.bounds.height - (SizeConverter.isSmallScreen ? 20 : 40)))
                            .zIndex(232)
                    }
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
                                        reloadLevel()
                                    }) {
                                        Image(Resources.Game.Buttons.backButton)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 49, height: 41)
                                            .padding(.bottom,  SizeConverter.isMediumScreen ? 15 : 0)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        isPaused = true
                                    }) {
                                        Image(Resources.Game.Buttons.pauseButton)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 49, height: 41)
                                            .padding(.bottom,  SizeConverter.isMediumScreen ? 15 : 0)
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
                        //                    .frame(maxHeight: SizeConverter.isSmallScreen ? 115 : 125)
                        
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
                    SpeedView()
                        .position(x: geometry.size.width - 55,
                                  y: geometry.size.height * (1.4/8) + (SizeConverter.isSmallScreen ? 35 : 20))
                    if isGameOver {
                        GameOverView(onRestart: {
                            isGameOver = false
                            reloadLevel()
                        }, onHome: {
                            isGameOver = false
                            presentationMode.wrappedValue.dismiss()
                        })
                    }
                    if isUserWin {
                        YouWinView(onRestart: {
                            isUserWin =  false
                            if currentLevel < 12 {
                                levelManager.goToNextLevel(level: currentLevel+1)
                            } else {
                                levelManager.goToNextLevel(level: 12)
                            }
                            if AchievementsManager.shared.claiming(index: 5) {
                                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                                    NotificationCenter.default.post(name: NSNotification.Name("AchievementClaimed"), object: 5)
                                }
                            }
                            reloadLevel()
                        }, onHome: {
                            isUserWin =  false
                            if currentLevel < 12 {
                                levelManager.goToNextLevel(level: currentLevel+1)
                            } else {
                                levelManager.goToNextLevel(level: 12)
                            }
                            presentationMode.wrappedValue.dismiss()
                        }, onNextLevel: {
                            isUserWin =  false
                            loadNextLevel()
                        })
                        .onAppear {
                            LightningManager.shared.addLightnings(100)
                        }
                    }
                    if isPaused {
                        PauseView(onCancel: {
                            isPaused = false
                            scene.isPaused = false
                            scene.startTimer()
                        }, onHome: {
                            isPaused = false
                            presentationMode.wrappedValue.dismiss()
                        }, onInfo: {
                            isInfo = true
                        })
                    }
                    if isInfo {
                        PauseInfoView(onBack: {
                            isInfo = false
                        })
                        .edgesIgnoringSafeArea(.all)
                    }
                    if showAchievement, let index = currentAchievementIndex {
                        Image("achievementImage\(index)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 365.5, height: 113)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            .transition(.opacity)
                            .zIndex(25)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    showAchievement = false
                                }
                            }
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
                        self.scene = GameScene(size: sceneSize, goal: goal, elements: elements, gameBoardCells: gameBoardCells, currentLevel: currentLevel)
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
                    
                    NotificationCenter.default.addObserver(
                        forName: NSNotification.Name("UserWin"),
                        object: nil,
                        queue: .main
                    ) { _ in
                        self.isUserWin = true // Показываем YouWinView
                    }
                    NotificationCenter.default.addObserver(
                        forName: NSNotification.Name("isSwap"),
                        object: nil,
                        queue: .main
                    ) { _ in
                        self.isSwap.toggle()
                    }
                    NotificationCenter.default.addObserver(forName: NSNotification.Name("AchievementClaimed"), object: nil, queue: .main) { notification in
                        if let index = notification.object as? Int {
                            self.currentAchievementIndex = index
                            self.showAchievement = true
                        }
                    }
                }
                .onDisappear {
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name("MatchCountUpdated"), object: nil)
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name("GameOver"), object: nil)
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UserWin"), object: nil)
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name("AchievementClaimed"), object: nil)
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name("isSwap"), object: nil)
                }
                .onChange(of: isPaused) { newValue in
                    if newValue == true {
                        scene?.timer?.invalidate()
                    }
                    scene?.isPaused = newValue
                }
            }
        }
    }
    
    
    func reloadLevel() {
//        replayCounter += 1
        if AchievementsManager.shared.claiming(index: 3) {
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                NotificationCenter.default.post(name: NSNotification.Name("AchievementClaimed"), object: 3)
            }
        }
        if AchievementsManager.shared.claiming(index: 4) {
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                NotificationCenter.default.post(name: NSNotification.Name("AchievementClaimed"), object: 4)
            }
        }
        self.scene.timer?.invalidate()
        self.scene = GameScene(size: sceneSize, goal: goal, elements: elements, gameBoardCells: gameBoardCells, currentLevel: currentLevel)
        self.scene?.scaleMode = .aspectFill
    }
    
    func loadNextLevel() {
        replayCounter = 0
        self.matchCount = [:]
        if currentLevel != 12 {
            currentLevel += 1
            levelManager.goToNextLevel(level: currentLevel)
        } else {
            currentLevel = 1
            levelManager.goToNextLevel(level: 12)
        }
        if let levelData = levelManager.getLevelData(levelNumber: currentLevel) {
            self.elements = levelData.elements
            self.gameBoardCells = levelData.gameBoardCells
            self.goal = levelData.goal
            // Создаем экземпляр GameScene после загрузки данных
            self.scene = GameScene(size: sceneSize, goal: goal, elements: elements, gameBoardCells: gameBoardCells, currentLevel: currentLevel)
            self.scene?.scaleMode = .aspectFill
        } else {
            print("Ошибка загрузки данных уровня!")
        }
    }
}
