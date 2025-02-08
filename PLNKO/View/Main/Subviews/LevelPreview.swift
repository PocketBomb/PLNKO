
import SwiftUI
import UIKit

struct LevelPreview: View {
    
    @StateObject var bestResultManager = BestResultManager.shared
    
    let currentLevel: Int
    @State var goals: [String: Int] = [:]
    var onPlay: () -> Void
    var onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.7)
            BlurEffect(blurStyle: .dark)
                .edgesIgnoringSafeArea(.all)
            ZStack(alignment: .bottom) {
                ZStack(alignment: .topTrailing) {
                    ZStack(alignment: .top) {
                        Image("levelPreviewBack")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 265, height: 381.5)
                        ZStack {
                            Image("levelNumberBack")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 148.5, height: 48.65)
                            CustomTextShadow(text: "LEVEL \(currentLevel)", width: 2)
                                .font(.custom(Resources.Fonts.jomhuria, size: 40))
                                .foregroundStyle(Color(red: 0.184, green: 0.086, blue: 0.369))
                        }
                        .padding(.top, -15)
                    }
                    Button {
                        onExit()
                    } label: {
                        Image("cancelButton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    }
                    .padding(.trailing, 10)
                }
                .frame(width: 265, height: 381.5)
                ZStack(alignment: .bottom) {
                    Image("goalLevelPreviewBack")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 202, height: 119)
                    HStack(alignment: .bottom, spacing: 9) {
                        ForEach(goals.sorted(by: { $0.key < $1.key }), id: \.key) { goal in // Сортировка по ключу
                            ZStack(alignment: .center) {
                                Image("\(goal.key)GoalSquare") // Используем value для имени изображения
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 37, height: 37)
                                Text("\(goal.value)")
                                    .font(.custom(Resources.Fonts.jomhuria, size: 33))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.bottom, 220)
                VStack(alignment: .center, spacing: -15) {
                    CustomTextShadow2(text: "Best score:", width: 2, color: Color(red: 92/255, green: 8/255, blue: 146/255))
                        .font(.custom(Resources.Fonts.jomhuria, size: 52))
                        .foregroundStyle(Color(red: 251/255, green: 193/255, blue: 23/255))
                        .multilineTextAlignment(.center)
                    CustomTextShadow2(text: "\(bestResultManager.getBestResult(for: currentLevel))s", width: 2, color: Color(red: 92/255, green: 8/255, blue: 146/255))
                        .font(.custom(Resources.Fonts.jomhuria, size: 52))
                        .foregroundStyle(Color(red: 251/255, green: 193/255, blue: 23/255))
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 120)
                
                Button {
                    onPlay()
                } label: {
                    Image("playLevelPreviewButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 78)
                }
                .padding(.bottom, 40)
            }
            .padding(.bottom, 100)
            .onAppear {
                let levelData = LevelManager.shared.getLevelData(levelNumber: currentLevel)
                goals = levelData?.goal ?? [:]
            }
        }
    }
}
