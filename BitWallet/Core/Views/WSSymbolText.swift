import SwiftUI

struct WSSymbolText: View {
    let symbol: String
    
    var body: some View {
        Text(symbol)
            .font(.title2)
            .fontWeight(.bold)
            .frame(width: 40)
            .foregroundColor(.orange)
    }
}
