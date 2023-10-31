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
				Toggle(
					"Show buses",
					isOn: Bindable(self.mapState).doShowBuses
				)
				Toggle(
					"Show stops",
					isOn: Bindable(self.mapState).doShowStops
				)
				Toggle(
					"Show routes",
					isOn: Bindable(self.mapState).doShowRoutes
				)
			}
		}
	}
	
}

#Preview {
	VisibilityInspectorSection()
		.environment(MapState.shared)
}
