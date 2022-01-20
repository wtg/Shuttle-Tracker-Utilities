//
//  InspectorSection.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/19/22.
//

import SwiftUI

struct InspectorSection<Content>: View where Content: View {
	
	@EnvironmentObject private var mapState: MapState
	
	let title: String
	
	let content: Content
	
	var body: some View {
		DisclosureGroup {
			self.content
		} label: {
			Text(self.title)
				.font(.title3)
		}
	}
	
	init<S>(_ title: S, @ViewBuilder content: () -> Content) where S: StringProtocol {
		self.title = String(title)
		self.content = content()
	}
	
}
