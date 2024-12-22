import SwiftUI

struct DetailRow: View {
    let label: String
    let value: String
    let trailing: AnyView?
    
    init(label: String, value: String) {
        self.label = label
        self.value = value
        self.trailing = nil
    }
    
    init<V: View>(label: String, value: String, @ViewBuilder trailing: () -> V) {
        self.label = label
        self.value = value
        self.trailing = AnyView(trailing())
    }
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            if let trailing = trailing {
                trailing
            } else {
                Text(value)
            }
        }
    }
} 