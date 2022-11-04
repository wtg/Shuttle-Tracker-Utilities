//
//  API.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import Foundation
import Moya

typealias HTTPMethod = Moya.Method

enum API: TargetType {
	
	case readBuses
	
	case updateBus(id: Int, location: Bus.Location)
	
	case readRoutes
	
	case readStops
	
	static let provider = MoyaProvider<API>()
	
	static let lastVersion = 2
	
	static var baseURL = URL(string: "https://staging.shuttletracker.app")!
	
	var baseURL: URL {
		get {
			return Self.baseURL
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
	
	var task: Task {
		get {
			switch self {
			case .readBuses, .readRoutes, .readStops:
				return .requestPlain
			case .updateBus(_, let location):
				let encoder = JSONEncoder()
				encoder.dateEncodingStrategy = .iso8601
				return .requestCustomJSONEncodable(location, encoder: encoder)
			}
		}
	}
	
	var headers: [String: String]? {
		get {
			return [:]
		}
	}
	
	var sampleData: Data {
		get {
			return "{}".data(using: .utf8)!
		}
	}
	
}
