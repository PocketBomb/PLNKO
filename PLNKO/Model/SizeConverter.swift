
import SwiftUI
import Foundation

final class SizeConverter {
    
    static var isSmallScreen: Bool {
        get {
            return UIScreen.main.bounds.height < 700
        }
    }
    
    static var isMediumScreen: Bool {
        get {
//            return UIScreen.main.bounds.height < 820 && UIScreen.main.bounds.height > 700
            return UIScreen.main.bounds.height < 820 
        }
    }
}

