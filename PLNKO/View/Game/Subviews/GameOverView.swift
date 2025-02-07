import SwiftUI

struct GameOverView: View {
    
    var onBack: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8) // Полупрозрачный фон
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Вы выиграли!")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Button("Начать заново") {
                    // Логика для начала новой игры
                    onBack()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}
