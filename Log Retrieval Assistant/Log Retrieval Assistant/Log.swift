//
//  Log.swift
//  Log Retrieval Assistant
//
//  Created by Gabriel Jacoby-Cooper on 11/6/22.
//

import KeyManagement

struct Log: Decodable, Hashable, Identifiable, SignableForDeletion {
	
	typealias DeletionRequest = SimpleDeletionRequest
	
	enum ClientPlatform: String, Decodable {
		
		case ios, macos, android, web
		
		var name: String {
			get {
				switch self {
				case .ios:
					return "iOS"
				case .macos:
					return "macOS"
				case .android:
					return "Android"
				case .web:
					return "Web"
				}
			}
		}
		
	}
	
	let id: UUID
	
	let content: String
	
	let clientPlatform: ClientPlatform
	
	let date: Date
	
	func writeToDisk() throws -> URL {
		let url = FileManager.default.temporaryDirectory.appending(component: "\(self.id.uuidString).log")
		try self.content.write(to: url, atomically: false, encoding: .utf8)
		return url
	}
	
}
