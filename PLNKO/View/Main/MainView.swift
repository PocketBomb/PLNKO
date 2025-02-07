
import SwiftUI

struct MainView: View {
    
    let levels: [(x: CGFloat, y: CGFloat)] = [
        (0.2, 0.97), (0.35, 0.95), (0.62, 0.93),
        (0.85, 0.80), (0.8, 0.7), (0.6, 0.65),
        (0.42, 0.65), (0.2, 0.65), (0.09, 0.57),
        (0.16, 0.45), (0.34, 0.42), (0.38, 0.35)
    ]
    
    @State var isGame = false
    var selectedLevel = 1
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Image(Resources.Main.Views.mainBackgroundImage)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        ZStack(alignment: .top) {
                            // Первое изображение
                            Image(Resources.Welcome.Views.infoTopView)
                                .resizable()
                                .scaledToFit()
                                .frame(minWidth: UIScreen.main.bounds.width)
                                .padding(.bottom, 0) // Убедитесь, что это изображение по нижнему краю
                            
                            VStack(spacing: -50) {
                                HStack {
                                    //move --> InfoView()
                                    NavigationLink(destination: InfoView()) {
                                        Image(Resources.Main.Buttons.infoButton)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 49, height: 58)
                                    }
                                    Spacer()
                                    //move --> RecordsView()
                                    
                                    NavigationLink(destination: AchievementsView()) {
                                        Image(Resources.Main.Buttons.recordButton)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 49, height: 41)
                                    }
                                    
                                }
                                .padding(.horizontal, 16) // горизонтальные отступы
                                .frame(height: SizeConverter.isSmallScreen ? 107 : 125, alignment: .bottom)
                                
                                Image(Resources.Main.Views.menuLabel)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 140, alignment: .bottom)
                            }
                            
                        }
                        .zIndex(10)
                        Spacer()
                    }
                    .zIndex(10)
                    NavigationLink(destination: GumGalleryView()) {
                        Image("galleryButton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 100)
                    }
                    .position(x: 55,
                              y: geometry.size.height * (1.6/8) + (SizeConverter.isSmallScreen ? 35 : 20))
                
                    
                    SpeedView()
                        .position(x: geometry.size.width - 55,
                                  y: geometry.size.height * (1.4/8) + (SizeConverter.isSmallScreen ? 35 : 20))
                    
                    
                    
                    // Размещение кнопок уровней
                    ForEach(0..<levels.count, id: \ .self) { index in
                        Button(action: {
                            LevelManager.shared.maxUnlockedLevel-1 < index {
                                selectedLevel = index+1
                                isGame = true
                            }
                        }) {
                            ZStack(alignment: .center) {
                                Image(LevelManager.shared.maxUnlockedLevel-1 < index ? "levelBlocked" :"levelAvailable")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 62, height: 53.5, alignment: .center)
                                Text("\(index + 1)")
                                    .font(.custom(Resources.Fonts.jomhuria, size: 49))
                                    .foregroundStyle(.white)
                                    .padding(.bottom, 8)
                            }
                            .frame(width: 62, height: 53.5, alignment: .center)
                        }
                        .position(x: geometry.size.width * levels[index].x ,
                                  y: geometry.size.height * levels[index].y - (SizeConverter.isSmallScreen ? 0 : 100))
                    }
                }
                .edgesIgnoringSafeArea(.all)
                if isGame {
                    GameView(currentLevel: selectedLevel)
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    MainView()
}
