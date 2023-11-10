//
//  Server.swift
//  ServerSelection
//
//  Created by Gabriel Jacoby-Cooper on 10/31/23.
//

import SwiftData
import SwiftUI

@Model
public final class Server {
	
	public static let production = Server(
		name: "Production",
		baseURL: URL(string: "https://shuttletracker.app")!,
		isEditable: false
	)
	
	public static let staging = Server(
		name: "Staging",
		baseURL: URL(string: "https://staging.shuttletracker.app")!,
		isEditable: false
	)
	
	static let defaultServers: [Server] = [.production, .staging]
	
	public private(set) var name: String
	
	public private(set) var baseURL: URL
	
	let isEditable: Bool
	
	convenience init(name: String, baseURL: URL) {
		self.init(name: name, baseURL: baseURL, isEditable: true)
	}
	
	private init(name: String, baseURL: URL, isEditable: Bool) {
		self.name = name
		self.baseURL = baseURL
		self.isEditable = isEditable
	}
	
}

extension Sequence where Element == Server {
	
	var allAreNonEditable: Bool {
		get {
			return self.allSatisfy { (server) in
				return !server.isEditable
			}
		}
	}
	
	func hasServer(for baseURL: URL) -> Bool {
		return self.contains { (server) in
			return server.baseURL == baseURL
		}
	}
	
}
