import SwiftUI

struct StatsView: View {
    let todayCount: Int
    let weekCount: Int
    
    var body: some View {
        HStack(spacing: 20) {
            StatCard(title: "今天", count: todayCount)
            StatCard(title: "本週", count: weekCount)
        }
        .padding()
    }
}

struct StatCard: View {
    let title: String
    let count: Int
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    StatsView(todayCount: 5, weekCount: 23)
        .preferredColorScheme(.dark)
}
