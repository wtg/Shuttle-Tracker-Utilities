//
//  ContentView.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import MapKit
import OSLog
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
			Map(position: self.$mapCameraPosition) {
//				ForEach(self.mapState.buses) { (bus) in
//					Marker(
//						bus.title!, // MKAnnotation requires that the title property be optional, but our implementation always returns a non-nil value.
//						systemImage: bus.iconSystemName,
//						coordinate: bus.coordinate
//					)
//						.tint(bus.tintColor)
//						.mapOverlayLevel(level: .aboveLabels)
//				}
//				ForEach(self.mapState.stops) { (stop) in
//					Annotation(
//						stop.title, // MKAnnotation requires that the title property be optional, but our implementation always returns a non-nil value.
//						coordinate: stop.coordinate
//					) {
//						Circle()
//							.size(width: 12, height: 12)
//							.fill(.white)
//							.stroke(.black, lineWidth: 3)
//					}
//				}
//				ForEach(self.mapState.routes) { (route) in
//					MapPolyline(points: route.mapPoints, contourStyle: .geodesic)
//						.stroke(route.color, lineWidth: 5)
//				}
			}
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
					ServerSelectionSheet(sheetType: self.$sheetType)
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
