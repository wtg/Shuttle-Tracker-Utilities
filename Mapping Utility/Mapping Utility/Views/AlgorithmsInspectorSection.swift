//
//  AlgorithmsInspectorSection.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/19/22.
//

import SwiftUI

struct AlgorithmsInspectorSection: View {
	
	@Environment(MapState.self)
	private var mapState
	
	var body: some View {
		InspectorSection("Algorithms") {
			HStack {
				VStack(alignment: .leading) {
					Text("Is on Route")
						.font(.headline)
					Form {
						TextField(
							"Threshold",
							value: Bindable(self.mapState).thresholdForCheckingIsOnRoute,
							format: .number
						)
					}
					if let pinCoordinate = self.mapState.pinCoordinate {
						ForEach(self.mapState.routes) { (route) in
							if route.checkIfValid(coordinate: pinCoordinate, threshold: self.mapState.thresholdForCheckingIsOnRoute) {
								Text("Is on route “\(route.name)”")
							}
							else {
								Text("Is not on route “\(route.name)”")
									.foregroundColor(.secondary)
							}
						}
					} else {
						Text("No Pin on Map")
							.foregroundColor(.secondary)
					}
				}
				Spacer()
			}
		}
	}
	
}

#Preview {
	AlgorithmsInspectorSection()
		.environment(MapState.shared)
}
