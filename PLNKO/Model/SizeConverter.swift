
import SwiftUI
import Foundation

final class SizeConverter {
    
    static var isSmallScreen: Bool {
        get {
            return UIScreen.main.bounds.height < 700
        }
    }
}

