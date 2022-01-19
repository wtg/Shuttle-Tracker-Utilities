//
//  Pin.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/19/22.
//

import MapKit

class Pin: NSObject, CustomAnnotation {
	
	var coordinate: CLLocationCoordinate2D
	
	let annotationView: MKAnnotationView = {
		let markerAnnotationView = MKMarkerAnnotationView()
		markerAnnotationView.displayPriority = .required
		markerAnnotationView.glyphTintColor = .white
		return markerAnnotationView
	}()
	
	init(coordinate: CLLocationCoordinate2D) {
		self.coordinate = coordinate
	}
	
}
