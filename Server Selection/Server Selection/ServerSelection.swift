//
//  ServerSelection.swift
//  ServerSelection
//
//  Created by Gabriel Jacoby-Cooper on 11/5/23.
//

import SwiftData
import SwiftUI

fileprivate struct ServerSelection: ViewModifier {
	
	private let modelContext: ModelContext
	
	func body(content: Content) -> some View {
		content
			.modelContext(self.modelContext)
	}
	
	init() throws {
		self.modelContext = ModelContext(
			try ModelContainer(
				for: Server.self,
				configurations: ModelConfiguration()
			)
		)
		self.modelContext.autosaveEnabled = false
	}
	
	init(appGroupID: String) throws {
		self.modelContext = ModelContext(
			try ModelContainer(
				for: Server.self,
				configurations: ModelConfiguration(
					groupContainer: .identifier(appGroupID)
				)
			)
		)
		self.modelContext.autosaveEnabled = false
	}
	
}

extension View {
	
	public func serverSelection() -> some View {
		return self
			.modifier(try! ServerSelection())
	}
	
	public func serverSelection(appGroupID: String) -> some View {
		return self
			.modifier(try! ServerSelection(appGroupID: appGroupID))
	}
	
}
