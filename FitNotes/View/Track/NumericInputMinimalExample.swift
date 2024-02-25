import SwiftUI

struct NumericInputMinimalExample: View {
    
    @Binding var value: Double?
    @FocusState var focus
    
    var body: some View {
        
        TextField("-", value: $value, formatter: doubleFormatter)
            .focused($focus)
            .onTapGesture {
                if (!focus) {
                    print("Here")
                    value = Optional(nilLiteral: ())
                }
            }
            .padding(4)
            .background(.gray.opacity(0.3))
            .keyboardType(.decimalPad)
        
    }
}
