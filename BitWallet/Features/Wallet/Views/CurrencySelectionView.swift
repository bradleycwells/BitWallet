import SwiftUI

struct CurrencySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WalletViewModel
    @State private var searchText = ""
    
    var filteredCurrencies: [CurrencyCode] {
        if searchText.isEmpty {
            return CurrencyCode.allCases.filter { $0 != .BTC }
        } else {
            return CurrencyCode.allCases.filter { $0 != .BTC && 
                (($0.name?.localizedCaseInsensitiveContains(searchText) ?? false) || 
                 $0.rawValue.localizedCaseInsensitiveContains(searchText))
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredCurrencies) { code in
                    CurrencySelectionRow(
                        code: code,
                        isSelected: viewModel.selectedCurrencyCodes.contains(code),
                        toggle: {
                            toggleCurrency(code)
                        }
                    )
                }
            }
            .navigationTitle("Select Currencies")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search currencies")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleCurrency(_ code: CurrencyCode) {
        var currentSelection = viewModel.selectedCurrencyCodes
        if let index = currentSelection.firstIndex(of: code) {
            currentSelection.remove(at: index)
        } else {
            currentSelection.append(code)
        }
        viewModel.updateSelectedCurrencies(currentSelection)
    }
}

struct CurrencySelectionRow: View {
    let code: CurrencyCode
    let isSelected: Bool
    let toggle: () -> Void
    
    var body: some View {
        Button(action: toggle) {
            HStack {
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
                
                if let symbol = code.symbol {
                    Text(symbol)
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .gray)
                    .font(.title3)
                    .padding(.leading, 8)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let container = AppContainer()
    CurrencySelectionView(viewModel: container.makeWalletViewModel())
}
