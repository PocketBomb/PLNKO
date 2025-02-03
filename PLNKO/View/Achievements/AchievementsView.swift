
import SwiftUI

struct AchievementsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
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
                    
                    Spacer()
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
    }
}
