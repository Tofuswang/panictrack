import SwiftUI

struct StatsView: View {
    static let previewData = (todayCount: 5, weekCount: 23)
    
    let todayCount: Int
    let weekCount: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // 今日統計
            VStack(alignment: .center, spacing: 8) {
                Text(LocalizedStringKey("stats.today"))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text("\(todayCount)")
                    .font(.system(size: 36))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            
            // 分隔線
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 2, height: 60)
            
            // 本週統計
            VStack(alignment: .center, spacing: 8) {
                Text(LocalizedStringKey("stats.week"))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text("\(weekCount)")
                    .font(.system(size: 36))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.12))
        )
        .padding(.horizontal, 4)
    }
}

#Preview {
    VStack {
        // Add spacer to simulate the large panic button above
        Spacer()
            .frame(height: 480) // Match PanicButton height
        
        StatsView(todayCount: StatsView.previewData.todayCount,
                 weekCount: StatsView.previewData.weekCount)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
}
