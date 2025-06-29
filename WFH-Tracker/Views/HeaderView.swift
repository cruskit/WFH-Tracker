import SwiftUI

struct HeaderView: View {
    let monthName: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(monthName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            
            Divider()
        }
    }
}

#Preview {
    HeaderView(monthName: "January 2025")
} 