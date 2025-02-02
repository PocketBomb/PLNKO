import SwiftUI

struct WelcomeView: View {
    
    @State private var currentScreen: Int = 1
    
    var onMain: () -> Void
    
    var welcomeImages = [
        Resources.Welcome.Images.infoImage1,
        Resources.Welcome.Images.infoImage2,
        Resources.Welcome.Images.infoImage3
    ]
    
    var welcomeTexts = [
        Resources.Welcome.Text.text1,
        Resources.Welcome.Text.text2,
        Resources.Welcome.Text.text3
    ]
    
    var body: some View {
        ZStack {
            Image(Resources.Welcome.Views.infoBackgroundImage)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack(alignment: .top) {
                    Image(Resources.Welcome.Views.infoTopView)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width)
                        .padding(.bottom, 0)

                    HStack {
                        if currentScreen != 1 {
                            Button(action: {
                                currentScreen -= 1
                            }) {
                                Image(Resources.Welcome.Buttons.infoLeftButton)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 43, height: 41)
                            }
                        }
                        Spacer()
                        if currentScreen != welcomeImages.count {
                            Button(action: {
                                currentScreen += 1
                            }) {
                                Image(Resources.Welcome.Buttons.infoRightButton)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 43, height: 41)
                            }
                        }
                    }
                    
                    .padding(.horizontal, 16) // горизонтальные отступы
                    .frame(height: SizeConverter.isSmallScreen ? 107 : 113, alignment: .bottom)
                }
                .zIndex(10) //for image don't
                .padding(.top,SizeConverter.isSmallScreen ? 30 : 0)
                Image(welcomeImages[currentScreen-1])
                    .resizable()
                    .scaledToFit()
                    .frame(width: SizeConverter.isSmallScreen ? 280 : 352)
                    .padding(.top, -60)
                    .zIndex(8)
            
                
                HStack(spacing: 14) {
                    ForEach(1..<4) { index in
                        Image(index == currentScreen ? "circleRed" : "circleWhite")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 33, height: 33)
                    }
                }
                
                Text(welcomeTexts[currentScreen-1])
                    .font(.custom(Resources.Fonts.jomhuria, size: 34))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(-4)
                
                if currentScreen == welcomeImages.count {
                    Button(action: {
                        onMain()
                    }) {
                        Image(Resources.Welcome.Buttons.playButton)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 78)
                    }
                }
                
                Spacer()
                
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

