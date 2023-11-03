//
//  InspectorSection.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/19/22.
//

import SwiftUI

struct InspectorSection<Content>: View where Content: View {
	
	@Environment(MapState.self)
	private var mapState
	
	let title: String
	
	let content: Content
	
	var body: some View {
		DisclosureGroup(self.title) {
			self.content
		}
	}
	
	init(_ title: some StringProtocol, @ViewBuilder content: () -> Content) {
		self.title = String(title)
		self.content = content()
	}
	
}
