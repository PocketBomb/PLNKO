
import SwiftUI

struct SpeedView: View {
    var body: some View {
        ZStack(alignment: .center) {
            Image("speedBackground")
                .resizable()
                .scaledToFit()
                .frame(width: 110)
            
            Text("150")
                .font(.custom(Resources.Fonts.jomhuria, size: 37))
                .foregroundStyle(.white)
                .padding(.leading, 37)
                .padding(.top, 2)
        }
    }
}

