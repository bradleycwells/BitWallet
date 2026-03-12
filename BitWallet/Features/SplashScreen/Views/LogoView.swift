import SwiftUI

struct LogoView: View {
    @Binding var animate: Bool

    var body: some View {
        HStack {
            Text("🚀")
                .font(.system(size: 30))
                .scaleEffect(animate ? 1.2 : 1.0)
                .opacity(animate ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 3.0), value: animate)
            Text("BitWallet")
                .font(.largeTitle)
                .bold()
                .opacity(animate ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 3.0), value: animate)
        }
    }
}

#Preview {
    StatefulPreviewWrapper(false) { animate in
        LogoView(animate: animate)
            .padding()
    }
}

// Helper to provide a binding in previews
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initialValue: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(wrappedValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
