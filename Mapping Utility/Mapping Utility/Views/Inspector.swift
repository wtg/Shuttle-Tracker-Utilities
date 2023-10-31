//
//  Inspector.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/19/22.
//

import SwiftUI

struct Inspector: View {
	
	@Environment(MapState.self)
	private var mapState
	
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

#Preview {
	Inspector()
		.environment(MapState.shared)
}
