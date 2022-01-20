//
//  Route.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import SwiftUI
import MapKit

class Route: NSObject, Collection, Decodable, Identifiable, MKOverlay {
	
	enum CodingKeys: String, CodingKey {
		
		case coordinates
		
	}
	
	let startIndex = 0
	
	private(set) lazy var endIndex = self.mapPoints.count - 1
	
	let mapPoints: [MKMapPoint]
	
	var last: MKMapPoint? {
		get {
			return self.mapPoints.last
		}
	}
	
	var polylineRenderer: MKPolylineRenderer {
		get {
			let polyline = self.mapPoints.withUnsafeBufferPointer { (mapPointsPointer) -> MKPolyline in
				return MKPolyline(points: mapPointsPointer.baseAddress!, count: mapPointsPointer.count)
			}
			let polylineRenderer = MKPolylineRenderer(polyline: polyline)
			polylineRenderer.strokeColor = NSColor(.blue)
				.withAlphaComponent(0.5)
			polylineRenderer.lineWidth = 3
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
	
	let name = "Default Route"
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.mapPoints = try container.decode([Coordinate].self, forKey: .coordinates)
			.map { (coordinate) in
				return MKMapPoint(coordinate)
			}
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
	
	func checkIfValid(coordinate: CLLocationCoordinate2D, centerLatitude: CLLocationDegrees, threshold: Double) -> Bool {
		return self.mapPoints
			.enumerated()
			.compactMap { (offset, mapPoint2) -> Double? in
				let mapPoint1: MKMapPoint
				if offset == 0 {
					mapPoint1 = self.mapPoints.last!
				} else {
					mapPoint1 = self.mapPoints[offset - 1]
				}
				let (x0, y0) = coordinate.convertedForFlatGrid(centeredAtLatitude: centerLatitude)
				let (x1, y1) = mapPoint1.coordinate.convertedForFlatGrid(centeredAtLatitude: centerLatitude)
				let (x2, y2) = mapPoint2.coordinate.convertedForFlatGrid(centeredAtLatitude: centerLatitude)
				let a = y1 - y2
				let b = x2 - x1
				let c = x1 * y2 - x2 * y1
				let distance = abs(a * x0 + b * y0 + c) / sqrt(pow(a, 2) + pow(b, 2))
				return distance.isNaN ? nil : distance
			}
			.reduce(into: false) { (partialResult, distance) in
				if distance < threshold {
					partialResult = true
				}
			}
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
