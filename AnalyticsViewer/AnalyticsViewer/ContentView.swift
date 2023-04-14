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
        case total = "Total Entries", cumulativeTotal = "Cumulative total", coldLaunches = "Cold Launches", boardBusTapped = "Board Bus Tapped", leaveBusTapped = "Leave Bus Tapped", totalColorBlind = "Total Color Blind Users", manualBoardBuses = "Manually Boarded Buses", autoBoardBuses = "Automatically boarded buses", manualLeftBuses = "Manually Left Buses", autoLeftBuses = "Automatically left buses",
            permissionsSheetOpened = "Permissions Sheet Opened", debugModeEnabled = "Debug Mode Enabled"
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
                runningCountChart(increment: .colorBlindModeToggled(enabled: true), decrement: .colorBlindModeToggled(enabled: false))
            case .cumulativeTotal:
                runningCountChart(increment: nil, decrement: nil)
            case .manualBoardBuses:
                entryChart(eventType: .boardBusActivated(manual: true))
            case .autoBoardBuses:
                entryChart(eventType: .boardBusActivated(manual: false))
            case .manualLeftBuses:
                entryChart(eventType: .boardBusDeactivated(manual: true))
            case .autoLeftBuses:
                entryChart(eventType: .boardBusDeactivated(manual: false))
            case .permissionsSheetOpened:
                entryChart(eventType: .permissionsSheetOpened)
            case .debugModeEnabled:
                runningCountChart(increment: .debugModeToggled(enabled: true), decrement: .debugModeToggled(enabled: false))
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
        //let users = Array(Set(entries.map({ $0.userID })))
        
        return ZStack {
            if let first = dates.first, let last = dates.last, let range = Calendar.current.dateComponents([.day], from: first, to: last).day {
                let dateCounts = entries.reduce(into: [Date : Int]()) {
                    let date = Calendar.current.date(byAdding: .day, value: Calendar.current.dateComponents([.day], from: first, to: $1.date).day!, to: first)!
                    $0[date] = ($0[date] ?? 0) + 1
                }
                
                let counts = (0..<range + 1).reduce(into: [Date: Int]()) {
                    let day = Calendar.current.date(byAdding: .day, value: $1, to: first)!
                    $0[day] = dateCounts[day] ?? 0
                }
                
                chart(counts: counts)
            }
        }
    }
    
    func runningCountChart(increment: Analytics.EventType?, decrement: Analytics.EventType?) -> some View {
        let entries = entries.filter({ increment == nil || $0.eventType == increment || $0.eventType == decrement })

        let dates = entries.map({ $0.date }).sorted()
        
        return ZStack {
            if let first = dates.first, let last = dates.last, let range = Calendar.current.dateComponents([.day], from: first, to: last).day {
                let incrementCounts = entries.filter({ increment == nil || $0.eventType == increment }).reduce(into: [Date : Int]()) {
                    let date = Calendar.current.date(byAdding: .day, value: Calendar.current.dateComponents([.day], from: first, to: $1.date).day!, to: first)!
                    $0[date] = ($0[date] ?? 0) + 1
                }
                
                let decrementCounts = entries.filter({ $0.eventType == decrement }).reduce(into: [Date : Int]()) {
                    let date = Calendar.current.date(byAdding: .day, value: Calendar.current.dateComponents([.day], from: first, to: $1.date).day!, to: first)!
                    $0[date] = ($0[date] ?? 0) + 1
                }
                
                let counts = (0..<range + 1).reduce(into: [Date: Int]()) {
                    let day = Calendar.current.date(byAdding: .day, value: $1, to: first)!
                    var val = (incrementCounts[day] ?? 0) - (decrementCounts[day] ?? 0)
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
                    }.opacity(abs(rangeEnd - rangeStart) > 0.001 ? 1 : 0)
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
                })
            }
        }
        .foregroundStyle(.linearGradient(colors: [.red, Color(red: 0.6, green: 0.2, blue: 0.2)], startPoint: .top, endPoint: .bottom))
        .frame(maxWidth: .infinity)
        .padding()
        .onAppear {
            rangeStart = 0
            rangeEnd = 0
        }
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
