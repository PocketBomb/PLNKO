
import Foundation

final class LightningManager: ObservableObject {
    static let shared = LightningManager()

    private let lightningKey = "lightningKey"
    
    private init() {
        if UserDefaults.standard.object(forKey: lightningKey) == nil {
            self.storedLightnings = 0
        } else {
            self.storedLightnings = UserDefaults.standard.object(forKey: lightningKey) as! Int
        }
        
    }
    
    
    @Published private var storedLightnings: Int {
        didSet {
            // Сохраняем в UserDefaults после изменения
            UserDefaults.standard.set(storedLightnings, forKey: lightningKey)
        }
    }
    
    // getter for public use
    public var currentLightnings: Int {
        return storedLightnings
    }
    
    func addLightnings(_ amount: Int) {
        storedLightnings += amount // add to total
    }
    
    
    func subtractLightnings(_ amount: Int) -> Bool {
        if storedLightnings >= amount {
            storedLightnings -= amount
            return true
        } else {
            return false // not enought money
        }
    }
}


