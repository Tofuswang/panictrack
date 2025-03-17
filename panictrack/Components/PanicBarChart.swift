import SwiftUI
import Charts

#if os(iOS)
import UIKit
#endif

struct PanicBarChart: View {
    @Environment(\.colorScheme) private var colorScheme
    let data: [(label: String, count: Int)]
    let title: String
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGPoint = .zero
    @State private var lastOffset: CGPoint = .zero
    @State private var isScaling: Bool = false
    
    private var maxCount: Int {
        data.map { $0.count }.max() ?? 0
    }
    
    private var chartWidth: CGFloat {
        let baseWidth = UIScreen.main.bounds.width - 32
        let minWidth = baseWidth
        let maxWidth = baseWidth * scale
        return max(minWidth, maxWidth)
    }
    
    private var scaleRange: ClosedRange<CGFloat> {
        // 根據數據點數加大最大縮放倍數
        let maxScale = max(3.0, min(5.0, CGFloat(data.count) / 8.0))
        return 1.0...maxScale
    }
    
    private var trendDescription: String {
        guard data.count > 1 else { return "無趨勢" }
        
        let counts = data.map { $0.count }
        let firstHalf = Array(counts[..<(counts.count/2)])
        let secondHalf = Array(counts[(counts.count/2)...])
        
        let firstHalfAvg = Double(firstHalf.reduce(0, +)) / Double(firstHalf.count)
        let secondHalfAvg = Double(secondHalf.reduce(0, +)) / Double(secondHalf.count)
        
        let diff = secondHalfAvg - firstHalfAvg
        if abs(diff) < 0.5 {
            return "趨勢穩定"
        } else if diff > 0 {
            return "上升趨勢"
        } else {
            return "下降趨勢"
        }
    }
    
    private var trendIcon: String {
        switch trendDescription {
        case "上升趨勢": return "arrow.up.right"
        case "下降趨勢": return "arrow.down.right"
        default: return "arrow.right"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("•")
                    .foregroundColor(.white.opacity(0.5))
                HStack(spacing: 4) {
                    Image(systemName: trendIcon)
                        .imageScale(.small)
                    Text(trendDescription)
                        .font(.caption)
                }
                .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                Chart {
                    ForEach(data, id: \.label) { item in
                        BarMark(
                            x: .value("Time", item.label),
                            y: .value("Count", item.count)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red.opacity(0.8), .red],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .cornerRadius(4)
                    }
                    
                    // 平均線
                    if data.count > 1 {
                        RuleMark(
                            y: .value("Average", Double(data.map { $0.count }.reduce(0, +)) / Double(data.count))
                        )
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(.white.opacity(0.3))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                            .foregroundStyle(.white.opacity(0.1))
                        AxisValueLabel() {
                            if let count = value.as(Int.self) {
                                Text("\(count)")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(.white.opacity(0.1))
                        AxisValueLabel() {
                            if let label = value.as(String.self), !label.isEmpty {
                                Text(label)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                }
                .frame(width: chartWidth, height: 200)
                .chartYScale(domain: 0...max(5, maxCount))
                .chartBackground { chartProxy in
                    Color.black.opacity(0.3)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .clipped()
            .contentShape(Rectangle())
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            withAnimation(.interactiveSpring()) {
                                let delta = value / lastScale
                                scale = min(max(scaleRange.lowerBound, scale * delta), scaleRange.upperBound)
                                isScaling = true
                            }
                            lastScale = value
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                            isScaling = false
                        },
                    DragGesture()
                        .onChanged { value in
                            guard scale > 1.0 else { return }
                            withAnimation(.interactiveSpring()) {
                                let translation = value.translation
                                let newOffset = CGPoint(
                                    x: lastOffset.x + translation.width,
                                    y: lastOffset.y
                                )
                                // 限制左右移動範圍
                                let maxOffset = (chartWidth - UIScreen.main.bounds.width + 32) / 2
                                offset = CGPoint(
                                    x: max(-maxOffset, min(maxOffset, newOffset.x)),
                                    y: 0
                                )
                            }
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
            )
            .gesture(
                TapGesture(count: 2)
                    .onEnded { _ in
                        withAnimation(.interactiveSpring()) {
                            // 重置縮放和位移
                            scale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        }
                    }
            )
            .frame(height: 200)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // 今日趨勢
        PanicBarChart(
            data: [
                (label: "00", count: 2),
                (label: "01", count: 1),
                (label: "02", count: 3),
                (label: "03", count: 0),
                (label: "04", count: 2),
                (label: "05", count: 1),
                (label: "06", count: 0),
                (label: "07", count: 1),
                (label: "08", count: 2),
                (label: "09", count: 3),
                (label: "10", count: 4),
                (label: "11", count: 2)
            ],
            title: "今日焦慮趨勢"
        )
        
        // 最近7天趨勢
        PanicBarChart(
            data: [
                (label: "3/10", count: 3),
                (label: "3/11", count: 5),
                (label: "3/12", count: 4),
                (label: "3/13", count: 6),
                (label: "3/14", count: 3),
                (label: "3/15", count: 4),
                (label: "今天", count: 2)
            ],
            title: "最近7天焦慮趨勢"
        )
        
        // 本月趨勢
        PanicBarChart(
            data: [
                (label: "1", count: 2),
                (label: "2", count: 4),
                (label: "3", count: 3),
                (label: "4", count: 5),
                (label: "5", count: 4),
                (label: "6", count: 6),
                (label: "7", count: 3),
                (label: "8", count: 4),
                (label: "9", count: 5),
                (label: "10", count: 3),
                (label: "11", count: 4),
                (label: "12", count: 2),
                (label: "13", count: 3),
                (label: "14", count: 4),
                (label: "15", count: 3),
                (label: "今天", count: 2)
            ],
            title: "本月焦慮趨勢"
        )
    }
    .preferredColorScheme(.dark)
    .background(Color.black)
    .padding()
}
