
import SwiftUI

struct AchievementsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var achievementsManager = AchievementsManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Фоновое изображение
                Image(Resources.Achievements.View.achievementsBackground)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Верхняя часть с кнопкой назад и заголовком
                    ZStack(alignment: .top) {
                        Image(Resources.Welcome.Views.infoTopView)
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: UIScreen.main.bounds.width)
                            .padding(.bottom, 0)
                        
                        // Кнопка назад
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(Resources.GumGallery.Buttons.backButton)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 49, height: 41)
                        }
                        .position(x: 16 + 49/2, y: SizeConverter.isSmallScreen ? 85 : 95)
                        
                        // Заголовок галереи
                        Image(Resources.Achievements.View.achievmentsLabel)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 184, alignment: .bottom)
                            .position(x: UIScreen.main.bounds.width / 2, y: SizeConverter.isSmallScreen ? 95 : 105)
                    }
                    .zIndex(10)
                    .frame(maxHeight: 140)
                    // Список ачивок
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(Array(achievementsManager.achievements.enumerated()), id: \.offset) { index, achievement in
                                Image(achievement.isClaimed ? "achievementImage\(index)" : "achievementImage\(index)NotCompleted")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 365.5, height: 114)
                            }
                            Spacer(minLength: 140)
                        }
                        .padding(.top, 20)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
    }
}
