
import Foundation

struct Achievement: Codable {
    let title: String
    var isClaimed: Bool
}

class AchievementsManager {
    static let shared = AchievementsManager()
    
    private let userDefaults = UserDefaults.standard
    private let achievementsKey = "achievementsKey"
    
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
                Achievement(title: "Replay any level twice", isClaimed: false),
                Achievement(title: "Replay 5 levels", isClaimed: false),
                Achievement(title: "Replay one of the starting levels after finishing the game", isClaimed: false),
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
        guard index >= 0, index < achievements.count else { return false }
        if achievements[index].isClaimed {
            return false
        } else {
            achievements[index].isClaimed = true
            saveAchievements()
            return true
        }
    }
}
