import Foundation

struct PanicEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    
    init(id: UUID = UUID(), timestamp: Date = Date()) {
        self.id = id
        self.timestamp = timestamp
    }
}

class PanicStore: ObservableObject {
    @Published private(set) var entries: [PanicEntry] = []
    private let entriesKey = "panicEntries"
    
    init() {
        loadEntries()
    }
    
    // MARK: - Entry Management
    
    func addEntry(at timestamp: Date = Date()) {
        let entry = PanicEntry(timestamp: timestamp)
        entries.append(entry)
        saveEntries()
    }
    
    func entriesForDate(_ date: Date) -> [PanicEntry] {
        entries.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
    }
    
    func entriesForLastNDays(_ days: Int) -> [PanicEntry] {
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -days + 1, to: today)!
        return entries.filter { entry in
            entry.timestamp >= startDate && entry.timestamp <= today
        }
    }
    
    // MARK: - Statistics
    
    func getDayStats() -> [(label: String, count: Int)] {
        let calendar = Calendar.current
        let today = Date()
        let todayEntries = entriesForDate(today)
        
        var hourCounts = [Int: Int]() // hour: count
        for entry in todayEntries {
            let hour = calendar.component(.hour, from: entry.timestamp)
            hourCounts[hour, default: 0] += 1
        }
        
        return (0...23).map { hour in
            let hourString = String(format: "%02d", hour)
            return (label: hourString, count: hourCounts[hour] ?? 0)
        }
    }
    
    func getWeekStats() -> [(label: String, count: Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        // 取得過去7天的數據
        var result: [(label: String, count: Int)] = []
        for daysAgo in (0...6).reversed() {
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: calendar.startOfDay(for: today))!
            let entries = entriesForDate(date)
            let count = entries.count
            
            // 格式化日期，例如：3/16
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let label = daysAgo == 0 ? "今天" : "\(month)/\(day)"
            
            result.append((label: label, count: count))
        }
        return result
    }
    
    func getMonthStats() -> [(label: String, count: Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        // 取得本月第一天
        let components = calendar.dateComponents([.year, .month], from: today)
        let startOfMonth = calendar.date(from: components)!
        
        // 取得本月天數
        let range = calendar.range(of: .day, in: .month, for: today)!
        let numberOfDays = range.count
        
        var dayCounts = [Int: Int]() // day: count
        let monthEntries = entries.filter { entry in
            entry.timestamp >= startOfMonth && entry.timestamp <= today
        }
        
        for entry in monthEntries {
            let day = calendar.component(.day, from: entry.timestamp)
            dayCounts[day, default: 0] += 1
        }
        
        return (1...numberOfDays).map { day in
            let isToday = calendar.isDate(calendar.date(from: DateComponents(year: components.year, month: components.month, day: day))!, inSameDayAs: today)
            let label = isToday ? "今天" : "\(day)"
            return (label: label, count: dayCounts[day] ?? 0)
        }
    }
    
    func getYearStats() -> [(label: String, count: Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        // 取得今年第一天
        var components = calendar.dateComponents([.year], from: today)
        let startOfYear = calendar.date(from: components)!
        
        var monthCounts = [Int: Int]() // month: count
        let yearEntries = entries.filter { entry in
            entry.timestamp >= startOfYear && entry.timestamp <= today
        }
        
        for entry in yearEntries {
            let month = calendar.component(.month, from: entry.timestamp)
            monthCounts[month, default: 0] += 1
        }
        
        let monthNames = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
        
        return (0...11).map { index in
            let month = index + 1
            let isCurrentMonth = calendar.component(.month, from: today) == month
            let label = isCurrentMonth ? "本月" : monthNames[index]
            return (label: label, count: monthCounts[month] ?? 0)
        }
    }
    
    // MARK: - Export
    
    func exportDailyStats() -> String {
        let stats = getDayStats()
        var output = "每日焦慮點擊統計\n"
        output += "=================\n"
        output += "時間 | 次數\n"
        output += "-----------------\n"
        
        // 建立小時對應的點擊數
        var hourCounts: [Int: Int] = [:]
        for stat in stats {
            if let hour = Int(stat.label) {
                hourCounts[hour] = stat.count
            }
        }
        
        // 顯示 0-23 點的資料
        for hour in 0...23 {
            let count = hourCounts[hour] ?? 0
            output += String(format: "%02d:00 | %d\n", hour, count)
        }
        
        let total = stats.reduce(0) { $0 + $1.count }
        output += "-----------------\n"
        output += "總計: \(total) 次\n"
        
        return output
    }
    
    func exportToCSV() -> String {
        // 排序所有資料，依日期分組
        let calendar = Calendar.current
        var dailyHourlyEntries: [Date: [Int: Int]] = [:]
        
        // 將所有資料依日期和小時分組
        for entry in entries {
            let date = calendar.startOfDay(for: entry.timestamp)
            let hour = calendar.component(.hour, from: entry.timestamp)
            if dailyHourlyEntries[date] == nil {
                dailyHourlyEntries[date] = [:]
            }
            dailyHourlyEntries[date]?[hour, default: 0] += 1
        }
        
        // 建立 CSV 檔案
        var csv = "日期"
        for hour in 0...23 {
            csv += String(format: ",%02d:00", hour)
        }
        csv += "\n"
        
        // 依日期排序
        let sortedDates = dailyHourlyEntries.keys.sorted()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        for date in sortedDates {
            csv += "\"\(dateFormatter.string(from: date))\""
            let hourlyData = dailyHourlyEntries[date] ?? [:]
            
            for hour in 0...23 {
                let count = hourlyData[hour] ?? 0
                csv += ",\(count)"
            }
            csv += "\n"
        }
        
        return csv
    }
    
    // MARK: - Persistence
    
    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: entriesKey),
              let decodedEntries = try? JSONDecoder().decode([PanicEntry].self, from: data) else {
            return
        }
        entries = decodedEntries
    }
    
    private func saveEntries() {
        guard let encodedData = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(encodedData, forKey: entriesKey)
    }
}
