
import SwiftUI

@main
struct PLNKOApp: App {
    
    @AppStorage("isFirst") private var isFirst: Bool = true
//    @State private var isFirst: Bool = true
    
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
            }
        }
    }
}
