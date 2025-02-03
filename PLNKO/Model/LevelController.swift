
import Foundation

final class LevelController {
    static let shared = LevelController()
    
    
    private(set) var lastLevel: Int {
        didSet {
            UserDefaults.standard.set(lastLevel, forKey: "lastLevel")
        }
    }
    
    private init() {
        self.lastLevel = UserDefaults.standard.integer(forKey: "lastLevel")
        
        if lastLevel == 0 {
            self.lastLevel = 1
        }
    }
    
    
    public func getLevelData(by levelId: Int) {
        
    }
    
    public func updateLevel(currentLevel: Int) {
        self.lastLevel = currentLevel
    }
    
}
