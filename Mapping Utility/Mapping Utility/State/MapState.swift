//
//  MapState.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import CoreLocation

class MapState: ObservableObject {
	
	static let shared = MapState()
	
	@Published var buses = [Bus]()
	
	@Published var stops = [Stop]()
	
	@Published var routes = [Route]()
	
	@Published var doShowBuses = false
	
	@Published var doShowStops = true
	
	@Published var doShowRoutes = true
	
	@Published var pinCoordinate: CLLocationCoordinate2D?
	
	private init() { }
	
}
