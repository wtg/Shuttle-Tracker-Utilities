//
//  MapState.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import SwiftUI
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
	
	@Published var centerLatitudeForCheckingIfOnRoute = MapUtilities.Constants.originCoordinate.latitude
	
	@Published var thresholdForCheckingIfOnRoute: Double = 10
	
	lazy var pinLatitude = Binding {
		return self.pinCoordinate?.latitude ?? MapUtilities.Constants.originCoordinate.latitude
	} set: { (newValue, transaction) in
		self.pinCoordinate?.latitude = newValue
	}
	
	lazy var pinLongitude = Binding {
		return self.pinCoordinate?.longitude ?? MapUtilities.Constants.originCoordinate.longitude
	} set: { (newValue) in
		self.pinCoordinate?.longitude = newValue
	}
	
	private init() { }
	
}
