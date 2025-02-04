import SwiftUI
import SpriteKit

struct GameView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var scene: GameScene = {
        let scene = GameScene(size: CGSize(width: 343, height: 558))
        scene.scaleMode = .aspectFill
        return scene
    }()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Фоновое изображение
                Image(Resources.Game.Views.gameBackground)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(0)
                
                VStack(spacing: 0) {
                    // Верхняя часть с кнопкой назад и заголовком
                    ZStack(alignment: .top) {
                        Image(Resources.Welcome.Views.infoTopView)
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: UIScreen.main.bounds.width)
                            .padding(.bottom, 0)
                        
                        VStack(spacing: -50) {
                            HStack {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Image(Resources.Game.Buttons.backButton)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 49, height: 41)
                                }
                                
                                Spacer()
                                
                                Button(action: {}) {
                                    Image(Resources.Game.Buttons.pauseButton)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 49, height: 41)
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: SizeConverter.isSmallScreen ? 107 : 115, alignment: .bottom)
                            
                            Image("level1Label")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 133, alignment: .bottom)
                        }
                    }
                    .zIndex(2)
                    .frame(maxHeight: 125)
                    
                    Spacer(minLength: 100)
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .frame(width: 343, height: 558)
                        .ignoresSafeArea()
                        .background(.clear)
                        .zIndex(3)
                        .id(scene)
                    
                    Spacer()
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
    }
}

