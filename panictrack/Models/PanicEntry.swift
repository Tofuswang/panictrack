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
    
    func addEntry() {
        let entry = PanicEntry()
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
