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
        case total = "Total Entries", case cumulativeTotal = "Cumulative total", coldLaunches = "Cold Launches", boardBusTapped = "Board Bus Tapped", leaveBusTapped = "Leave Bus Tapped",
        totalColorBlind = "Total Color Blind Users"
    }
    
    @State
    private var option: Options = .total
    
    @State
    private var rangeStart: Float = 0
    
    @State
    private var rangeEnd: Float = 0
    
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
            case .totalColorBlind:
                runningCountChart(eventType: .colorBlindModeToggled(enabled: true))
            }
        }
            .navigationSplitViewStyle(.balanced)
            .accentColor(.red)
            .task {
                await refresh()
            }
    }
    
    func entryChart(eventType: Analytics.EventType?) -> some View {
        let entries = entries.filter({ eventType == nil || $0.eventType == eventType })

        let dates = entries.map({ $0.date }).sorted()
        let users = Array(Set(entries.map({ $0.userID })))
        
        return ZStack {
            if let first = dates.first, let last = dates.last, let range = Calendar.current.dateComponents([.day], from: first, to: last).day {
                let counts = (0..<range + 1).reduce(into: [Date: Int]()) {
                    let day = Calendar.current.date(byAdding: .day, value: $1, to: first)!
                    $0[day] = entries.filter({ Calendar.current.dateComponents([.day], from: $0.date).day! == Calendar.current.dateComponents([.day], from: day).day! }).count
                }
                
                chart(counts: counts)
            }
        }
    }
    
    func runningCountChart(eventType: Analytics.EventType?) -> some View {
        let entries = entries.filter({ eventType == nil || $0.eventType == eventType })

        let users = entries.reduce(into: [UUID: Analytics.Entry]()) {
            $0[$1.userID] = $1
        }
        let dates = users.map({ $1.date }).sorted()
        
        return ZStack {
            if let first = dates.first, let last = dates.last, let range = Calendar.current.dateComponents([.day], from: first, to: last).day {
                let counts = (0..<range + 1).reduce(into: [Date: Int]()) {
                    let day = Calendar.current.date(byAdding: .day, value: $1, to: first)!
                    var val = entries.filter({ Calendar.current.dateComponents([.day], from: $0.date).day! == Calendar.current.dateComponents([.day], from: day).day! }).count
                    if $1 > 0 {
                        let prevDay = Calendar.current.date(byAdding: .day, value: $1 - 1, to: first)!
                        if let prevVal = $0[prevDay] {
                            val += prevVal
                        }
                    }
                    
                    $0[day] = val
                }
                
                chart(counts: counts)
            }
        }
    }
    
    func chart(counts: [Date : Int]) -> some View {
        let tolerance: Float = 0.1
        
        return GeometryReader { reader in
            VStack {
                Color.clear.overlay(
                    Chart {
                        ForEach(Array(counts.keys.sorted()), id:\.self) { day in
                            LineMark(x: .value("Day", day), y: .value("Value", counts[day]!))
                                .cornerRadius(10)
                                .interpolationMethod(InterpolationMethod.stepCenter)
                        }
                    }
                        .padding(.trailing, abs(rangeStart - rangeEnd) > tolerance ? reader.size.width - reader.size.width / CGFloat(rangeEnd - rangeStart) : 0)
                        .position(x: reader.size.width/2 + (abs(rangeStart - rangeEnd) > tolerance ? -reader.size.width / CGFloat(rangeEnd - rangeStart) * CGFloat(rangeStart) : 0), y: reader.size.height/4)
                )
                
                Chart {
                    ForEach(Array(counts.keys.sorted()), id:\.self) { day in
                        LineMark(x: .value("Day", day), y: .value("Value", counts[day]!))
                            .cornerRadius(10)
                            .interpolationMethod(InterpolationMethod.stepCenter)
                    }
                }.overlay(
                    HStack(spacing: 0){
                        Spacer(minLength: 0)
                            .frame(width: reader.size.width * CGFloat(rangeStart))
                        Color.gray.opacity(0.3).frame(width: 2)
                        Color.gray.opacity(abs(rangeEnd - rangeStart) > tolerance ? 0.1 : 0)
                            .frame(width: reader.size.width * CGFloat(rangeEnd - rangeStart))
                            .shadow(color: .white, radius: 3)
                        Color.gray.opacity(0.3).frame(width: 2)
                        Spacer(minLength: 0)
                    }
                )
                .gesture(DragGesture().onChanged { event in
                    let rangeS = min(0.99, max(0.005, Float(min(event.startLocation.x, event.location.x) / reader.size.width)))
                    let rangeE = min(0.99, max(0.005, Float(max(event.startLocation.x, event.location.x) / reader.size.width)))
                    
                    if abs(rangeE - rangeS) > tolerance {
                        withAnimation {
                            rangeStart = rangeS
                            rangeEnd = rangeE
                        }
                    } else {
                        rangeStart = rangeS
                        rangeEnd = rangeE
                    }
                }.onEnded { event in
                    
                })
            }
        }
        .foregroundStyle(.linearGradient(colors: [.red, .purple], startPoint: .top, endPoint: .bottom))
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
