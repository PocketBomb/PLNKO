
import SwiftUI
import Foundation

//MARK: - Resources is assets, colors, texts... from application
enum Resources {
    
    enum Fonts {
        static let jomhuria = "Jomhuria-Regular"
    }
    
    //MARK: - MainView
    enum Main {
        
        enum Buttons {
            static let infoButton = "infoButton"
            static let recordButton = "recordButton"
        }
        
        enum Level {
            static let activeImage = "levelBlocked"
            static let blockedImage = "levelBlocked"
        }
        
        enum Views {
            static let mainBackgroundImage = "mainBackgroundImage"
            static let menuLabel = "menuLabel"
        }
    }
    
    //MARK: - InfoView 
    enum Welcome {
        enum Buttons {
            static let infoLeftButton = "infoLeftButton"
            static let infoRightButton = "infoRightButton"
            static let playButton = "playButton"
        }
        
        enum Views {
            static let infoBackgroundImage = "infoBackgroundImage"
            static let infoTopView = "infoTopView"
            static let circleWhite = "circleWhite"
            static let circleRed = "circleRed"
        }
        
        enum Images {
            static let infoImage1 = "infoImage1"
            static let infoImage2 = "infoImage2"
            static let infoImage3 = "infoImage3"
        }
        
        enum Text {
            static let text1 = "Hi! I’m Luke, leader of the\nBubble Explorers.\nMy friends and I are hunting\nfor the rarest gum flavors!"
            static let text2 = "We blow bubbles, solve puzzles,\nand unlock hidden flavors!"
            static let text3 = "Join us! Grab your gum\nand let’s start the adventure!"
        }
    }
    
    
    enum GumGallery {
        enum Views {
            static let galleryBackground = "galleryBackground"
            static let gumGalleryLabel = "gumGalleryLabel"
        }
        
        enum Buttons {
            static let backButton = "backButton"
        }
    }
}
