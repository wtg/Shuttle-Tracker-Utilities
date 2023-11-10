//
//  API.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import Foundation
import HTTPStatus
import Moya
import ServerSelection

typealias HTTPMethod = Moya.Method

typealias HTTPTask = Moya.Task

enum API: TargetType {
	
	case readBuses
	
	case updateBus(id: Int, location: Bus.Location)
	
	case readRoutes
	
	case readStops
	
	static let provider = MoyaProvider<API>()
	
	static let lastVersion = 2
	
	static var server: Server = .staging
	
	var baseURL: URL {
		get {
			return Self.server.baseURL
		}
	}
	
	var path: String {
		get {
			switch self {
			case .readBuses:
				return "/buses"
			case .updateBus(let id, _):
				return "/buses/\(id)"
			case .readRoutes:
				return "/routes"
			case .readStops:
				return "/stops"
			}
		}
	}
	
	public var method: HTTPMethod {
		get {
			switch self {
			case .readBuses, .readRoutes, .readStops:
				return .get
			case .updateBus:
				return .patch
			}
		}
	}
	
	var task: HTTPTask {
		get {
			let encoder = JSONEncoder(dateEncodingStrategy: .iso8601)
			switch self {
			case .readBuses, .readRoutes, .readStops:
				return .requestPlain
			case .updateBus(_, let location):
				return .requestCustomJSONEncodable(location, encoder: encoder)
			}
		}
	}
	
	var headers: [String: String]? {
		get {
			return [:]
		}
	}
	
	@discardableResult
	func perform() async throws -> Data {
		let request = try API.provider.endpoint(self).urlRequest()
		let (data, response) = try await URLSession.shared.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else {
			throw APIError.invalidResponse
		}
		guard let statusCode = HTTPStatusCodes.statusCode(httpResponse.statusCode) else {
			throw APIError.invalidStatusCode
		}
		if let error = statusCode as? any Error {
			throw error
		} else {
			return data
		}
	}
	
	func perform<ResponseType>(
		decodingJSONWith decoder: JSONDecoder = JSONDecoder(dateDecodingStrategy: .iso8601),
		as responseType: ResponseType.Type,
		onMainActor: Bool = false
	) async throws -> ResponseType where ResponseType: Sendable & Decodable {
		let data = try await self.perform()
		if onMainActor {
			return try await MainActor.run {
				return try decoder.decode(responseType, from: data)
			}
		} else {
			return try decoder.decode(responseType, from: data)
		}
	}
	
}

fileprivate enum APIError: LocalizedError {
	
	case invalidResponse
	
	case invalidStatusCode
	
	var errorDescription: String? {
		get {
			switch self {
			case .invalidResponse:
				return "The server returned an invalid response."
			case .invalidStatusCode:
				return "The server returned an invalid HTTP status code."
			}
		}
	}
	
}
