//
//  MapViewDelegate.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import SwiftUI
import MapKit

class MapViewDelegate: NSObject, MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if let customAnnotation = annotation as? CustomAnnotation {
			return customAnnotation.annotationView
		}
		return nil
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if let route = overlay as? Route {
			return route.polylineRenderer
		}
		return MKOverlayRenderer()
	}
	
}
