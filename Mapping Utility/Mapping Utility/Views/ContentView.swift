//
//  ContentView.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import SwiftUI

struct ContentView: View {
	
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
				ScrollView {
					DisclosureGroup {
						VStack(alignment: .leading) {
							Toggle("Show buses", isOn: self.$mapState.doShowBuses)
							Toggle("Show stops", isOn: self.$mapState.doShowStops)
							Toggle("Show routes", isOn: self.$mapState.doShowRoutes)
						}
					} label: {
						Text("Visibility")
							.font(.title3)
					}
					DisclosureGroup {
						if self.mapState.pinCoordinate == nil {
							Button("Drop Pin") {
								self.mapState.pinCoordinate = MapUtilities.Constants.originCoordinate
							}
						} else {
							VStack(alignment: .leading) {
								Text("Coordinate")
									.font(.headline)
								HStack {
									TextField("Latitude", value: self.mapState.pinLatitude, format: .number, prompt: Text("Latitude"))
									TextField("Longitude", value: self.mapState.pinLongitude, format: .number, prompt: Text("Longitude"))
								}
							}
								.padding(.bottom)
							Button("Remove Pin") {
								self.mapState.pinCoordinate = nil
							}
						}
					} label: {
						Text("Pin")
							.font(.title3)
					}
					Spacer()
				}
					.padding()
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
						withAnimation {
							self.doShowInspector.toggle()
						}
					} label: {
						Label("Toggle Inspector", systemImage: "sidebar.right")
					}

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
						await self.refreshBuses()
					}
				}
			}
			.onReceive(self.timer) { (_) in
				Task {
					await self.refreshBuses()
				}
			}
	}
	
	@MainActor  private func refreshBuses() async {
		self.mapState.buses = await [Bus].download()
		self.isRefreshing = false
	}
	
}

struct ContentViewPreviews: PreviewProvider {
	
	static var previews: some View {
		ContentView()
			.environmentObject(MapState.shared)
	}
	
}
