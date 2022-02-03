//
//  MapView.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import SwiftUI
import MapKit

struct MapView: NSViewRepresentable {
	
	@EnvironmentObject private var mapState: MapState
	
	private let mapView = MKMapView(frame: .zero)
	
	private let pin = Pin(coordinate: MapUtilities.Constants.originCoordinate)
	
	func makeNSView(context: Context) -> MKMapView {
		self.mapView.delegate = context.coordinator
		self.mapView.showsUserLocation = true
		self.mapView.showsCompass = true
		self.mapView.setVisibleMapRect(MapUtilities.mapRect, animated: true)
		Task {
			self.mapState.buses = await [Bus].download()
			self.mapState.stops = await [Stop].download()
			self.mapState.routes = await [Route].download()
		}
		return self.mapView
	}
	
	func updateNSView(_ nsView: MKMapView, context: Context) {
		self.mapView.delegate = context.coordinator
		let annotationsToRemove = nsView.annotations.filter { (annotation) in
			return annotation is Bus || annotation is Stop
		}
		nsView.removeAnnotations(annotationsToRemove)
		if self.mapState.doShowBuses {
			nsView.addAnnotations(Array(self.mapState.buses))
		}
		if self.mapState.doShowStops {
			nsView.addAnnotations(Array(self.mapState.stops))
		}
		if let pinCoordinate = self.mapState.pinCoordinate {
			switch self.pin.annotationView.dragState {
			case .dragging:
				break
			default:
				self.pin.coordinate = pinCoordinate
				let isAlreadyAdded = nsView.annotations.contains { (annotation) in
					return annotation is Pin
				}
				if !isAlreadyAdded {
					nsView.addAnnotation(self.pin)
				}
			}
		}
		nsView.removeOverlays(nsView.overlays)
		if self.mapState.doShowRoutes {
			nsView.addOverlays(self.mapState.routes)
		}
	}
	
	func makeCoordinator() -> MapViewDelegate {
		return MapViewDelegate()
	}
	
}
