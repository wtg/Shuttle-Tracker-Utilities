//
//  Coordinate.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import CoreLocation

struct Coordinate: Codable {
	
	let latitude: Double
	
	let longitude: Double
	
	func convertedForCoreLocation() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
	}
	
}
