import SwiftUI

@main
struct PLNKOApp: App {
    
    @AppStorage("isFirst") private var isFirst: Bool = true
    @AppStorage("totalPlayTime") private var totalPlayTime: Int = 0
    
    @State private var startTime: Date?
    
    
    var body: some Scene {
        WindowGroup {
            if isFirst {
                WelcomeView(onMain: {
                    isFirst = false
                })
                .edgesIgnoringSafeArea(.all)
            } else {
                MainView()
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        startTrackingTime()
                    }
                    .onDisappear {
                        stopTrackingTime()
                    }
            }
        }
    }
    
    private func startTrackingTime() {
        startTime = Date()
    }

    private func stopTrackingTime() {
        guard let startTime = startTime else { return }
        let elapsedTime = Int(Date().timeIntervalSince(startTime))
        totalPlayTime += elapsedTime 

        if totalPlayTime >= 36000 {
            let _ = AchievementsManager.shared.claiming(index: 8)
        }
    }
}

