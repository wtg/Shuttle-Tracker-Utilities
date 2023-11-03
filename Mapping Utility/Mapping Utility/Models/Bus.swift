//
//  Bus.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import SwiftUI
import MapKit

final class Bus: Codable, Identifiable {
	
	struct Location: Codable {
		
		enum LocationType: String, Codable {
			
			case system, user, network
			
		}
		
		let id: UUID
		
		let date: Date
		
		let coordinate: Coordinate
		
		let type: LocationType
		
		func convertForCoreLocation() -> CLLocation {
			return CLLocation(
				coordinate: self.coordinate.convertedForCoreLocation(),
				altitude: .nan,
				horizontalAccuracy: .nan,
				verticalAccuracy: .nan,
				timestamp: self.date
			)
		}
		
	}
	
	let id: Int
	
	let routeID: UUID?
	
	private(set) var location: Location
	
	@MainActor
	var title: String {
		get {
			return "Bus \(self.id)"
		}
	}
	
	@MainActor
	var subtitle: String {
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
	
	@MainActor
	var tintColor: Color {
		get {
			switch self.location.type {
			case .system:
				return .red
			case .user, .network:
				return .green
			}
		}
	}
	
	init(id: Int, routeID: UUID, location: Location) {
		self.id = id
		self.routeID = routeID
		self.location = location
	}
	
	static func == (lhs: Bus, rhs: Bus) -> Bool {
		return lhs.id == rhs.id
	}
	
}

extension Array where Element == Bus {
	
	static func download() async -> Self {
		return (try? await API.readBuses.perform(as: Self.self)) ?? []
	}
	
}
