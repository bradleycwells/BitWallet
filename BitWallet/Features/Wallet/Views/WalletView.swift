import SwiftUI

struct WalletView: View {
    @StateObject private var viewModel: WalletViewModel
    @State private var isShowingEditAlert = false
    @State private var isShowingWelcomeAlert = false
    @State private var isShowingCurrencySelection = false
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
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
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
                    WalletListView(
                        currencyValues: viewModel.currencyValues,
                        lastFetchDate: viewModel.lastFetchDate
                    )
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                LogoView(animate: .constant(false))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingCurrencySelection = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.brandPrimary)
                }
                .accessibilityIdentifier("AddCurrencyButton")
            }
        }
        .sheet(isPresented: $isShowingCurrencySelection) {
            CurrencySelectionView(viewModel: viewModel)
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
        .welcomeAlert(
            isPresented: $isShowingWelcomeAlert,
            amount: $tempBitcoinAmount,
            onGetStarted: { value in
                viewModel.setOnboardingCompleted()
                if let value = value, value > 0 {
                    viewModel.bitcoinAmount = value
                    Task {
                        await viewModel.fetchRates()
                    }
                }
            },
            onMaybeLater: {
                viewModel.setOnboardingCompleted()
            }
        )
        .editAmountAlert(
            isPresented: $isShowingEditAlert,
            amount: $tempBitcoinAmount,
            onAdd: { value in
                viewModel.bitcoinAmount = value
            }
        )
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

