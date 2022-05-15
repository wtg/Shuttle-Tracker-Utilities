//
//  ContentView.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import SwiftUI

struct ContentView: View {
	
	enum SheetType: Int, IdentifiableByRawValue {
		
		case serverSelection
		
	}
	
	@State private var sheetType: SheetType?
	
	@State private var isRefreshing = false
	
	@State private var doShowInspector = true
	
	@EnvironmentObject private var mapState: MapState
	
	private let timer = Timer
		.publish(every: 5, on: .main, in: .common)
		.autoconnect()
	
	var body: some View {
		HSplitView {
			MapView()
				.frame(minWidth: 400, idealWidth: 600)
			if self.doShowInspector {
				Inspector()
					.frame(minWidth: 200, idealWidth: 200, maxWidth: 300, maxHeight: .infinity)
			}
		}
			.frame(minHeight: 300, idealHeight: 500)
			.toolbar {
				ToolbarItem {
					if self.isRefreshing {
						ProgressView()
					} else {
						Button {
							NotificationCenter.default.post(name: .refreshBuses, object: nil)
						} label: {
							Label("Refresh", systemImage: "arrow.clockwise")
						}
					}
				}
				ToolbarItem {
					Button {
						self.sheetType = .serverSelection
					} label: {
						Label("Select Server", systemImage: "server.rack")
					}
				}
				ToolbarItem {
					Button {
						withAnimation {
							self.doShowInspector.toggle()
						}
					} label: {
						Label("Toggle Inspector", systemImage: "sidebar.right")
					}
				}
			}
			.sheet(item: self.$sheetType) {
				Task {
					await self.refreshMap()
				}
			} content: { (sheetType) in
				switch sheetType {
				case .serverSelection:
					ServerSelectionSheet(sheetType: self.$sheetType)
				}
			}
			.onAppear {
				NSWindow.allowsAutomaticWindowTabbing = false
			}
			.onReceive(NotificationCenter.default.publisher(for: .refreshBuses, object: nil)) { (_) in
				withAnimation {
					self.isRefreshing = true
				}
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					Task {
						await self.refreshMap()
					}
				}
			}
			.onReceive(self.timer) { (_) in
				if self.mapState.doShowBuses {
					Task {
						await self.refreshBuses()
					}
				}
			}
	}
	
	@MainActor private func refreshBuses() async {
		self.mapState.buses = await [Bus].download()
		self.isRefreshing = false
	}
	
	@MainActor private func refreshMap() async {
		self.mapState.routes = await [Route].download()
		self.mapState.stops = await [Stop].download()
		await self.refreshBuses()
	}
	
}

struct ContentViewPreviews: PreviewProvider {
	
	static var previews: some View {
		ContentView()
			.environmentObject(MapState.shared)
	}
	
}
