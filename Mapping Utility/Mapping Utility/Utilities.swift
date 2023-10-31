//
//  Utilities.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import MapKit
import SwiftUI

enum MapConstants {
	
	static let originCoordinate = CLLocationCoordinate2D(latitude: 42.735, longitude: -73.688)
	
	static let mapRect = MKMapRect(
		origin: MKMapPoint(MapConstants.originCoordinate),
		size: MKMapSize(
			width: 10000,
			height: 10000
		)
	)
	
	static let defaultCameraPosition: MapCameraPosition = .rect(MapConstants.mapRect)
	
	static let mapRectInsets = NSEdgeInsets(top: 100, left: 20, bottom: 20, right: 20)
	
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
	
	public static func == (lhs: MKMapPoint, rhs: MKMapPoint) -> Bool {
		return lhs.coordinate == rhs.coordinate
	}
	
}

extension Notification.Name {
	
	static let refreshBuses = Notification.Name("RefreshBuses")
	
}

extension JSONEncoder {
	
	convenience init(
		dateEncodingStrategy: DateEncodingStrategy = .deferredToDate,
		dataEncodingStrategy: DataEncodingStrategy = .base64,
		nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy = .throw
	) {
		self.init()
		self.keyEncodingStrategy = keyEncodingStrategy
		self.dateEncodingStrategy = dateEncodingStrategy
		self.dataEncodingStrategy = dataEncodingStrategy
		self.nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy
	}
	
}

extension JSONDecoder {
	
	convenience init(
		dateDecodingStrategy: DateDecodingStrategy = .deferredToDate,
		dataDecodingStrategy: DataDecodingStrategy = .base64,
		nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw
	) {
		self.init()
		self.keyDecodingStrategy = keyDecodingStrategy
		self.dateDecodingStrategy = dateDecodingStrategy
		self.dataDecodingStrategy = dataDecodingStrategy
		self.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
	}
	
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
