//
//  Stop.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/8/22.
//

import MapKit

class Stop: NSObject, Decodable, Identifiable, CustomAnnotation {
	
	enum CodingKeys: String, CodingKey {
		
		case name, coordinate
		
	}
	
	let name: String
	
	let coordinate: CLLocationCoordinate2D
	
	var location: CLLocation {
		get {
			return CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
		}
	}
	
	var title: String? {
		get {
			return self.name
		}
	}
	
	let annotationView: MKAnnotationView = {
		let annotationView = MKAnnotationView()
		annotationView.displayPriority = .defaultHigh
		annotationView.canShowCallout = true
		annotationView.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: nil)?
			.withTintColor(.white)
		annotationView.layer?.borderColor = .black
		annotationView.layer?.borderWidth = 2
		annotationView.layer?.cornerRadius = annotationView.frame.width / 2
		return annotationView
	}()
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decode(String.self, forKey: .name)
		self.coordinate = try container.decode(Coordinate.self, forKey: .coordinate).convertedForCoreLocation()
	}
	
}

extension Array where Element == Stop {
	
	static func download() async -> Array<Stop> {
		return await withCheckedContinuation { continuation in
			API.provider.request(.readStops) { (result) in
				let stops = try? result
					.get()
					.map([Stop].self)
				continuation.resume(returning: stops ?? [])
			}
		}
	}
	
}
