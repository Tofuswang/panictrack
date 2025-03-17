//
//  ContentView.swift
//  panictrack
//
//  Created by Tofus on 2025/3/16.
//

import SwiftUI

#if os(iOS)
import UIKit
#endif

struct ContentView: View {
    @ObservedObject var panicStore: PanicStore
    @State private var particles: [(id: UUID, emoji: String)] = []
    @State private var showingHelp = false
    
    private let emojis = ["😫"]
    
    private func showEmoji() {
        let emoji = emojis.randomElement() ?? "😫"
        let particle = (id: UUID(), emoji: emoji)
        particles.append(particle)
        
        // 0.5秒後移除 emoji
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            particles.removeAll { $0.id == particle.id }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // 按鈕和統計資訊的容器
                    ZStack {
                        // 顯示所有 emoji 粒子
                        ForEach(particles, id: \.id) { particle in
                            EmojiParticle(emoji: particle.emoji)
                        }
                        
                        // 固定的按鈕和統計資訊
                        VStack(spacing: 0) {
                            PanicButton {
                                showEmoji()
                                panicStore.addEntry()
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            StatsView(
                                todayCount: panicStore.entriesForDate(Date()).count,
                                weekCount: panicStore.entriesForLastNDays(7).count
                            )
                            .padding(.bottom)
                        }
                    }
                }
            }
            .navigationTitle("焦慮戳戳樂")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingHelp = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showingHelp) {
                HelpView()
            }
            .tint(.white)
        }
    }
}

#Preview {
    ContentView(panicStore: PanicStore())
}
