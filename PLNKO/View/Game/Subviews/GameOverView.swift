import SwiftUI

struct GameOverView: View {
    
    var onRestart: () -> Void
    
    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.7)
            ZStack(alignment: .bottom) {
                Image("gameOverBack")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 342, height: 368)
                HStack(alignment: .center) {
                    Button {
                        print()
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
//                    .frame(width: 180, height: 60)
                    .padding(.bottom, 25)
                }
            }
            .frame(width: 342, height: 368)
        }
        
    }
}
