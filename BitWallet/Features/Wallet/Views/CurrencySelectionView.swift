import SwiftUI

struct CurrencySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WalletViewModel
    @State private var localSelection: Set<CurrencyCode> = []
    @State private var isShowingAlert = false
    
    init(viewModel: WalletViewModel) {
        self.viewModel = viewModel
        self._localSelection = State(initialValue: Set(viewModel.selectedCurrencyCodes))
    }
    
    var body: some View {
        NavigationView {
            List {
                if #available(iOS 15.0, *) {
                    // No header needed; searchable will be applied below
                } else {
                    Section(header: Text("Search")) {
                            TextField("Search currencies", text: $viewModel.currencySearchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .accessibilityIdentifier("CurrencySearchField")
                    }
                }

                ForEach(viewModel.filteredCurrencies) { code in
                    CurrencySelectionRow(
                        code: code,
                        isSelected: localSelection.contains(code),
                        toggle: {
                            toggleCurrency(code)
                        }
                    )
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Select Currencies")
            .navigationBarTitleDisplayMode(.inline)
            .modifier(SearchableIfAvailable(searchText: $viewModel.currencySearchText))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        AnalyticsManager.shared.log(.currencySelectionCancelled)
                        dismiss()
                    }
                    .font(.headline)
                    .accessibilityIdentifier("CurrencySelectionCancelButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        AnalyticsManager.shared.log(.currencySelectionSaved(selectedCount: localSelection.count))
                        viewModel.updateSelectedCurrencies(Array(localSelection))
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.brandPrimary)
                    .accessibilityIdentifier("CurrencySelectionSaveButton")
                }
            }
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("One currency must be selected"),
                message: Text("You must have at least one currency selected in your wallet."),
                dismissButton: .default(Text("OK"))
            )
        }
        .ifAvailableTint(color: .brandPrimary)
        .onAppear {
            viewModel.currencySearchText = ""
        }
    }
    
    private func toggleCurrency(_ code: CurrencyCode) {
        AnalyticsManager.shared.log(.currencyToggled(currencyCode: code.rawValue, wasSelectedBefore: localSelection.contains(code)))
        
        if localSelection.contains(code) {
            if localSelection.count > 1 {
                localSelection.remove(code)
            } else {
                isShowingAlert = true
            }
        } else {
            localSelection.insert(code)
        }
    }
}

struct CurrencySelectionRow: View {
    let code: CurrencyCode
    let isSelected: Bool
    let toggle: () -> Void
    
    var body: some View {
        Button(action: toggle) {
            HStack {
                if let symbol = code.symbol {
                    WSSymbolText(symbol: symbol)
                }
                VStack(alignment: .leading) {
                    Text(code.rawValue)
                        .font(.headline)
                        .foregroundColor(.brandText)
                    if let name = code.name {
                        Text(name)
                            .font(.caption)
                            .foregroundColor(.brandText.opacity(0.6))
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .brandPrimary : Color.brandText.opacity(0.3))
                    .font(.title3)
                    .padding(.leading, 8)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityIdentifier("CurrencyRow_\(code.rawValue)")
    }
}

private struct SearchableIfAvailable: ViewModifier {
    @Binding var searchText: String

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.searchable(text: $searchText, prompt: "Search currencies")
        } else {
            content
        }
    }
}

extension View {
    @ViewBuilder
    func ifAvailableTint(color: Color) -> some View {
        if #available(iOS 15.0, *) {
            self.tint(color)
        } else {
            self.accentColor(color)
        }
    }
}

#Preview {
    let container = AppContainer()
    CurrencySelectionView(viewModel: container.makeWalletViewModel())
}
