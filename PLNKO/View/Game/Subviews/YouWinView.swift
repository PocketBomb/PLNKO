import SwiftUI

struct YouWinView: View {
    
    var onRestart: () -> Void
    var onHome: () -> Void
    var onNextLevel: () -> Void
    
    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.7)
            BlurEffect(blurStyle: .dark)
                .edgesIgnoringSafeArea(.all)
            Image("fireEffect")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .position(x: UIScreen.main.bounds.width / 2, y: 606 / 2) 
            ZStack(alignment: .bottom) {
                Image("youWinBack")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 342, height: 473)
                VStack(spacing: 21) {
                    Button {
                        onNextLevel()
                    } label: {
                        Image("nextLevelButton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 242, height: 78)
                    }
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
                }
                .padding(.bottom, 45)
                
            }
            .frame(width: 342, height: 368)
            .padding(.bottom, 150)
        }
        .edgesIgnoringSafeArea(.all)
        
    }
}
