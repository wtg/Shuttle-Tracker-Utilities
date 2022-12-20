//
//  Log.swift
//  Log Retrieval Assistant
//
//  Created by Gabriel Jacoby-Cooper on 11/6/22.
//

import HTTPStatus
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

extension Set where Element == Log {
	
	mutating func delete(baseURL: URL, keyPair: KeyPair) async throws {
		try await withThrowingTaskGroup(of: Log.self) { (taskGroup) in
			for log in self {
				_ = taskGroup.addTaskUnlessCancelled {
					let url = baseURL.appending(components: "logs", log.id.uuidString)
					var request = URLRequest(url: url)
					request.httpMethod = "DELETE"
					request.setValue("application/json", forHTTPHeaderField: "Content-Type")
					let deletionRequest = try log.deletionRequest(signedUsing: keyPair)
					let data = try JSONEncoder().encode(deletionRequest)
					let (_, response) = try await URLSession.shared.upload(for: request, from: data)
					guard let httpResponse = response as? HTTPURLResponse, let statusCode = HTTPStatusCodes.statusCode(httpResponse.statusCode) else {
						throw OperationError.malformedResponse
					}
					switch statusCode {
					case HTTPStatusCodes.Success.ok:
						return log
					case HTTPStatusCodes.ClientError.unauthorized:
						throw OperationError.keyNotVerified
					case HTTPStatusCodes.ClientError.forbidden:
						throw OperationError.keyRejected
					case let statusCodeError as any Error:
						throw statusCodeError
					default:
						throw OperationError.unknown
					}
				}
			}
			for try await deletedLog in taskGroup {
				self.remove(deletedLog)
			}
		}
	}
	
}
