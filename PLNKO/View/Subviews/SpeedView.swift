
import SwiftUI

struct SpeedView: View {
    
    @StateObject private var lightningManager = LightningManager.shared
    
    var body: some View {
        ZStack(alignment: .center) {
            Image("speedBackground")
                .resizable()
                .scaledToFit()
                .frame(width: 110)
            
            Text("\(lightningManager.currentLightnings)")
                .font(.custom(Resources.Fonts.jomhuria, size: 37))
                .foregroundStyle(.white)
                .padding(.leading, 37)
                .padding(.top, 2)
        }
    }
}

