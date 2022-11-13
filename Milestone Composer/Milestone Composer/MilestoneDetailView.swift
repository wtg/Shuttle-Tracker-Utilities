//
//  MilestoneDetailView.swift
//  Milestone Composer
//
//  Created by Gabriel Jacoby-Cooper on 3/30/22.
//

import KeyManagement
import SwiftUI

struct MilestoneDetailView: View {
	
	@State
	private var doShowConfirmationDialog = false
	
	@State
	private var doShowSuccessAlert = false
	
	@State
	private var error: WrappedError?
	
	@State
	private var selectedKeyPair: KeyPair?
	
	@AppStorage("KeyPairs", store: DefaultsUtilities.store)
	private var keyPairs: [KeyPair] = []
	
	let milestone: Milestone
	
	let baseURL: URL
	
	let deletionHandler: () async -> Void
	
	var body: some View {
		ScrollView {
			Spacer()
			HStack {
				Text(self.milestone.extendedDescription)
				Spacer()
			}
			Spacer()
			HStack {
				VStack(alignment: .leading) {
					Text("Progress")
					Text("Progress Type")
					Text("Goals")
				}
					.font(.headline)
					.padding(.trailing)
				VStack(alignment: .leading) {
					Text(self.milestone.progress.description)
					Text(self.milestone.progressType?.rawValue ?? "Unknown")
					HStack {
						ForEach(self.milestone.goalHandles.sorted()) { (goalHandle) in
							Text(goalHandle.goal.description)
						}
						Spacer()
					}
				}
			}
		}
			.padding(.horizontal, 10)
			.frame(minWidth: 300)
			.navigationTitle(self.milestone.name)
			.toolbar {
				Picker("Key", selection: self.$selectedKeyPair) {
					ForEach(self.keyPairs) { (keyPair) in
						Text(keyPair.name)
							.tag(Optional(keyPair))
					}
				}
					.disabled(self.keyPairs.isEmpty)
				HStack {
					Divider()
				}
				Button {
					self.doShowConfirmationDialog = true
				} label: {
					Label("Delete…", systemImage: "trash")
				}
					.disabled(self.selectedKeyPair == nil)
			}
			.confirmationDialog("Delete Milestone", isPresented: self.$doShowConfirmationDialog) {
				Button("Cancel", role: .cancel) { }
					.keyboardShortcut(.cancelAction)
				Button("Delete", role: .destructive) {
					Task {
						let url = self.baseURL
							.appendingPathComponent("milestones")
							.appendingPathComponent(self.milestone.id.uuidString)
						guard let selectedKeyPair = self.selectedKeyPair else {
							let newError = DeletionError.noKeySelected
							self.error = WrappedError(newError)
							throw newError
						}
						var request = URLRequest(url: url)
						request.httpMethod = "DELETE"
						let response: URLResponse
						do {
							let deletionRequest = try self.milestone.deletionRequest(signedUsing: selectedKeyPair)
							let data = try JSONEncoder()
								.encode(deletionRequest)
							(_, response) = try await URLSession.shared.upload(for: request, from: data)
							await self.deletionHandler()
						} catch let newError {
							self.error = WrappedError(newError)
							throw newError
						}
						guard let httpResponse = response as? HTTPURLResponse else {
							let newError = DeletionError.malformedResponse
							self.error = WrappedError(newError)
							throw newError
						}
						let newError: DeletionError
						switch httpResponse.statusCode {
						case 200:
							self.doShowSuccessAlert = true
							return
						case 401:
							newError = .keyNotVerified
						case 403:
							newError = .keyRejected
						case 500:
							newError = .internalServerError
						default:
							newError = .unknown
						}
						self.error = WrappedError(newError)
						throw newError
					}
				}
			} message: {
				Text("Are you sure that you want to delete this milestone? You can’t undo this action.")
			}
			.alert(isPresented: self.$error.isNotNil, error: self.error) {
				Button("Continue") { }
			}
			.alert("The deletion was successful!", isPresented: self.$doShowSuccessAlert) {
				Button("Continue") { }
			}
	}
	
}
