
import Foundation

struct Achievement: Codable {
    let title: String
    var isClaimed: Bool
    var goal: Int?
    var count: Int?
}

class AchievementsManager: ObservableObject {
    static let shared = AchievementsManager()
    
    private let userDefaults = UserDefaults.standard
    private let achievementsKey = "achievementsKey31e1123t3r3dhfg24f3"
    
    public var achievements: [Achievement] = []
    
    private init() {
        loadAchievements()
    }
    
    private func loadAchievements() {
        if let data = userDefaults.data(forKey: achievementsKey),
           let savedAchievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = savedAchievements
        } else {
            achievements = [
                Achievement(title: "Complete the first level", isClaimed: false),
                Achievement(title: "Complete 7 levels", isClaimed: false),
                Achievement(title: "Finish all levels in the game", isClaimed: false),
                Achievement(title: "Replay any level twice", isClaimed: false, goal: 2, count: 0),
                Achievement(title: "Replay 5 levels", isClaimed: false, goal: 5, count: 0),
                Achievement(title: "Replay one of the starting levels after finishing the game", isClaimed: false, goal: 1, count: 0),
                Achievement(title: "Complete a level in under 30 seconds.", isClaimed: false),
                Achievement(title: "Pop 3 bubbles at once with a single move.", isClaimed: false),
                Achievement(title: "Spend more than 10 hours in the game.", isClaimed: false),
                Achievement(title: "Blow your first gum bubble.", isClaimed: false)
            ]
            saveAchievements()
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            userDefaults.set(data, forKey: achievementsKey)
        }
    }
    
    func getAchievementsProgress() -> [Achievement] {
        return achievements
    }
    
    func claiming(index: Int) -> Bool {
        print(index)
        guard index >= 0, index < achievements.count else { return false }
        
        var achievement = achievements[index]
        
        // Если ачивка не выполнена и имеет goal
        if !achievement.isClaimed, let goal = achievement.goal {
            // Увеличиваем счетчик
            achievement.count = (achievement.count ?? 0) + 1
            // Если достижение выполнено, помечаем как выполненное
            if goal == achievement.count {
                achievement.isClaimed = true
            }
            
            // Сохраняем изменения
            achievements[index] = achievement
            saveAchievements()
            
            return achievement.isClaimed
        } else if achievement.isClaimed == false {
            achievements[index].isClaimed = true
            saveAchievements()
            return true
        }
        
        // Если ачивка уже выполнена, ничего не делаем
        return false
    }

}
