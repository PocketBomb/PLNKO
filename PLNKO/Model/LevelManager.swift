import Foundation

class LevelManager: ObservableObject {
    static let shared = LevelManager() // Singleton
    
    private let userDefaults = UserDefaults.standard
    
    
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
    
    // Данные о уровнях("blueQuarter",CGPoint(x: -19, y: 19))
    private let levelsData: [[String: Any]] = [
        ["number": 1,
         "elements": [
            [[], [], [], [("whiteSquare", CGPoint(x: 0, y: 0))]],
            [[], [("redHorizontalHalf", CGPoint(x: 0, y: 19)), ("orangeHorizontalHalf", CGPoint(x: 0, y: -19))], [], []],
            [[], [], [], [("redVerticalHalf", CGPoint(x: -19, y: 0)), ("greenVerticalHalf", CGPoint(x: 19, y: 0))]],
            [[], [], [("orangeVerticalHalf", CGPoint(x: -19, y: 0)), ("purpleVerticalHalf", CGPoint(x: 19, y: 0))], [("blueSquare", CGPoint(x: 0, y: 0))]]
        ] as [[[(String, CGPoint)]]],
         "gameBoardCells": [
            [true, true, true, true],
            [true, true, true, true], // Вторая клетка во второй строке выколота
            [true, true, true, true], // Третья клетка в третьей строке выколота
            [true, true, true, true]
        ] as [[Bool]],
         "goal": [
            "red": 3,
            "orange": 3,
            "white": 3
        ] as [String: Int]],
        
        ["number": 2,
         "elements": [
            [[("greenSquare", CGPoint(x: 0, y: 0))], [("purpleHorizontalHalf", CGPoint(x: 0, y: 19)), ("redHorizontalHalf", CGPoint(x: 0, y: -19))], [("greenVerticalHalf", CGPoint(x: -19, y: 0)),("orangeQuarter",CGPoint(x: 19, y: 19)), ("purpleQuarter",CGPoint(x: 19, y: -19))], []],
            [[("purpleVerticalHalf", CGPoint(x: -19, y: 0)),("orangeQuarter",CGPoint(x: 19, y: 19)), ("redQuarter",CGPoint(x: 19, y: -19))], [], [], []],
            [[], [("orangeVerticalHalf", CGPoint(x: 19, y: 0)),("redQuarter",CGPoint(x: -19, y: 19)), ("greenQuarter",CGPoint(x: -19, y: -19))], [("greenQuarter",CGPoint(x: -19, y: 19)), ("orangeQuarter",CGPoint(x: 19, y: 19)), ("purpleQuarter",CGPoint(x: -19, y: -19)), ("redQuarter",CGPoint(x: 19, y: -19))], [("purpleQuarter",CGPoint(x: -19, y: 19)), ("redQuarter",CGPoint(x: 19, y: 19)), ("orangeQuarter",CGPoint(x: -19, y: -19)), ("greenQuarter",CGPoint(x: 19, y: -19))]],
            [[], [], [("orangeQuarter",CGPoint(x: -19, y: 19)), ("greenQuarter",CGPoint(x: 19, y: 19)), ("purpleQuarter",CGPoint(x: -19, y: -19)), ("redQuarter",CGPoint(x: 19, y: -19))], [("redQuarter",CGPoint(x: -19, y: 19)), ("orangeQuarter",CGPoint(x: 19, y: 19)), ("purpleQuarter",CGPoint(x: -19, y: -19)), ("greenQuarter",CGPoint(x: 19, y: -19))]]
        ] as [[[(String, CGPoint)]]],
         "gameBoardCells": [
            [true, true, true, true],
            [true, false, false, true],
            [true, true, true, true],
            [true, true, true, true]
        ] as [[Bool]],
         "goal": [
            "red": 5,
            "orange": 5,
            "green": 5
        ] as [String: Int]],
        ["number": 3,
         "elements": [
            [[], [], [], []],
            [[], [], [("orangeSquare", CGPoint(x: 0, y: 0))], []],
            [[], [], [], []],
            [[], [("purpleVerticalHalf", CGPoint(x: 19, y: 0)),("orangeQuarter",CGPoint(x: -19, y: 19)), ("greenQuarter",CGPoint(x: -19, y: -19))], [], []]
        ] as [[[(String, CGPoint)]]],
         "gameBoardCells": [
            [false, true, true, false],
            [true, true, true, true],
            [true, true, true, true],
            [false, true, true, false]
        ] as [[Bool]],
         "goal": [
            "red": 10,
            "orange": 8,
            "green": 4
        ] as [String: Int]],
        ["number": 4,
         "elements": [
            [[], [], [("purpleHorizontalHalf", CGPoint(x: 0, y: 19)), ("blueQuarter",CGPoint(x: -19, y: -19)), ("yellowQuarter",CGPoint(x: 19, y: -19))], []],
            [[("purpleQuarter",CGPoint(x: -19, y: 19)), ("greenQuarter",CGPoint(x: 19, y: 19)), ("yellowQuarter",CGPoint(x: -19, y: -19)), ("orangeQuarter",CGPoint(x: 19, y: -19))], [], [], []],
            [[], [], [("pinkVerticalHalf", CGPoint(x: -19, y: 0)), ("greenVerticalHalf", CGPoint(x: 19, y: 0))], []],
            [[], [], [], []]
        ] as [[[(String, CGPoint)]]],
         "gameBoardCells": [
            [false, true, true, false],
            [true, true, true, true],
            [true, true, true, true],
            [false, true, true, false]
        ] as [[Bool]],
         "goal": [
            "pink": 7,
            "orange": 6,
            "blue": 6
        ] as [String: Int]],
        ["number": 5,
         "elements": [
            [[], [], [("purpleHorizontalHalf", CGPoint(x: 0, y: 19)), ("blueQuarter",CGPoint(x: -19, y: -19)), ("yellowQuarter",CGPoint(x: 19, y: -19))], []],
            [[], [("pinkVerticalHalf", CGPoint(x: -19, y: 0)), ("greenVerticalHalf", CGPoint(x: 19, y: 0))], [], []],
            [[], [], [], [("blueSquare", CGPoint(x: 0, y: 0))]],
            [[], [("purpleQuarter",CGPoint(x: -19, y: 19)), ("greenQuarter",CGPoint(x: 19, y: 19)), ("yellowQuarter",CGPoint(x: -19, y: -19)), ("orangeQuarter",CGPoint(x: 19, y: -19))], [], []]
        ] as [[[(String, CGPoint)]]],
         "gameBoardCells": [
            [false, true, true, false],
            [true, true, true, true],
            [true, true, true, true],
            [false, true, true, false]
        ] as [[Bool]],
         "goal": [
            "green": 7,
            "purple": 4,
            "blue": 7
        ] as [String: Int]],
        ["number": 6,
         "elements": [
            [[], [], [], [("pinkHorizontalHalf", CGPoint(x: 0, y: -19)), ("orangeQuarter",CGPoint(x: -19, y: 19)), ("blueQuarter",CGPoint(x: 19, y: 19))]],
            [[], [("purpleHorizontalHalf", CGPoint(x: 0, y: 19)), ("blueHorizontalHalf", CGPoint(x: 0, y: -19))], [], []],
            [[], [], [], []],
            [[("purpleHorizontalHalf", CGPoint(x: 0, y: 19)), ("redHorizontalHalf", CGPoint(x: 0, y: -19))], [], [], []]
        ] as [[[(String, CGPoint)]]],
         "gameBoardCells": [
            [true, true, true, true],
            [true, true, false, true],
            [true, false, true, true],
            [true, true, true, true]
        ] as [[Bool]],
         "goal": [
            "pink": 5,
            "yellow": 5,
            "purple": 6
        ] as [String: Int]],
        ["number": 7,
         "elements": [
            [[], [("pinkSquare", CGPoint(x: 0, y: 0))], [], [("orangeVerticalHalf", CGPoint(x: -19, y: 0)), ("yellowQuarter",CGPoint(x: 19, y: -19)), ("purpleQuarter",CGPoint(x: 19, y: 19))]],
            [[], [("yellowVerticalHalf", CGPoint(x: 19, y: 0)), ("pinkQuarter",CGPoint(x: -19, y: -19)), ("purpleQuarter",CGPoint(x: -19, y: 19))], [("pinkVerticalHalf", CGPoint(x: -19, y: 0)), ("greenQuarter",CGPoint(x: 19, y: -19)), ("orangeQuarter",CGPoint(x: 19, y: 19))], []],
            [[], [("purpleQuarter",CGPoint(x: -19, y: 19)), ("orangeQuarter",CGPoint(x: 19, y: 19)), ("blueQuarter",CGPoint(x: -19, y: -19)), ("pinkQuarter",CGPoint(x: 19, y: -19))], [], [("purpleHorizontalHalf", CGPoint(x: 0, y: 19)), ("orangeQuarter",CGPoint(x: -19, y: -19)), ("yellowQuarter",CGPoint(x: 19, y: -19))]],
            [[], [], [], []]
        ] as [[[(String, CGPoint)]]],
         "gameBoardCells": [
            [true, true, true, true],
            [true, true, true, true],
            [true, true, true, true],
            [true, true, true, true]
        ] as [[Bool]],
         "goal": [
            "pink": 6,
            "green": 4,
            "blue": 3
        ] as [String: Int]],
        ["number": 8,
         "elements": [
            [[("purpleQuarter",CGPoint(x: -19, y: 19)), ("greenQuarter",CGPoint(x: 19, y: 19)), ("blueQuarter",CGPoint(x: -19, y: -19)), ("pinkQuarter",CGPoint(x: 19, y: -19))], [("orangeSquare", CGPoint(x: 0, y: 0))], [], [("whiteVerticalHalf", CGPoint(x: -19, y: 0)), ("purpleQuarter",CGPoint(x: 19, y: 19)), ("redQuarter",CGPoint(x: 19, y: -19))]],
            [[], [("blueVerticalHalf", CGPoint(x: 19, y: 0)), ("greenQuarter",CGPoint(x: -19, y: -19)), ("purpleQuarter",CGPoint(x: -19, y: 19))], [], []],
            [[("pinkVerticalHalf", CGPoint(x: -19, y: 0)), ("purpleQuarter",CGPoint(x: 19, y: -19)), ("orangeQuarter",CGPoint(x: 19, y: 19))], [], [], []],
            [[], [], [], []]
        ] as [[[(String, CGPoint)]]],
         "gameBoardCells": [
            [true, true, true, true],
            [true, true, true, true],
            [true, true, false, false],
            [true, true, false, false]
        ] as [[Bool]],
         "goal": [
            "orange": 4,
            "white": 9,
            "blue": 5
        ] as [String: Int]],
        ["number": 9,
         "elements": [
            [[("purpleQuarter",CGPoint(x: -19, y: 19)), ("greenQuarter",CGPoint(x: 19, y: 19)), ("blueQuarter",CGPoint(x: -19, y: -19)), ("pinkQuarter",CGPoint(x: 19, y: -19))], [("redSquare", CGPoint(x: 0, y: 0))], [], [("whiteSquare", CGPoint(x: 0, y: 0))]],
            [[("orangeSquare", CGPoint(x: 0, y: 0))], [], [("purpleHorizontalHalf", CGPoint(x: 0, y: 19)),("redHorizontalHalf", CGPoint(x: 0, y: -19))], [("redQuarter",CGPoint(x: -19, y: 19)), ("blueQuarter",CGPoint(x: 19, y: 19)), ("greenQuarter",CGPoint(x: -19, y: -19)), ("whiteQuarter",CGPoint(x: 19, y: -19))]],
            [[], [], [], [("greenSquare", CGPoint(x: 0, y: 0))]],
            [[], [], [], [("pinkSquare", CGPoint(x: 0, y: 0))]]
        ] as [[[(String, CGPoint)]]],
         "gameBoardCells": [
            [true, true, true, true],
            [true, true, true, true],
            [false, false, true, true],
            [false, false, true, true]
        ] as [[Bool]],
         "goal": [
            "red": 7,
            "green": 4,
            "white": 3
        ] as [String: Int]],
        ["number": 10,
         "elements": [
            [[("orangeQuarter",CGPoint(x: -19, y: 19)), ("greenQuarter",CGPoint(x: 19, y: 19)), ("yellowQuarter",CGPoint(x: -19, y: -19)), ("pinkQuarter",CGPoint(x: 19, y: -19))], [], [("redQuarter",CGPoint(x: -19, y: 19)), ("yellowQuarter",CGPoint(x: 19, y: 19)), ("orangeQuarter",CGPoint(x: -19, y: -19)), ("greenQuarter",CGPoint(x: 19, y: -19))], []],
            [[], [("whiteVerticalHalf", CGPoint(x: -19, y: 0)), ("purpleVerticalHalf", CGPoint(x: 19, y: 0))], [], [("orangeSquare", CGPoint(x: 0, y: 0))]],
            [[], [], [("whiteQuarter",CGPoint(x: -19, y: 19)), ("purpleQuarter",CGPoint(x: 19, y: 19)), ("greenQuarter",CGPoint(x: -19, y: -19)), ("redQuarter",CGPoint(x: 19, y: -19))], []],
            [[], [], [], [("purpleQuarter",CGPoint(x: -19, y: 19)), ("whiteQuarter",CGPoint(x: 19, y: 19)), ("redQuarter",CGPoint(x: -19, y: -19)), ("greenQuarter",CGPoint(x: 19, y: -19))]]
        ] as [[[(String, CGPoint)]]],
         "gameBoardCells": [
            [true, true, true, true],
            [true, true, true, true],
            [false, false, true, true],
            [false, false, true, true]
        ] as [[Bool]],
         "goal": [
            "orange": 6,
            "purple": 5,
            "red": 4
        ] as [String: Int]],
        ["number": 11,
         "elements": [
            [[], [], [("purpleHorizontalHalf", CGPoint(x: 0, y: 19)), ("blueQuarter",CGPoint(x: -19, y: -19)), ("yellowQuarter",CGPoint(x: 19, y: -19))], []],
            [[("pinkVerticalHalf", CGPoint(x: -19, y: 0)), ("greenVerticalHalf", CGPoint(x: 19, y: 0))], [("purpleQuarter",CGPoint(x: -19, y: 19)), ("greenQuarter",CGPoint(x: 19, y: 19)), ("yellowQuarter",CGPoint(x: -19, y: -19)), ("orangeQuarter",CGPoint(x: 19, y: -19))], [], [("whiteSquare", CGPoint(x: 0, y: 0))]],
            [[], [], [("pinkSquare", CGPoint(x: 0, y: 0))], [("orangeSquare", CGPoint(x: 0, y: 0))]],
            [[], [("yellowQuarter",CGPoint(x: -19, y: 19)), ("orangeQuarter",CGPoint(x: 19, y: 19)), ("greenQuarter",CGPoint(x: -19, y: -19)), ("blueQuarter",CGPoint(x: 19, y: -19))], [("redQuarter",CGPoint(x: -19, y: 19)), ("whiteQuarter",CGPoint(x: 19, y: 19)), ("pinkQuarter",CGPoint(x: -19, y: -19)), ("orangeQuarter",CGPoint(x: 19, y: -19))], []]
        ] as [[[(String, CGPoint)]]],
         "gameBoardCells": [
            [false, true, true, false],
            [true, true, true, true],
            [true, true, true, true],
            [false, true, true, false]
        ] as [[Bool]],
         "goal": [
            "pink": 6,
            "green": 6,
            "red": 6
        ] as [String: Int]],
        ["number": 12,
         "elements": [
            [[("purpleHorizontalHalf", CGPoint(x: 0, y: 19)), ("blueQuarter",CGPoint(x: -19, y: -19)), ("yellowQuarter",CGPoint(x: 19, y: -19))], [], [("purpleQuarter",CGPoint(x: -19, y: 19)), ("yellowQuarter",CGPoint(x: 19, y: 19)), ("pinkQuarter",CGPoint(x: -19, y: -19)), ("orangeQuarter",CGPoint(x: 19, y: -19))], [("yellowHorizontalHalf", CGPoint(x: 0, y: -19)), ("purpleQuarter",CGPoint(x: -19, y: 19)), ("pinkQuarter",CGPoint(x: 19, y: 19))]],
            [[], [("whiteHorizontalHalf", CGPoint(x: 0, y: 19)), ("pinkHorizontalHalf", CGPoint(x: 0, y: -19))], [], []],
            [[], [], [("pinkQuarter",CGPoint(x: -19, y: 19)), ("blueQuarter",CGPoint(x: 19, y: 19)), ("redQuarter",CGPoint(x: -19, y: -19)), ("whiteQuarter",CGPoint(x: 19, y: -19))], []],
            [[("purpleHorizontalHalf", CGPoint(x: 0, y: 19)), ("redHorizontalHalf", CGPoint(x: 0, y: -19))], [], [], []]
        ] as [[[(String, CGPoint)]]],
         "gameBoardCells": [
            [true, true, true, true],
            [true, true, false, true],
            [true, false, true, true],
            [true, true, true, true]
        ] as [[Bool]],
         "goal": [
            "white": 5,
            "blue": 3,
            "orange": 3
        ] as [String: Int]],
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
    func goToNextLevel(level: Int) {
        if level > maxUnlockedLevel {
            maxUnlockedLevel = level
        }
    }
}
