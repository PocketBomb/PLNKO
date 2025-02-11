
import SwiftUI

struct PauseView: View {
    
    var onCancel: () -> Void
    var onHome: () -> Void
    var onInfo: () -> Void
    
    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.7)
            BlurEffect(blurStyle: .dark)
                .edgesIgnoringSafeArea(.all)
            ZStack(alignment: .bottom) {
                
                Image("pauseBack")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 238, height: 194)
                VStack(alignment: .center, spacing: 10) {
                    HStack(alignment: .bottom, spacing: 50) {
                        Button {
                            onInfo()
                        } label: {
                            Image("infoPauseButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 62, height: 56)
                        }
                        Button {
                            onHome()
                        } label: {
                            Image("homePauseButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 62, height: 56)
                        }
                    }
                    Button {
                        onCancel()
                    } label: {
                        Image("pauseCancelButton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 68)
                    }
                }
                .padding(.bottom, -10)

            }
            .padding(.bottom, SizeConverter.isMediumScreen ? 130: 0)
        }
    }
}
