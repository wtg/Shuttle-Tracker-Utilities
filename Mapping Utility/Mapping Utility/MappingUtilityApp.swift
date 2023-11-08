//
//  MappingUtilityApp.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import MapKit
import ServerSelection
import SwiftUI

@main
struct MappingUtilityApp: App {
	
	static let refreshSequence = RefreshSequence(interval: .seconds(5))
	
	private static let serverSelectionAppGroupID = "SYBLH277NF.com.gerzer.shuttletracker.serverselection"
	
	@State
	private var mapCameraPosition: MapCameraPosition = .automatic
	
	var body: some Scene {
		WindowGroup {
			ContentView(mapCameraPosition: self.$mapCameraPosition)
				.environment(MapState.shared)
				.serverSelection(appGroupID: Self.serverSelectionAppGroupID)
		}
			.commands {
				CommandGroup(before: .sidebar) {
					Button("Re-Center Map") {
						Task {
							await MapState.shared.recenter(position: self.$mapCameraPosition)
						}
					}
						.keyboardShortcut(KeyEquivalent("C"), modifiers: [.command, .shift])
					Button("Refresh") {
						Task {
							await Self.refreshSequence.trigger()
						}
					}
						.keyboardShortcut(KeyEquivalent("R"), modifiers: .command)
					Divider()
				}
				CommandGroup(replacing: .newItem) { }
			}
	}
	
}
