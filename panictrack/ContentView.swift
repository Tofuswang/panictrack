//
//  ContentView.swift
//  panictrack
//
//  Created by Tofus on 2025/3/16.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var panicStore = PanicStore()
    @State private var selectedTimeRange = TimeRange.today
    
    enum TimeRange {
        case today, week, month
        
        var title: String {
            switch self {
            case .today: return "今天"
            case .week: return "本週"
            case .month: return "本月"
            }
        }
    }
    
    var todayEntries: [PanicEntry] {
        panicStore.entriesForDate(Date())
    }
    
    var weekEntries: [PanicEntry] {
        panicStore.entriesForLastNDays(7)
    }
    
    var monthEntries: [PanicEntry] {
        panicStore.entriesForLastNDays(30)
    }
    
    var body: some View {
        NavigationView {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Picker("Time Range", selection: $selectedTimeRange) {
                    Text(TimeRange.today.title).tag(TimeRange.today)
                    Text(TimeRange.week.title).tag(TimeRange.week)
                    Text(TimeRange.month.title).tag(TimeRange.month)
                }
                .pickerStyle(.segmented)
                .padding()
                
                Spacer()
                
                PanicButton {
                    panicStore.addEntry()
                    // TODO: Add haptic feedback
                }
                .padding()
                
                Spacer()
                
                StatsView(
                    todayCount: todayEntries.count,
                    weekCount: weekEntries.count
                )
                    .padding(.bottom)
            }
            }
            .navigationTitle("焦慮戳戳樂")
        }
    }
}

#Preview {
    ContentView()
}
