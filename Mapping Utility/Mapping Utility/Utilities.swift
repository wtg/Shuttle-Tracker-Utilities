//
//  Utilities.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import MapKit

protocol IdentifiableByRawValue: Identifiable, RawRepresentable { }

extension IdentifiableByRawValue where RawValue: Hashable {
	
	var id: RawValue {
		get {
			return self.rawValue
		}
	}
	
}

enum MapUtilities {
	
	enum Constants {
		
		static let originCoordinate = CLLocationCoordinate2D(latitude: 42.735, longitude: -73.688)
		
	}
	
	static let mapRect = MKMapRect(
		origin: MKMapPoint(Constants.originCoordinate),
		size: MKMapSize(
			width: 10000,
			height: 10000
		)
	)
	
}

extension CLLocationCoordinate2D {
	
	func convertedToCoordinate() -> Coordinate {
		return Coordinate(latitude: self.latitude, longitude: self.longitude)
	}
	
	func convertedForFlatGrid(centeredAtLatitude centerLatitude: Double) -> (x: Double, y: Double) {
		let r = 6.3781E6
		let x = r * self.longitude * cos(centerLatitude)
		let y = r * self.latitude
		return (x: x, y: y)
	}
	
}

extension MKMapPoint: Equatable {
	
	init(_ coordinate: Coordinate) {
		self.init(coordinate.convertedForCoreLocation())
	}
	
	public static func == (_ left: MKMapPoint, _ right: MKMapPoint) -> Bool {
		return left.coordinate == right.coordinate
	}
	
}

extension Notification.Name {
	
	static let refreshBuses = Notification.Name("RefreshBuses")
	
}

extension NSImage {
	
	func withTintColor(_ color: NSColor) -> NSImage {
		let image = self.copy() as! NSImage
		image.lockFocus()
		color.set()
		let imageRect = NSRect(origin: .zero, size: image.size)
		imageRect.fill(using: .sourceAtop)
		image.unlockFocus()
		return image
	}
	
}
