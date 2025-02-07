
import SwiftUI

import SwiftUI

struct GoalsView: View {
    let goals: [String: Int]
    let matchCount: [String: Int]

    var body: some View {
        ZStack(alignment: .bottom) {
            Image("goalsBack")
                .resizable()
                .scaledToFit()
                .frame(width: 134, height: 81)
            HStack(alignment: .bottom, spacing: 9) {
                ForEach(goals.sorted(by: { $0.key < $1.key }), id: \.key) { goal in // Сортировка по ключу
                    ZStack(alignment: .center) {
                        Image("\(goal.key)GoalSquare") // Используем value для имени изображения
                            .resizable()
                            .scaledToFit()
                            .frame(width: 29, height: 29)
                        Text("\(getValue(for: goal.key))")
                            .font(.custom(Resources.Fonts.jomhuria, size: 33))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.bottom, 7)
        }
        .frame(width: 134, height: 81)
    }
    
    func getValue(for color: String) -> Int {
        var total = goals[color] ?? 0
        var matched = matchCount[color] ?? 0
        if total - matched <= 0 {
            return 0
        } else {
            return total - matched
        }
    }
}
