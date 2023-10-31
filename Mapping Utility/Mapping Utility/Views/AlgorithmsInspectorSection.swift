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
			VStack(alignment: .leading) {
				Text("Is on Route")
					.font(.headline)
				Form {
					// FIXME: This code currently fails to build due to a linker error that seems to be a symptom of a bug in Swift itself.
//					@Bindable
//					var mapState = self.mapState
//					
//					TextField("Threshold", value: $mapState.thresholdForCheckingIsOnRoute, format: .number)
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
		}
	}
	
}

#Preview {
	AlgorithmsInspectorSection()
		.environment(MapState.shared)
}
