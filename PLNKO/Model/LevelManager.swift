import Foundation

class LevelManager {
    static let shared = LevelManager() // Singleton
    
    private let userDefaults = UserDefaults.standard
    
    // Текущий уровень
    var currentLevel: Int {
        get {
            return userDefaults.integer(forKey: "currentLevel")
        }
        set {
            userDefaults.set(newValue, forKey: "currentLevel")
        }
    }
    
    // Максимальный открытый уровень
    var maxUnlockedLevel: Int {
        get {
            return userDefaults.integer(forKey: "maxUnlockedLevel")
        }
        set {
            if newValue > maxUnlockedLevel && newValue <= totalLevels {
                userDefaults.set(newValue, forKey: "maxUnlockedLevel")
            }
        }
    }
    
    // Общее количество уровней
    let totalLevels = 12
    
    // Данные о уровнях
    private let levelsData: [[String: Any]] = [
        ["number": 1,
         "elements": [
            [[], [], [], [("whiteSquare", CGPoint(x: 0, y: 0))]],
            [[], [("blueQuarter",CGPoint(x: -19, y: 19))], [], []],
            [[], [], [], [("redVerticalHalf", CGPoint(x: -19, y: 0)), ("greenVerticalHalf", CGPoint(x: 19, y: 0))]],
            [[], [], [], [("orangeSquare", CGPoint(x: 0, y: 0))]]
        ] as [[[(String, CGPoint)]]],
         "gameBoardCells": [
            [true, true, true, true],
            [true, false, true, true], // Вторая клетка во второй строке выколота
            [true, true, false, true], // Третья клетка в третьей строке выколота
            [true, true, true, true]
        ] as [[Bool]],
         "goal": [
            "white": 1,
            "blue": 1,
            "red": 1
        ] as [String: Int]],
        
        ["number": 2,
         "elements": [] as [[[(String, CGPoint)]]],
         "gameBoardCells": [] as [[Bool]],
         "goal": ["blue": 4, "red": 5] as [String: Int]],
        // Здесь вы можете добавить остальные 10 уровней с нужными параметрами
    ]
    
    // Приватный инициализатор для Singleton
    private init() {
        // Инициализируем начальные значения
        if userDefaults.integer(forKey: "currentLevel") == 0 {
            userDefaults.set(1, forKey: "currentLevel") // Начинаем с первого уровня
        }
        if userDefaults.integer(forKey: "maxUnlockedLevel") == 0 {
            userDefaults.set(1, forKey: "maxUnlockedLevel") // Первый уровень открыт по умолчанию
        }
    }
    
    // Метод для получения данных об уровне
    func getLevelData(levelNumber: Int) -> (elements: [[[(String, CGPoint)]]], gameBoardCells: [[Bool]], goal: [String: Int])? {
        guard levelNumber >= 1 && levelNumber <= totalLevels else { return nil }
        
        // Находим данные об уровне
        if let levelData = levelsData.first(where: { ($0["number"] as? Int) == levelNumber }) {
            return (
                elements: levelData["elements"] as! [[[(String, CGPoint)]]],
                gameBoardCells: levelData["gameBoardCells"] as! [[Bool]],
                goal: levelData["goal"] as! [String: Int]
            )
        }
        
        return nil
    }
    
    // Метод для перехода к следующему уровню
    func goToNextLevel() {
        let nextLevel = currentLevel + 1
        if nextLevel <= totalLevels {
            currentLevel = nextLevel
            maxUnlockedLevel = nextLevel
        } else {
            print("Это последний уровень!")
        }
    }
}
