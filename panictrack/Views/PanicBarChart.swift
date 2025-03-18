import SwiftUI
import Charts

struct PanicBarChart: View {
    let data: [(label: String, count: Int)]
    let title: String
    
    var body: some View {
        Chart(data, id: \.label) { item in
            BarMark(
                x: .value("Time", item.label),
                y: .value("Count", item.count)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.red.opacity(0.7), .red],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(height: 200)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.1))
        )
    }
}
