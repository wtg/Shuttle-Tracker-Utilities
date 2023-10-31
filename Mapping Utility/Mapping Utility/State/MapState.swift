//
//  MapState.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import MapKit
import SwiftUI

@Observable
@MainActor
final class MapState {
	
	static let shared = MapState()
	
	private(set) var buses = [Bus]()
	
	private(set) var stops = [Stop]()
	
	private(set) var routes = [Route]()
	
	var doShowBuses = false
	
	var doShowStops = true
	
	var doShowRoutes = true
	
	var pinCoordinate: CLLocationCoordinate2D?
	
	var thresholdForCheckingIsOnRoute: Double = 5
	
	@ObservationIgnored
	lazy var pinLatitude = Binding {
		return self.pinCoordinate?.latitude ?? MapConstants.originCoordinate.latitude
	} set: { (newValue, transaction) in
		self.pinCoordinate?.latitude = newValue
	}
	
	@ObservationIgnored
	lazy var pinLongitude = Binding {
		return self.pinCoordinate?.longitude ?? MapConstants.originCoordinate.longitude
	} set: { (newValue) in
		self.pinCoordinate?.longitude = newValue
	}
	
	private init() { }
	
	func refreshBuses() async {
		self.buses = await [Bus].download()
	}
	
	func refreshAll() async {
		async let buses = [Bus].download()
		async let stops = [Stop].download()
		async let routes = [Route].download()
		self.buses = await buses
		self.stops = await stops
		self.routes = await routes
	}
	
	func recenter(position: Binding<MapCameraPosition>) async {
		let dx = (MapConstants.mapRectInsets.left + MapConstants.mapRectInsets.right) * -15
		let dy = (MapConstants.mapRectInsets.top + MapConstants.mapRectInsets.bottom) * -15
		let mapRect = self.routes.boundingMapRect.insetBy(dx: dx, dy: dy)
		withAnimation {
			position.wrappedValue = .rect(mapRect)
		}
	}
	
}
