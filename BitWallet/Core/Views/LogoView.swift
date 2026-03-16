import SwiftUI

struct LogoView: View {
    @Binding var animate: Bool
    var onComplete: (() -> Void)? = nil
    @State private var displayedText: String = "Bit"
    private let words: [String] = AppConstants.priorityCurrencies + ["BTC", "Bit"]
    @State private var isAnimatingText = false
    private let charWait: UInt64 = 140_000_000 // 0.2 seconds
    private let wordWait: UInt64 = 500_000_000 // 0.5 seconds
    
    init(animate: Binding<Bool>, onComplete: (() -> Void)? = nil) {
        self._animate = animate
        self.onComplete = onComplete
    }

    var body: some View {
        HStack(spacing: 8) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .cornerRadius(8)
            
            HStack(spacing: 0) {
                Text(displayedText)
                    .foregroundColor(.brandPrimary)
                    .bold()
                Text("Wallet")
                    .foregroundColor(.brandText)
                    .bold()
            }
            .font(.system(.largeTitle, design: .rounded))
        }
        .onTapGesture {
            Task {
                await animateText()
            }
        }
        .task {
            if animate {
                await animateText()
            }
        }
        .onChange(of: animate) { newValue in
            if newValue {
                Task {
                    await animateText()
                }
            }
        }
    }

    func animateText() async {
        if isAnimatingText { return }
        isAnimatingText = true
        await MainActor.run { displayedText = "" }
        for (index, word) in words.enumerated() {
            var current = ""
            for ch in word {
                current.append(ch)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        displayedText = current
                    }
                }
                try? await Task.sleep(nanoseconds: charWait)
            }
            if index < words.count - 1 {
                try? await Task.sleep(nanoseconds: wordWait)
            }
        }
        isAnimatingText = false
        await MainActor.run {
            HapticManager.shared.triggerLogoAnimationComplete()
            onComplete?()
        }
    }
}
