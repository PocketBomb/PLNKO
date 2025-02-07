import SwiftUI

struct GameOverView: View {
    
    var onRestart: () -> Void
    var onHome: () -> Void
    
    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.7)
            BlurEffect(blurStyle: .dark)
                .edgesIgnoringSafeArea(.all)
            ZStack(alignment: .bottom) {
                Image("gameOverBack")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 342, height: 368)
                HStack(alignment: .center, spacing: 55) {
                    Button {
                        onHome()
                    } label: {
                        Image("backToHomeButton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 62, height: 51.88)
                    }
                    Button {
                        onRestart()
                    } label: {
                        Image("restartLevelButton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 62, height: 51.88)
                    }
                }
                .padding(.bottom, 45)
            }
            .frame(width: 342, height: 368)
            .padding(.bottom, 150)
        }
        
    }
}
