import SwiftUI

struct GumGalleryView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentIndex: Int = 0
    private let characterCount = 12
    private let spacing: CGFloat = 50
    private let imageSize = CGSize(width: 343, height: 394)
    private let cellSize = CGSize(width: 103, height: 103)
    private let horizontalSpacing: CGFloat = 9
    private let verticalSpacing: CGFloat = 12
    
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
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(Resources.GumGallery.Buttons.backButton)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 49, height: 41)
                        }
                        .position(x: 16 + 49/2, y: SizeConverter.isSmallScreen ? 85 : 95)
                        
                        // Заголовок галереи
                        Image(Resources.GumGallery.Views.gumGalleryLabel)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, alignment: .bottom)
                            .position(x: UIScreen.main.bounds.width / 2, y: SizeConverter.isSmallScreen ? 95 : 105)
                    }
                    .zIndex(10)
                    .frame(maxHeight: 140)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        // Галерея персонажей
                        ZStack(alignment: .center) {
                            ScrollViewReader { proxy in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: spacing) {
                                        ForEach(0..<characterCount, id: \.self) { index in
                                            let isOpen = index < LevelManager.shared.maxUnlockedLevel
                                            let imageName = isOpen ? "characterLevel\(index + 1)" : "characterLevel\(index + 1)Closed"
                                            Image(imageName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 343)
                                                .id(index)
                                        }
                                    }
                                    .padding(.horizontal, (geometry.size.width - imageSize.width) / 2)
                                }
                                .onAppear {
                                    proxy.scrollTo(currentIndex, anchor: .center)
                                }
                                .scrollDisabled(true) // Блокируем скролл пальцем
                                .onChange(of: currentIndex) { newIndex in
                                    withAnimation {
                                        proxy.scrollTo(newIndex, anchor: .center)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Кнопки прокрутки
                            HStack {
                                if currentIndex != 0 {
                                    Button(action: {
                                        if currentIndex > 0 {
                                            currentIndex -= 1
                                        }
                                    }) {
                                        Image(Resources.GumGallery.Buttons.galleryLeftButton)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 43, height: 41)
                                    }
                                }
                                
                                Spacer()
                                if currentIndex != 11 {
                                    Button(action: {
                                        if currentIndex < characterCount - 1 {
                                            currentIndex += 1
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
                            .frame(height: SizeConverter.isSmallScreen ? 107 : 113, alignment: .bottom)
                            
                            // Коллекция ячеек персонажей
            
                        }
                        .zIndex(1)
                        .padding(.top, -80)
                        
                        if currentIndex >= LevelManager.shared.maxUnlockedLevel {
                            Text("Complete Level \(currentIndex + 1)\nto give the character gum.")
                                .font(.custom(Resources.Fonts.jomhuria, size: 27))
                                .foregroundStyle(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .lineSpacing(1)
                                .padding(.top, -50)
                                .frame(height: 70)
                        }
                        
                        
                        VStack(spacing: verticalSpacing) {
                            ForEach(0..<4) { row in // 4 строки
                                HStack(spacing: horizontalSpacing) {
                                    ForEach(0..<3) { column in // 3 ячейки в строке
                                        let index = row * 3 + column
                                        let isOpen = index <= LevelManager.shared.maxUnlockedLevel
                                        let imageName = isOpen ? "characterCellLevel\(index + 1)" : "characterCellLevel\(index + 1)Closed"
                                        
                                        Button(action: {
                                            // При нажатии на ячейку обновляем текущий индекс
                                            currentIndex = index
                                        }) {
                                            Image(imageName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: cellSize.width, height: cellSize.height)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, currentIndex >= LevelManager.shared.maxUnlockedLevel ? -28 : 50 ) // Отступ сверху для коллекции
                        .padding(.horizontal, (geometry.size.width - (cellSize.width * 3 + horizontalSpacing * 2)) / 2)
                        Spacer(minLength: 150)
                    }
                    .zIndex(10)
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
        .onAppear()
    }
}
