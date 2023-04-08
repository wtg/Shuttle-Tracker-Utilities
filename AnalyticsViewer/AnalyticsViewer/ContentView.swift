//
//  ContentView.swift
//  AnalyticsViewer
//
//  Created by Aidan Flaherty on 4/4/23.
//

import SwiftUI
import CoreData
import Charts

struct ContentView: View {
    @State
    private var baseURL = URL(string: "https://staging.shuttletracker.app")!
    
    @State
    private var entries = [Analytics.Entry]()
    
    private enum Options : String, Hashable, CaseIterable {
        case total = "Total Entries", coldLaunches = "Cold Launches", boardBusTapped = "Board Bus Tapped", leaveBusTapped = "Leave Bus Tapped"
    }
    
    @State
    private var option: Options = .total
    
    var body: some View {
        NavigationSplitView {
            List(selection: $option) {
                ForEach(Options.allCases, id:\.self) { option in
                    NavigationLink(value: option) {
                        Text(option.rawValue)
                    }
                }
            }
        } detail: {
            switch option {
            case .total:
                entryChart(eventType: nil)
            case .coldLaunches:
                entryChart(eventType: .coldLaunch)
            case .boardBusTapped:
                entryChart(eventType: .boardBusTapped)
            case .leaveBusTapped:
                entryChart(eventType: .leaveBusTapped)
            }
        }
            .navigationSplitViewStyle(.balanced)
            .accentColor(.red)
            .task {
                await refresh()
            }
    }
    
    func entryChart(eventType: Analytics.EventType?) -> some View {
        let dates = entries.map({ $0.date }).sorted()
        
        return Chart {
            if let first = dates.first, let last = dates.last, let range = Calendar.current.dateComponents([.day], from: first, to: last).day {
                ForEach(0..<range + 1, id:\.self) { index in
                    if let day = Calendar.current.date(byAdding: .day, value: index, to: first) {
                        let count = entries.filter({ eventType == nil || $0.eventType == eventType }).filter({ Calendar.current.dateComponents([.day], from: $0.date).day! == Calendar.current.dateComponents([.day], from: day).day! }).count
                        LineMark(x: .value("Day", day), y: .value("Value", count))
                            .cornerRadius(10)
                            .interpolationMethod(InterpolationMethod.stepCenter)
                    }
                }
            }
        }
        .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    func refresh() async {
        let url = self.baseURL.appending(component: "analytics").appending(component: "entries")
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            self.entries = try decoder.decode([Analytics.Entry].self, from: data)
        } catch {
            print(error)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
