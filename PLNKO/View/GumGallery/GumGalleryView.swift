
import SwiftUI

struct GumGalleryView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(Resources.GumGallery.Views.galleryBackground)
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
                        
                        Button(action: {
                            
                        }) {
                            Image(Resources.GumGallery.Buttons.backButton)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 49, height: 41)
                        }
                        .position(x: 16 + 49/2,y: SizeConverter.isSmallScreen ? 85 : 100)
                        Image(Resources.GumGallery.Views.gumGalleryLabel)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, alignment: .bottom)
                            .position(x: UIScreen.main.bounds.width / 2 ,y: SizeConverter.isSmallScreen ? 95 : 105)
                    }
                    .zIndex(10)
                    Spacer()
                }
                .zIndex(10)
            }
        }
    }
}

