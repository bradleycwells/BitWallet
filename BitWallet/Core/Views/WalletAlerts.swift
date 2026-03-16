import SwiftUI

extension View {
    func welcomeAlert(
        isPresented: Binding<Bool>,
        amount: Binding<String>,
        onGetStarted: @escaping (Double?) -> Void,
        onMaybeLater: @escaping () -> Void
    ) -> some View {
        self.alert("Welcome to BitWallet!", isPresented: isPresented) {
            TextField(CurrencySymbols.symbol(for: .BTC) ?? "BTC", text: amount)
                .font(.system(size: 34, weight: .bold))
                .keyboardType(.decimalPad)
            
            Button("Get Started") {
                let value = Double(amount.wrappedValue)
                onGetStarted(value)
            }
            
            Button("Maybe Later", role: .cancel) {
                onMaybeLater()
            }
        } message: {
            Text("Please enter the amount of Bitcoin you currently hold to start tracking its value in other currencies.")
        }
    }
    
    func editAmountAlert(
        isPresented: Binding<Bool>,
        amount: Binding<String>,
        onAdd: @escaping (Double) -> Void
    ) -> some View {
        self.alert("Edit Amount", isPresented: isPresented) {
            TextField("Bitcoin Amount", text: amount)
                .keyboardType(.decimalPad)
            
            Button("Add") {
                if let value = Double(amount.wrappedValue) {
                    onAdd(value)
                }
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter the amount of Bitcoin you want to track.")
        }
    }
}
