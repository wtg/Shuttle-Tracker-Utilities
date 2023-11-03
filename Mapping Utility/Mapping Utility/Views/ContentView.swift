//
//  ContentView.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import MapKit
import OSLog
import ServerSelection
import SwiftUI

struct ContentView: View {
	
	enum SheetType: Identifiable {
		
		case serverSelection
		
		var id: Self {
			get {
				return self
			}
		}
		
	}
	
	private static let logger = Logger(subsystem: "com.gerzer.shuttletracker.mappingutility", category: "ContentView")
	
	@State
	private var sheetType: SheetType?
	
	@State
	private var isRefreshing = false
	
	@State
	private var doShowInspector = true
	
	@Binding
	private var mapCameraPosition: MapCameraPosition
	
	@Environment(MapState.self)
	private var mapState
	
	var body: some View {
		HSplitView {
			MapReader { (mapProxy) in
				Map(position: self.$mapCameraPosition) {
					if self.mapState.doShowBuses {
						ForEach(self.mapState.buses) { (bus) in
							Marker(
								bus.title,
								systemImage: "bus",
								coordinate: bus.location.coordinate.convertedForCoreLocation()
							)
							.tint(bus.tintColor)
							.mapOverlayLevel(level: .aboveLabels)
						}
					}
					if self.mapState.doShowStops {
						ForEach(self.mapState.stops) { (stop) in
							Annotation(
								stop.title,
								coordinate: stop.coordinate
							) {
								Circle()
									.size(width: 12, height: 12)
									.fill(.white)
									.stroke(.black, lineWidth: 3)
							}
						}
					}
					if self.mapState.doShowRoutes {
						ForEach(self.mapState.routes) { (route) in
							MapPolyline(points: route.mapPoints, contourStyle: .geodesic)
								.stroke(route.color, lineWidth: 5)
							
						}
					}
					if let coordinate = self.mapState.pinCoordinate {
						Marker(coordinate: coordinate) { }
					}
				}
					.mapStyle(.standard(emphasis: .muted, pointsOfInterest: .excludingAll))
					.frame(minWidth: 400, idealWidth: 600)
					.onTapGesture(count: 2, coordinateSpace: .local) { (point) in
						let adjustedPoint = CGPoint(x: point.x, y: point.y + 100)
						self.mapState.pinCoordinate = mapProxy.convert(adjustedPoint, from: .local)
					}
			}
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
							Task {
								await MappingUtilityApp.refreshSequence.trigger()
							}
						} label: {
							Label("Refresh", systemImage: "arrow.clockwise")
						}
					}
				}
				ToolbarItem {
					Button {
						Task {
							await self.mapState.recenter(position: self.$mapCameraPosition)
						}
					} label: {
						Label("Re-Center Map", systemImage: "location.viewfinder")
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
					await self.mapState.refreshAll()
				}
			} content: { (sheetType) in
				switch sheetType {
				case .serverSelection:
					let baseURL = Binding {
						return API.baseURL
					} set: { (newValue) in
						API.baseURL = newValue
					}
					ServerSelectionSheet(baseURL: baseURL, item: self.$sheetType)
				}
			}
			.task {
				await self.mapState.refreshAll()
				await self.mapState.recenter(position: self.$mapCameraPosition)
				for await refreshType in MappingUtilityApp.refreshSequence {
					switch refreshType {
					case .manual:
						withAnimation {
							self.isRefreshing = true
						}
						do {
							try await Task.sleep(for: .milliseconds(500))
						} catch {
							Self.logger.log(level: .error, "[\(#fileID):\(#line) \(#function, privacy: .public)] Task sleep failed: \(error, privacy: .public)")
						}
						await self.mapState.refreshAll()
						withAnimation {
							self.isRefreshing = false
						}
					case .automatic:
						// For automatic refresh operations, we only refresh the buses.
						await self.mapState.refreshBuses()
					}
				}
			}
			.onAppear {
				NSWindow.allowsAutomaticWindowTabbing = false
			}
	}
	
	init(mapCameraPosition: Binding<MapCameraPosition>) {
		self._mapCameraPosition = mapCameraPosition
	}
	
}

#Preview {
	ContentView(mapCameraPosition: .constant(.automatic))
		.environment(MapState.shared)
}
