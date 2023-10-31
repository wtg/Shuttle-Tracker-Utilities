//
//  VisibilityInspectorSection.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/19/22.
//

import SwiftUI

struct VisibilityInspectorSection: View {
	
	@Environment(MapState.self)
	private var mapState
	
	var body: some View {
		InspectorSection("Visibility") {
			Form {
				// FIXME: This code currently fails to build due to a linker error that seems to be a symptom of a bug in Swift itself.
//				@Bindable
//				var mapState = self.mapState
//				
//				Toggle("Show buses", isOn: $mapState.doShowBuses)
//				Toggle("Show stops", isOn: $mapState.doShowStops)
//				Toggle("Show routes", isOn: $mapState.doShowRoutes)
			}
		}
	}
	
}

#Preview {
	VisibilityInspectorSection()
		.environment(MapState.shared)
}
