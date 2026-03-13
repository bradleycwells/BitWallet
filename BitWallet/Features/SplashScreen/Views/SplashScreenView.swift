import SwiftUI

struct SplashScreenView: View {
    @State private var animate = false
    @Binding var showSplash: Bool
    @State var stopDisplay: Bool = false
    var body: some View {
        LogoView(animate: $animate, onComplete: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showSplash = false
            }
        })
            .onAppear {
                animate = true
            }
    }
}

#Preview {
    SplashScreenView(showSplash: .constant(true))
}                        
