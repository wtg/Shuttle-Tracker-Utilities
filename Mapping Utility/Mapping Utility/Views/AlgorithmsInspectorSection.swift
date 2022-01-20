//
//  AlgorithmsInspectorSection.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/19/22.
//

import SwiftUI

struct AlgorithmsInspectorSection: View {
	
	@EnvironmentObject private var mapState: MapState
	
	var body: some View {
		InspectorSection("Algorithms") {
			VStack(alignment: .leading) {
				Text("Is on Route")
					.font(.headline)
				Form {
					TextField("Center Latitude", value: self.$mapState.centerLatitudeForCheckingIfOnRoute, format: .number)
					TextField("Threshold", value: self.$mapState.thresholdForCheckingIfOnRoute, format: .number)
				}
				if let pinCoordinate = self.mapState.pinCoordinate {
					ForEach(self.mapState.routes) { (route) in
						if route.checkIfValid(coordinate: pinCoordinate, centerLatitude: self.mapState.centerLatitudeForCheckingIfOnRoute, threshold: self.mapState.thresholdForCheckingIfOnRoute) {
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

struct AlgorithmsInspectorSectionPreviews: PreviewProvider {
	
	static var previews: some View {
		AlgorithmsInspectorSection()
			.environmentObject(MapState.shared)
	}
	
}
