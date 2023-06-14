import Charts
import SwiftUI

extension Date {
    // Creates a Date object for a given hour in the current day.
    static func hour(_ hour: Int) -> Date {
        var components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: Date()
        )
        components.hour = hour
        return Calendar.current.date(from: components)!
    }
}

struct Weather: Identifiable {
    let dateTime: Date
    let temperature: Double
    var id: Date { dateTime }
}

// This is the data to be plotted.
private let forecast: [Weather] = [
    .init(dateTime: Date.hour(8), temperature: 43.0),
    .init(dateTime: Date.hour(9), temperature: 48.0),
    .init(dateTime: Date.hour(10), temperature: 55.0),
    .init(dateTime: Date.hour(11), temperature: 60.0),
    .init(dateTime: Date.hour(12), temperature: 64.0),
    .init(dateTime: Date.hour(13), temperature: 67.0),
    .init(dateTime: Date.hour(14), temperature: 69.0),
    .init(dateTime: Date.hour(15), temperature: 70.0),
    .init(dateTime: Date.hour(16), temperature: 71.0),
    .init(dateTime: Date.hour(17), temperature: 71.0),
    .init(dateTime: Date.hour(18), temperature: 69.0),
    .init(dateTime: Date.hour(19), temperature: 67.0),
    .init(dateTime: Date.hour(20), temperature: 65.0),
    .init(dateTime: Date.hour(21), temperature: 63.0),
    .init(dateTime: Date.hour(22), temperature: 61.0),
    .init(dateTime: Date.hour(23), temperature: 58.0),
    .init(dateTime: Date.hour(24), temperature: 55.0)
]

struct ContentView: View {
    @State private var rawSelectedDate: Date?

    private let dateFormatter = DateFormatter()

    init() {
        dateFormatter.dateFormat = "h a"
    }

    private func annotation(for weather: Weather) -> some View {
        let t = dateFormatter.string(from: weather.dateTime)
        return VStack(alignment: .leading) {
            Text("Time: " + t)
            Text(String(format: "%.2f°F", weather.temperature))
        }
        .padding(5)
        .border(.gray)
    }

    private func ruleMark(selectedDate: Date) -> some ChartContent {
        // Find the index of the first Weather object
        // that is after the selected date.
        let index = forecast
            .firstIndex { $0.dateTime > selectedDate }
            ?? forecast.count

        // Get the selected Weather object.
        let weather = forecast[index - 1]

        return RuleMark(x: .value("Selected", weather.dateTime))
            .foregroundStyle(.gray.opacity(0.3))
            .offset(yStart: -10) // extend above chart
            .zIndex(-1) // behind LineMarks and PointMarks
            .annotation(
                position: .top, // above chart
                spacing: 0,
                // between top of RuleMark & annotation
                overflowResolution: .init(
                    x: .fit(to: .chart),
                    // prevents horizontal spill
                    y: .disabled // allows annotation above
                    // chart
                )
            ) {
                annotation(for: weather)
            }
    }

    var body: some View {
        VStack {
            Chart(forecast) { data in
                let time = PlottableValue.value("Time", data.dateTime)
                let temp = PlottableValue.value("Temperature", data.temperature)

                LineMark(x: time, y: temp)
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)

                PointMark(x: time, y: temp)
                    .foregroundStyle(.black)

                if let rawSelectedDate {
                    ruleMark(selectedDate: rawSelectedDate)
                }
            }
            // See https://feedbackassistant.apple.com/feedback/12346794
            .chartXSelection(value: $rawSelectedDate)
            .padding(.top, 40) // leaves room for annotations
        }
        .padding(50)
    }
}

#Preview {
    ContentView()
}
