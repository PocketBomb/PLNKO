
import Foundation

final class BestResultManager: ObservableObject {
    static let shared = BestResultManager()
    private let userDefaults = UserDefaults.standard
    private let resultsKey = "BestResults"
    
    private init() {}
    
    private var bestResults: [String: String] {
        get {
            return userDefaults.dictionary(forKey: resultsKey) as? [String: String] ?? [:]
        }
        set {
            userDefaults.setValue(newValue, forKey: resultsKey)
        }
    }
    
    func getBestResult(for level: Int) -> String {
        return bestResults["Level_\(level)"] ?? "None"
    }
    
    // Сохраняем результат, если он лучше предыдущего
    func updateBestResult(for level: Int, with time: String) {
        let key = "Level_\(level)"
        
        if let previousTime = bestResults[key], previousTime != "None",
           let previousSeconds = Double(previousTime), let newSeconds = Double(time),
           newSeconds >= previousSeconds {
            return // Новый результат не лучше старого, не обновляем
        }
        
        bestResults[key] = time
    }
}

