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
		VStack {
			HStack {
				Text("Inspector")
					.font(.title)
				Spacer()
			}
			ScrollView {
				VisibilityInspectorSection()
				PinInspectorSection()
				AlgorithmsInspectorSection()
				Spacer()
			}
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
