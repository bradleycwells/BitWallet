import SwiftUI

struct WalletView: View {
    @StateObject private var viewModel: WalletViewModel
    @State private var isShowingEditAlert = false
    @State private var isShowingWelcomeAlert = false
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
            WalletHeaderView(bitcoinAmount: viewModel.bitcoinAmount) {
                showEditView()
            }
            
            if viewModel.isLoading {
                WalletLoadingView()
            } else if let error = viewModel.errorMessage {
                WalletErrorView(errorMessage: error) {
                    Task {
                        await viewModel.fetchRates()
                    }
                }
            } else if viewModel.currencyValues.isEmpty && !viewModel.isLoading {
                WalletEmptyStateView {
                    isShowingWelcomeAlert = true
                }
            } else {
                WalletListView(currencyValues: viewModel.currencyValues)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                LogoView(animate: .constant(false))
            }
        }
        .task {
            if !viewModel.isOnboardingCompleted {
                isShowingWelcomeAlert = true
            } else {
                await viewModel.fetchRates()
            }
        }
        .refreshable {
            await viewModel.fetchRates(forceRefresh: true)
        }
        .alert("Welcome to BitWallet!", isPresented: $isShowingWelcomeAlert) {
            TextField(CurrencySymbols.symbol(for: .BTC)!, text: $tempBitcoinAmount)
                    .font(.system(size: 34, weight: .bold))
                    .keyboardType(.decimalPad)
            Button("Get Started") {
                viewModel.setOnboardingCompleted()
                if let value = Double(tempBitcoinAmount), value > 0 {
                    viewModel.bitcoinAmount = value
                    Task {
                        await viewModel.fetchRates()
                    }
                }
            }
            Button("Maybe Later", role: .cancel) {
                viewModel.setOnboardingCompleted()
            }
        } message: {
            Text("Please enter the amount of Bitcoin you currently hold to start tracking its value in other currencies.")
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

