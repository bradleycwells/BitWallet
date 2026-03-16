import SwiftUI

struct CurrencySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WalletViewModel
    @State private var searchText = ""
    @State private var localSelection: Set<CurrencyCode> = []
    @State private var isShowingAlert = false
    
    init(viewModel: WalletViewModel) {
        self.viewModel = viewModel
        self._localSelection = State(initialValue: Set(viewModel.selectedCurrencyCodes))
    }
    
    var filteredCurrencies: [CurrencyCode] {
        let allCurrencies = CurrencyCode.allCases.filter { $0 != .BTC }
        let filtered: [CurrencyCode]
        if searchText.isEmpty {
            filtered = allCurrencies
        } else {
            filtered = allCurrencies.filter {
                ($0.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                $0.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        let priorityOrder = AppConstants.priorityCurrencies
        return filtered.sorted { code1, code2 in
            let index1 = priorityOrder.firstIndex(of: code1.rawValue) ?? Int.max
            let index2 = priorityOrder.firstIndex(of: code2.rawValue) ?? Int.max
            
            if index1 != index2 {
                return index1 < index2
            }
            return code1.rawValue < code2.rawValue
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                if #available(iOS 15.0, *) {
                    // No header needed; searchable will be applied below
                } else {
                    Section(header: Text("Search")) {
                        TextField("Search currencies", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }

                ForEach(filteredCurrencies) { code in
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
            .modifier(SearchableIfAvailable(searchText: $searchText))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.updateSelectedCurrencies(Array(localSelection))
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.orange)
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
        .ifAvailableTint(color: .orange)
    }
    
    private func toggleCurrency(_ code: CurrencyCode) {
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
                    if let name = code.name {
                        Text(name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                

                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .orange : Color(.systemGray4))
                    .font(.title3)
                    .padding(.leading, 8)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
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
