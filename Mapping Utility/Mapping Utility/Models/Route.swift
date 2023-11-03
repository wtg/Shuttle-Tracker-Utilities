//
//  Route.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import MapKit
import SwiftUI
import Turf

final class Route: Collection, Decodable, Identifiable {
	
	private enum CodingKeys: String, CodingKey {
		
		case id, coordinates, name, colorName
		
	}
	
	let startIndex = 0
	
	private(set) lazy var endIndex = self.mapPoints.count - 1
	
	let id: UUID
	
	let mapPoints: [MKMapPoint]
	
	var last: MKMapPoint? {
		get {
			return self.mapPoints.last
		}
	}
	
	let name: String
	
	let color: Color
	
	var coordinate: CLLocationCoordinate2D {
		get {
			return MapConstants.originCoordinate
		}
	}
	
	var boundingMapRect: MKMapRect {
		get {
			let minX = self.min { return $0.x < $1.x }?.x
			let maxX = self.max { return $0.x < $1.x }?.x
			let minY = self.min { return $0.y < $1.y }?.y
			let maxY = self.max { return $0.y < $1.y }?.y
			guard let minX, let maxX, let minY, let maxY else {
				return MKMapRect.null
			}
			return MKMapRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
		}
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.mapPoints = try container.decode([Coordinate].self, forKey: .coordinates)
			.map { (coordinate) in
				return MKMapPoint(coordinate)
			}
		self.name = try container.decode(String.self, forKey: .name)
		self.color = try container.decode(ColorName.self, forKey: .colorName).color
	}
	
	subscript(position: Int) -> MKMapPoint {
		return self.mapPoints[position]
	}
	
	func index(after oldIndex: Int) -> Int {
		return oldIndex + 1
	}
	
	func checkIfValid(coordinate testCoordinate: CLLocationCoordinate2D, threshold: Double) -> Bool {
		let routeCoordinates = self.mapPoints.map { (mapPoint) in
			return mapPoint.coordinate
		}
		let distance = LineString(routeCoordinates)
			.closestCoordinate(to: testCoordinate)!
			.coordinate
			.distance(to: testCoordinate)
		return distance < threshold
	}
	
	static func == (lhs: Route, rhs: Route) -> Bool {
		return lhs.id == rhs.id
	}
	
}

extension Array where Element == Route {
	
	var boundingMapRect: MKMapRect {
		get {
			return self.reduce(into: .null) { (partialResult, route) in
				partialResult = partialResult.union(route.boundingMapRect)
			}
		}
	}
	
	static func download() async -> Self {
		return (try? await API.readRoutes.perform(as: Self.self)) ?? []
	}
	
}
