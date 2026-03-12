import SwiftUI

struct SplashScreenView: View {
    @State private var animate = false
    @Binding var showSplash: Bool
    
    var body: some View {
        LogoView(animate: $animate)
            .onAppear {
                animate = true
                // Simulate loading data
                DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                    showSplash = false
                }
            }
    }
}

#Preview {
    SplashScreenView(showSplash: .constant(true))
}                        
