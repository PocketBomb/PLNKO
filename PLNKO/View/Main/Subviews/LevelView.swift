
import SwiftUI

struct Level {
    let num: Int
    let isAvailable: Bool
}

struct LevelView: View {
    let num: Int
    let isAvailable: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            Image(isAvailable ? Resources.Main.Level.activeImage
                              : Resources.Main.Level.blockedImage)
            .resizable()
            .scaledToFit()
            .frame(width: 62, height: 54.5)
            
            Text("\(num)")
                .font(.custom(Resources.Fonts.jomhuria, size: 49))
        }
        .frame(width: 62, height: 54.5)
    }
}
