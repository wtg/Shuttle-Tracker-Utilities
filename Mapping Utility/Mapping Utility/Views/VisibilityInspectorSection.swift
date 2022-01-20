//
//  VisibilityInspectorSection.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/19/22.
//

import SwiftUI

struct VisibilityInspectorSection: View {
	
	@EnvironmentObject private var mapState: MapState
	
	var body: some View {
		InspectorSection("Visibility") {
			Form {
				Toggle("Show buses", isOn: self.$mapState.doShowBuses)
				Toggle("Show stops", isOn: self.$mapState.doShowStops)
				Toggle("Show routes", isOn: self.$mapState.doShowRoutes)
			}
		}
	}
	
}

struct VisibilityInspectorSectionPreviews: PreviewProvider {
	
	static var previews: some View {
		VisibilityInspectorSection()
			.environmentObject(MapState.shared)
	}
	
}
