

import SwiftUI

struct FirstLounchInfoView: View {
    
//    @Environment(\.presentationMode) var presentationMode
    var onBack: () -> Void
    var onPlay: () -> Void
    
    var infoImages = [
        Resources.Info.Images.info1,
        Resources.Info.Images.info2,
        Resources.Info.Images.info3
    ]
    
    var infoTexts = [
        Resources.Info.Text.text1,
        Resources.Info.Text.text2,
        Resources.Info.Text.text3
    ]
    
    @State var currentScreen = 1
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Фоновое изображение
                Image(Resources.GumGallery.Views.galleryBackground)
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
                            onBack()
                        }) {
                            Image(Resources.GumGallery.Buttons.backButton)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 49, height: 41)
                        }
                        .position(x: 16 + 49/2, y: SizeConverter.isMediumScreen ? 75: (SizeConverter.isSmallScreen ? 85 : 95))
                        Button(action: {
                            onPlay()
                        }) {
                            Image("infoPlayButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 49, height: 41)
                        }
                        .position(x: UIScreen.main.bounds.width - (16 + 49/2), y: SizeConverter.isMediumScreen ? 75: (SizeConverter.isSmallScreen ? 85 : 95))
                        
                        // Заголовок галереи
                        Image(Resources.Info.View.infoLabel)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 133, alignment: .bottom)
                            .position(x: UIScreen.main.bounds.width / 2, y: SizeConverter.isSmallScreen ? 95 : 105)
                    }
                    .zIndex(10)
                    .frame(maxHeight: 140)
                    
                    ZStack(alignment: .bottom) {
                        Image(infoImages[currentScreen-1])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 343)
                            .padding(.top, -60)
                            .zIndex(8)
                        
                        
                        HStack {
                            if currentScreen != 1 {
                                Button(action: {
                                    if currentScreen > 1 {
                                        currentScreen = currentScreen - 1
                                    }
                                }) {
                                    Image(Resources.GumGallery.Buttons.galleryLeftButton)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 43, height: 41)
                                }
                            }
                            
                            Spacer()
                            if currentScreen != 3 {
                                Button(action: {
                                    if currentScreen < 3 {
                                        currentScreen += 1
                                    }
                                }) {
                                    Image(Resources.GumGallery.Buttons.galleryRightButton)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 43, height: 41)
                                }
                            }
                            
                        }
                        .padding(.horizontal, SizeConverter.isSmallScreen ? 40 : 50)
                        .padding(.bottom, 0)
                        .zIndex(9)
                    }
                    .frame(maxHeight: 395)
                    
                    Text(infoTexts[currentScreen-1])
                        .font(.custom(Resources.Fonts.jomhuria, size: 34))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-4)
                    Spacer()
                }
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .navigationBarHidden(true)
    }
}


