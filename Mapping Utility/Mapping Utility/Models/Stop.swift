//
//  Stop.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import MapKit

final class Stop: Decodable, Identifiable {
	
	enum CodingKeys: String, CodingKey {
		
		case name, coordinate
		
	}
	
	let name: String
	
	let coordinate: CLLocationCoordinate2D
	
	var location: CLLocation {
		get {
			return CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
		}
	}
	
	var title: String {
		get {
			return self.name
		}
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decode(String.self, forKey: .name)
		self.coordinate = try container.decode(Coordinate.self, forKey: .coordinate).convertedForCoreLocation()
	}
	
}

extension Array where Element == Stop {
	
	static func download() async -> Self {
		return (try? await API.readStops.perform(as: Self.self)) ?? []
	}
	
}
