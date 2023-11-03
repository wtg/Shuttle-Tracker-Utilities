//
//  Server.swift
//  ServerSelection
//
//  Created by Gabriel Jacoby-Cooper on 10/31/23.
//

import SwiftData
import SwiftUI

@Model
public final class Server: Identifiable {
	
	public static let production = try! Server(
		id: UUID(uuidString: "1BBA964A-B05D-4E77-95BB-5301C1F2C34C")!,
		name: "Production",
		baseURL: URL(string: "https://shuttletracker.app")!
	)
	
	public static let staging = try! Server(
		id: UUID(uuidString: "C99A231C-ED95-43C6-B284-21586CA63264")!,
		name: "Staging",
		baseURL: URL(string: "https://staging.shuttletracker.app")!
	)
	
	private static let container = try! ModelContainer(for: Server.self, configurations: ModelConfiguration(for: Server.self))
	
	public let id: UUID
	
	public private(set) var name: String
	
	public private(set) var baseURL: URL
	
	let isEditable: Bool
	
	init(name: String, baseURL: URL) {
		self.id = UUID()
		self.name = name
		self.baseURL = baseURL
		self.isEditable = true
	}
	
	private init(id: UUID, name: String, baseURL: URL) throws {
		let configuration = ModelConfiguration(for: Self.self)
		let container = try ModelContainer(for: Self.self, configurations: configuration)
		let context = ModelContext(container)
		self.id = id
		self.name = name
		self.baseURL = baseURL
		self.isEditable = false
		context.insert(self)
	}
	
}
