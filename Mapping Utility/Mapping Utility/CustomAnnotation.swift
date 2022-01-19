//
//  CustomAnnotation.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import MapKit

protocol CustomAnnotation: MKAnnotation {
	
	var annotationView: MKAnnotationView { get }
	
}
