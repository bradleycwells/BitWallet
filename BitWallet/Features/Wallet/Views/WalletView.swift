import SwiftUI

struct WalletView: View {
    @StateObject private var viewModel: WalletViewModel
    
    init(viewModel: WalletViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
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
                        
                        TextField("Amount", value: $viewModel.bitcoinAmount, format: .number)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 34, weight: .bold))
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
        }
    }
}

#Preview {
    let container = AppContainer()
    WalletView(viewModel: container.makeWalletViewModel())
}

