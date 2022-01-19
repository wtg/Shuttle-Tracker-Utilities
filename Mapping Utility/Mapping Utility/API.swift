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
	
	case readRoutes
	
	case readStops
	
	static let provider = MoyaProvider<API>()
	
	static let lastVersion = 2
	
	var baseURL: URL {
		get {
			return URL(string: "https://shuttletracker.app")!
		}
	}
	
	var path: String {
		get {
			switch self {
			case .readBuses:
				return "/buses"
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
			}
		}
	}
	
	var task: Task {
		get {
			switch self {
			case .readBuses, .readRoutes, .readStops:
				return .requestPlain
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
