//
//  PinInspectorSection.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/19/22.
//

import SwiftUI

struct PinInspectorSection: View {
	
	@EnvironmentObject private var mapState: MapState
	
	var body: some View {
		InspectorSection("Pin") {
			if self.mapState.pinCoordinate == nil {
				Button("Drop Pin") {
					self.mapState.pinCoordinate = MapUtilities.Constants.originCoordinate
				}
			} else {
				VStack(alignment: .leading) {
					Text("Coordinate")
						.font(.headline)
					Form {
						TextField("Latitude", value: self.mapState.pinLatitude, format: .number)
						TextField("Longitude", value: self.mapState.pinLongitude, format: .number)
					}
				}
				Divider()
				Button("Remove Pin") {
					self.mapState.pinCoordinate = nil
				}
			}
		}
	}
	
}

struct PinInspectorSectionPreviews: PreviewProvider {
	
	static var previews: some View {
		PinInspectorSection()
			.environmentObject(MapState.shared)
	}
	
}
