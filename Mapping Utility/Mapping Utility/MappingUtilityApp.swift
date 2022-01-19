//
//  MappingUtilityApp.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import SwiftUI

@main struct MappingUtilityApp: App {
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(MapState.shared)
		}
	}
	
}
