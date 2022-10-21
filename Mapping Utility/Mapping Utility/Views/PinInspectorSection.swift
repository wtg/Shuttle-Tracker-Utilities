//
//  PinInspectorSection.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/19/22.
//

import SwiftUI

import enum Moya.MoyaError

struct PinInspectorSection: View {
	
	@State private var busID: Int?
	
	@State private var busSubmissionStatusCode: Int?
	
	@State private var busSubmissionLocationID = UUID()
	
	@EnvironmentObject private var mapState: MapState
	
	var body: some View {
		InspectorSection("Pin") {
			if self.mapState.pinCoordinate == nil {
				Button("Drop Pin") {
					self.mapState.pinCoordinate = MapUtilities.Constants.originCoordinate
				}
			} else {
				VStack(alignment: .leading) {
					Text("Coordinate")
						.font(.headline)
					Form {
						TextField("Latitude", value: self.mapState.pinLatitude, format: .number)
						TextField("Longitude", value: self.mapState.pinLongitude, format: .number)
					}
				}
				Divider()
				Form {
					HStack {
						TextField(
							"Bus ID",
							value: self.$busID,
							format: .number,
							prompt: Text("Bus ID")
						)
							.labelsHidden()
						Button("Submit as Bus Location") {
							let location = Bus.Location(
								id: self.busSubmissionLocationID,
								date: .now,
								coordinate: self.mapState.pinCoordinate!.convertedToCoordinate(),
								type: .user
							)
							API.provider.request(.updateBus(id: self.busID!, location: location)) { (result) in
								do {
									self.busSubmissionStatusCode = try result.get().statusCode
								} catch let error as MoyaError {
									if case .statusCode(let response) = error {
										self.busSubmissionStatusCode = response.statusCode
									} else {
										self.busSubmissionStatusCode = -1
									}
								} catch {
									self.busSubmissionStatusCode = -1
								}
								Task {
									try await Task.sleep(for: .seconds(2))
									self.busSubmissionStatusCode = nil
								}
							}
						}
							.disabled(self.busID == nil)
							.layoutPriority(1)
					}
					if let busSubmissionStatusCode = self.busSubmissionStatusCode {
						if busSubmissionStatusCode < 0 {
							Text("An unknown error occured")
						} else {
							Text("Received HTTP status code \(busSubmissionStatusCode)")
						}
					}
					HStack {
						Spacer()
						Button("Randomize Trip Identifier") {
							self.busSubmissionLocationID = UUID()
						}
						Spacer()
					}
				}
				Divider()
				Button("Remove Pin") {
					self.mapState.pinCoordinate = nil
				}
			}
		}
	}
	
}

struct PinInspectorSectionPreviews: PreviewProvider {
	
	static var previews: some View {
		PinInspectorSection()
			.environmentObject(MapState.shared)
	}
	
}
