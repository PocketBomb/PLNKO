//
//import SwiftUI
//import SpriteKit
//
//class GameViewModel: ObservableObject {
//    @Published var currentLevelData: (elements: [[[(String, CGPoint)]]], gameBoardCells: [[Bool]], goal: [String: Int])?
//    
//    // Получение данных текущего уровня
//    func loadCurrentLevel() {
//        if let levelData = LevelManager.shared.getLevelData(levelNumber: LevelManager.shared.currentLevel) {
//            self.currentLevelData = levelData
//        } else {
//            print("Ошибка загрузки уровня!")
//        }
//    }
//    
//    // Проверка выполнения цели
//    func checkGoalCompletion(matchCount: [String: Int]) -> Bool {
//        guard let goal = currentLevelData?.goal else { return false }
//        
//        for (color, targetValue) in goal {
//            if let count = matchCount[color], count < targetValue {
//                return false // Если хотя бы одна цель не достигнута
//            }
//        }
//        
//        return true // Все цели достигнуты
//    }
//    
//    // Переход к следующему уровню
//    func completeLevel() {
//        LevelManager.shared.goToNextLevel()
//        loadCurrentLevel()
//    }
//}
