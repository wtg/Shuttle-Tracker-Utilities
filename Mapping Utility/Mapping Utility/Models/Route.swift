//
//  Route.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import MapKit
import SwiftUI
import Turf

class Route: NSObject, Collection, Decodable, Identifiable, MKOverlay {
	
	enum CodingKeys: String, CodingKey {
		
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
	
	var polylineRenderer: MKPolylineRenderer {
		get {
			let polyline = self.mapPoints.withUnsafeBufferPointer { (mapPointsPointer) -> MKPolyline in
				return MKPolyline(points: mapPointsPointer.baseAddress!, count: mapPointsPointer.count)
			}
			let polylineRenderer = MKPolylineRenderer(polyline: polyline)
			polylineRenderer.strokeColor = NSColor(self.color)
				.withAlphaComponent(0.7)
			polylineRenderer.lineWidth = 5
			return polylineRenderer
		}
	}
	
	var coordinate: CLLocationCoordinate2D {
		get {
			return MapUtilities.Constants.originCoordinate
		}
	}
	
	var boundingMapRect: MKMapRect {
		get {
			let minX = self.reduce(into: self.first!.x) { (x, mapPoint) in
				if mapPoint.x < x {
					x = mapPoint.x
				}
			}
			let maxX = self.reduce(into: self.first!.x) { (x, mapPoint) in
				if mapPoint.x > x {
					x = mapPoint.x
				}
			}
			let minY = self.reduce(into: self.first!.y) { (y, mapPoint) in
				if mapPoint.y < y {
					y = mapPoint.y
				}
			}
			let maxY = self.reduce(into: self.first!.x) { (y, mapPoint) in
				if mapPoint.y > y {
					y = mapPoint.y
				}
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
	
	static func == (_ left: Route, _ right: Route) -> Bool {
		return left.mapPoints == right.mapPoints
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
	
}

extension Array where Element == Route {
	
	static func download() async -> [Route] {
		return await withCheckedContinuation { continuation in
			API.provider.request(.readRoutes) { (result) in
				let routes = try? result
					.get()
					.map([Route].self)
				continuation.resume(returning: routes ?? [])
			}
		}
	}
	
}
