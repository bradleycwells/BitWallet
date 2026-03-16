import SwiftUI

struct WalletView: View {
    @StateObject private var viewModel: WalletViewModel
    @State private var isShowingEditAlert = false
    @State private var tempBitcoinAmount: String = ""
    
    init(viewModel: WalletViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    content
                }
            } else {
                NavigationView {
                    content
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }

    private var content: some View {
        VStack(spacing: 20) {
            // Input Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Your Bitcoin")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("₿")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    
                    Text(viewModel.bitcoinAmount, format: .number)
                        .font(.system(size: 34, weight: .bold))
                    
                    Spacer()
                    
                    Button {
                        showEditView()
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // Conversions List
            if viewModel.isLoading {
                Spacer()
                ProgressView("Fetching rates...")
                Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        Task {
                            await viewModel.fetchRates()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                Spacer()
            } else {
                List(viewModel.currencyValues) { value in
                    CurrencyRowView(currency: value)
                }
                .listStyle(PlainListStyle())
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                LogoView(animate: .constant(false))
            }
        }
        .task {
            await viewModel.fetchRates()
        }
        .refreshable {
            await viewModel.fetchRates(forceRefresh: true)
        }
        .alert("Edit Amount", isPresented: $isShowingEditAlert) {
            TextField("Bitcoin Amount", text: $tempBitcoinAmount)
                .keyboardType(.decimalPad)
            Button("Add") {
                if let value = Double(tempBitcoinAmount) {
                    viewModel.bitcoinAmount = value
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter the amount of Bitcoin you want to track.")
        }
    }

    private func showEditView() {
        tempBitcoinAmount = String(format: "%.8f", viewModel.bitcoinAmount).replacingOccurrences(of: "0*$", with: "", options: .regularExpression).replacingOccurrences(of: "\\.$", with: "", options: .regularExpression)
        if tempBitcoinAmount == "0" && viewModel.bitcoinAmount == 0 {
            tempBitcoinAmount = ""
        }
        isShowingEditAlert = true
    }
}

#Preview {
    let container = AppContainer()
    WalletView(viewModel: container.makeWalletViewModel())
}

