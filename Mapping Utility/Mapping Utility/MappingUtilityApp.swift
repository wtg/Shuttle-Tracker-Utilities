//
//  MappingUtilityApp.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import MapKit
import SwiftUI

@main
struct MappingUtilityApp: App {
	
	static let refreshSequence = RefreshSequence(interval: .seconds(5))
	
	@State
	private var mapCameraPosition: MapCameraPosition = .automatic
	
	var body: some Scene {
		WindowGroup {
			ContentView(mapCameraPosition: self.$mapCameraPosition)
				.environment(MapState.shared)
		}
	}
	
}
