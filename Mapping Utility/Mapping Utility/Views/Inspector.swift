//
//  Inspector.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/19/22.
//

import SwiftUI

struct Inspector: View {
	
	@EnvironmentObject private var mapState: MapState
	
	var body: some View {
		ScrollView {
			InspectorSection("Visibility") {
				VStack(alignment: .leading) {
					Toggle("Show buses", isOn: self.$mapState.doShowBuses)
					Toggle("Show stops", isOn: self.$mapState.doShowStops)
					Toggle("Show routes", isOn: self.$mapState.doShowRoutes)
				}
			}
			InspectorSection("Pin") {
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
			}
			Spacer()
		}
			.padding()
	}
	
}

struct InspectorPreviews: PreviewProvider {
	
	static var previews: some View {
		Inspector()
			.environmentObject(MapState.shared)
	}
	
}
