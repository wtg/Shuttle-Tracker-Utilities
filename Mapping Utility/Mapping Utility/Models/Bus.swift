//
//  Bus.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import SwiftUI
import MapKit

class Bus: NSObject, Codable, CustomAnnotation {
	
	struct Location: Codable {
		
		enum LocationType: String, Codable {
			
			case system = "system"
			
			case user = "user"
			
		}
		
		let id: UUID
		
		let date: Date
		
		let coordinate: Coordinate
		
		let type: LocationType
		
		func convertForCoreLocation() -> CLLocation {
			return CLLocation(coordinate: self.coordinate.convertedForCoreLocation(), altitude: .nan, horizontalAccuracy: .nan, verticalAccuracy: .nan, timestamp: self.date)
		}
		
	}
	
	let id: Int
	
	let routeID: UUID?
	
	private(set) var location: Location
	
	var coordinate: CLLocationCoordinate2D {
		get {
			return self.location.coordinate.convertedForCoreLocation()
		}
	}
	
	var title: String? {
		get {
			return "Bus \(self.id)"
		}
	}
	
	var subtitle: String? {
		get {
			let formatter = RelativeDateTimeFormatter()
			formatter.dateTimeStyle = .named
			formatter.formattingContext = self.routeID == nil ? .standalone : .middleOfSentence
			let dateTimeString = formatter.localizedString(for: self.location.date, relativeTo: Date())
			if let routeID = self.routeID {
				let routeName = MapState.shared.routes.first { (route) in
					return route.id == routeID
				}?.name ?? "unknown route"
				return "On “\(routeName)” \(dateTimeString)"
			} else {
				return dateTimeString
			}
		}
	}
	
	var annotationView: MKAnnotationView {
		get {
			let markerAnnotationView = MKMarkerAnnotationView()
			markerAnnotationView.displayPriority = .required
			markerAnnotationView.canShowCallout = true
			let colorBlindMode = UserDefaults.standard.bool(forKey: "ColorBlindMode")
			let colorBlindSymbolName: String
			switch self.location.type {
			case .system:
				markerAnnotationView.markerTintColor = colorBlindMode ? .systemPurple : .systemRed
				colorBlindSymbolName = "circle.dotted"
			case .user:
				markerAnnotationView.markerTintColor = .systemGreen
				colorBlindSymbolName = "scope"
			}
			let symbolName = colorBlindMode ? colorBlindSymbolName : "bus"
			markerAnnotationView.glyphImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
			return markerAnnotationView
		}
	}
	
	init(id: Int, routeID: UUID, location: Location) {
		self.id = id
		self.routeID = routeID
		self.location = location
	}
	
	static func == (_ left: Bus, _ right: Bus) -> Bool {
		return left.id == right.id
	}
	
}

extension Array where Element == Bus {
	
	static func download() async -> [Bus] {
		return await withCheckedContinuation { (continuation) in
			API.provider.request(.readBuses) { (result) in
				let decoder = JSONDecoder()
				decoder.dateDecodingStrategy = .iso8601
				let buses = try? result
					.get()
					.map([Bus].self, using: decoder)
					.filter { (bus) in
						return bus.location.date.timeIntervalSinceNow > -300
					}
				continuation.resume(returning: buses ?? [])
			}
		}
	}
	
}
