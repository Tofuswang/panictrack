import SwiftUI
import Charts

struct StatsPageView: View {
    @EnvironmentObject var panicStore: PanicStore
    @State private var selectedTimeRange = TimeRange.day
    @State private var chartScale: CGFloat = 1
    @State private var showingSettings = false
    
    enum TimeRange {
        case day, week, month, year
        
        var title: String {
            switch self {
            case .day: return String(localized: "stats.range.day")
            case .week: return String(localized: "stats.range.week")
            case .month: return String(localized: "stats.range.month")
            case .year: return String(localized: "stats.range.year")
            }
        }
    }
    
    var timePeriodDescription: String {
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        
        switch selectedTimeRange {
        case .day:
            formatter.dateFormat = "M月d日"
            return formatter.string(from: now)
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -6, to: now)!
            formatter.dateFormat = "M/d"
            return "\(formatter.string(from: weekAgo)) - \(formatter.string(from: now))"
        case .month:
            formatter.dateFormat = "yyyy年M月"
            return formatter.string(from: now)
        case .year:
            formatter.dateFormat = "yyyy年"
            return formatter.string(from: now)
        }
    }
    
    var chartTitle: String {
        switch selectedTimeRange {
        case .day:
            return String(localized: "stats.trend.day")
        case .week:
            return String(localized: "stats.trend.week")
        case .month:
            return String(localized: "stats.trend.month")
        case .year:
            return String(localized: "stats.trend.year")
        }
    }
    
    var chartData: [(label: String, count: Int)] {
        switch selectedTimeRange {
        case .day:
            return panicStore.getDayStats() // 0-23點
        case .week:
            return panicStore.getWeekStats() // 最迗7天
        case .month:
            return panicStore.getMonthStats() // 當月每日
        case .year:
            return panicStore.getYearStats() // 1-12月
        }
    }
    
    private var totalCount: Int {
        chartData.reduce(0) { $0 + $1.count }
    }
    
    private var averageCount: String {
        let total = Double(totalCount)
        let count = Double(max(1, chartData.count))
        return String(format: "%.1f", total / count)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Time range picker
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(LocalizedStringKey("stats.period"))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                            Text("•")
                                .foregroundColor(.white.opacity(0.5))
                            Text(timePeriodDescription)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 0) {
                            ForEach([TimeRange.day, .week, .month, .year], id: \.self) { range in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedTimeRange = range
                                    }
                                }) {
                                    Text(range.title)
                                        .font(.system(.body))
                                        .foregroundColor(selectedTimeRange == range ? .white : .white.opacity(0.7))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 36)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(selectedTimeRange == range ? Color(white: 0.2) : Color.clear)
                                                .animation(.easeInOut(duration: 0.2), value: selectedTimeRange)
                                        )
                                }
                            }
                        }
                        .background(Color(white: 0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
                    // Chart section
                    VStack(spacing: 16) {
                        Text(chartTitle)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .transition(.opacity)
                            .id("chart_title_\(selectedTimeRange)")
                        
                        if chartData.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.system(size: 48))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.gray.opacity(0.7), .gray],
                                            startPoint: .bottomLeading,
                                            endPoint: .topTrailing
                                        )
                                    )
                                
                                Text(LocalizedStringKey("stats.no.data"))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(white: 0.1))
                            )
                            .padding(.horizontal)
                            .transition(.opacity)
                        } else {
                            PanicBarChart(
                                data: chartData,
                                title: chartTitle
                            )
                            .padding(.horizontal)
                            .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut, value: selectedTimeRange)
                    .animation(.easeInOut, value: chartData.isEmpty)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(LocalizedStringKey("stats.summary"))
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("•")
                                .foregroundColor(.white.opacity(0.5))
                            Text(timePeriodDescription)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            StatSummaryCard(
                                title: String(localized: "stats.total"),
                                value: "\(totalCount)",
                                icon: "hand.tap.fill",
                                gradient: [Color.red.opacity(0.7), Color.red],
                                description: String(localized: "stats.total.description")
                            )
                            
                            StatSummaryCard(
                                title: String(localized: "stats.average"),
                                value: averageCount,
                                icon: "chart.bar.fill",
                                gradient: [Color.blue.opacity(0.7), Color.blue],
                                description: String(localized: "stats.average.description")
                            )
                            
                            StatSummaryCard(
                                title: String(localized: "stats.highest"),
                                value: "\(chartData.map { $0.count }.max() ?? 0)",
                                icon: "arrow.up.circle.fill",
                                gradient: [Color.orange.opacity(0.7), Color.orange],
                                description: String(localized: "stats.highest.description")
                            )
                            
                            StatSummaryCard(
                                title: String(localized: "stats.lowest"),
                                value: "\(chartData.map { $0.count }.min() ?? 0)",
                                icon: "arrow.down.circle.fill",
                                gradient: [Color.green.opacity(0.7), Color.green],
                                description: String(localized: "stats.lowest.description")
                            )
                        }
                        .padding(.horizontal)
                    }
                    .animation(.easeInOut, value: selectedTimeRange)
                }
            }
            .navigationTitle(LocalizedStringKey("stats.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct StatSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    )
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.12), Color(white: 0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

#Preview {
    let store = PanicStore()
    // 添加一些模擬數據供預覽使用
    let now = Date()
    let calendar = Calendar.current
    
    // 今日數據
    store.addEntry() // 現在
    if let twoHoursAgo = calendar.date(byAdding: .hour, value: -2, to: now) {
        store.addEntry(at: twoHoursAgo)
    }
    
    // 最迗7天數據
    if let oneDayAgo = calendar.date(byAdding: .day, value: -1, to: now),
       let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now) {
        store.addEntry(at: oneDayAgo)
        store.addEntry(at: twoDaysAgo)
    }
    
    return StatsPageView()
        .environmentObject(store)
        .preferredColorScheme(.dark)
}
