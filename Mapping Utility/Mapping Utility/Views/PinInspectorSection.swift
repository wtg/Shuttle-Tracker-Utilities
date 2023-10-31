//
//  PinInspectorSection.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 1/19/22.
//

import HTTPStatus
import SwiftUI

import enum Moya.MoyaError

struct PinInspectorSection: View {
	
	@State
	private var busID: Int?
	
	@State
	private var busSubmissionStatus: (any HTTPStatusCode)?
	
	@State
	private var busSubmissionLocationID = UUID()
	
	@Environment(MapState.self)
	private var mapState
	
	var body: some View {
		InspectorSection("Pin") {
			if self.mapState.pinCoordinate == nil {
				Button("Drop Pin") {
					self.mapState.pinCoordinate = MapConstants.originCoordinate
				}
			}
			if let pinCoordinate = self.mapState.pinCoordinate {
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
							guard let busID = self.busID else {
								return
							}
							let location = Bus.Location(
								id: self.busSubmissionLocationID,
								date: .now,
								coordinate: pinCoordinate.convertedToCoordinate(),
								type: .user
							)
							Task {
								do {
									try await API.updateBus(id: busID, location: location).perform()
								} catch let error as HTTPStatusCode {
									self.busSubmissionStatus = error
								}
								try await Task.sleep(for: .seconds(2))
								self.busSubmissionStatus = nil
							}
						}
							.disabled(self.busID == nil)
							.layoutPriority(1)
					}
					Group {
						switch self.busSubmissionStatus {
						case .some(HTTPStatusCodes.Success.ok):
							Text("Submitted bus location")
						case .some(let code as any Error & HTTPStatusCode):
							Text(code.localizedDescription)
						case .some(let code):
							Text("HTTP \(code.rawValue)")
						case .none:
							EmptyView()
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

#Preview {
	PinInspectorSection()
		.environment(MapState.shared)
}
