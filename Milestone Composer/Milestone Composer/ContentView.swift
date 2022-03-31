//
//  ContentView.swift
//  Milestone Composer
//
//  Created by Gabriel Jacoby-Cooper on 3/15/22.
//

import SwiftUI
import KeyManagement

struct ContentView: View {
	
	@State private var milestone = Milestone()
	
	@State private var baseURLString = "https://shuttletracker.app"
	
	@State private var doShowSuccessAlert = false
	
	@State private var error: WrappedError?
	
	@State private var selectedKeyPair: KeyPair?
	
	@AppStorage("KeyPairs", store: DefaultsUtilities.store) private var keyPairs: [KeyPair] = []
	
	var body: some View {
		VStack {
			Form {
				Section {
					TextField("Name", text: self.$milestone.name, prompt: Text("Name"))
						.labelsHidden()
					TextEditor(text: self.$milestone.extendedDescription)
				} header: {
					Text("Name & Description")
						.font(.headline)
				}
				Divider()
					.padding(.vertical, 10)
				Section {
					HStack {
						ScrollView(.horizontal) {
							HStack {
								ForEach(self.milestone.goalHandles) { (goalHandle) in
									GoalEntryView(goals: self.$milestone.goals, index: goalHandle.index)
									Divider()
										.frame(height: 20)
								}
								Button {
									self.milestone.goals.append(1)
								} label: {
									Label("Add Goal", systemImage: "plus")
										.labelStyle(.iconOnly)
								}
							}
						}
						Spacer()
						if self.milestone.goals.count > 1 {
							Button("Sort") {
								self.milestone.goals.sort()
							}
						}
					}
						.frame(height: 25)
				} header: {
					Text("Goals")
						.font(.headline)
				}
				Divider()
					.padding(.vertical, 10)
				Section {
					HStack {
						TextField("Progress", value: self.$milestone.progress, format: .number)
							.frame(width: 50)
						Picker("Progress Type", selection: self.$milestone.progressType) {
							ForEach(Milestone.ProgressType.all) { (progressType) in
								Text(progressType.rawValue)
									.tag(Optional(progressType))
							}
						}
					}
						.labelsHidden()
				} header: {
					Text("Progress")
						.font(.headline)
				}
				Divider()
					.padding(.vertical, 10)
				Section {
					HStack {
						Picker("Key", selection: self.$selectedKeyPair) {
							ForEach(self.keyPairs) { (keyPair) in
								Text(keyPair.name)
									.tag(Optional(keyPair))
							}
						}
							.labelsHidden()
							.disabled(self.keyPairs.isEmpty)
						Button("Open Key Manager…") {
							WindowManager.show(.keyManager)
						}
					}
				} header: {
					Text("Key")
						.font(.headline)
				}
				Divider()
					.padding(.vertical, 10)
				Section {
					TextField("Base URL", text: self.$baseURLString, prompt: Text("Base URL"))
						.labelsHidden()
				} header: {
					Text("Server")
						.font(.headline)
				}
			}
			Divider()
				.padding(.vertical, 10)
			HStack {
				Button("Clear", role: .destructive) {
					self.clear()
				}
				Spacer()
				Button("Submit") {
					guard let selectedKeyPair = self.selectedKeyPair else {
						self.error = WrappedError(SubmissionError.noKeySelected)
						return
					}
					self.milestone.goals.ensurePositive()
					let signedMilestone: Milestone
					do {
						signedMilestone = try self.milestone.signed(using: selectedKeyPair)
					} catch let newError {
						self.error = WrappedError(newError)
						return
					}
					Task {
						guard let baseURL = URL(string: self.baseURLString) else {
							let newError = SubmissionError.invalidBaseURL
							self.error = WrappedError(newError)
							throw newError
						}
						let url = baseURL.appendingPathComponent("milestones", isDirectory: false)
						var request = URLRequest(url: url)
						request.httpMethod = "POST"
						let response: URLResponse
						do {
							let encoder = JSONEncoder()
							assert(signedMilestone.signature != nil)
							let data = try encoder.encode(signedMilestone)
							print(String(data: data, encoding: .utf8)!)
							(_, response) = try await URLSession.shared.upload(for: request, from: data)
							self.milestone = Milestone()
						} catch let newError {
							self.error = WrappedError(newError)
							throw newError
						}
						guard let httpResponse = response as? HTTPURLResponse else {
							let newError = SubmissionError.malformedResponse
							self.error = WrappedError(newError)
							throw newError
						}
						let newError: SubmissionError
						switch httpResponse.statusCode {
						case 200:
							self.doShowSuccessAlert = true
							self.clear()
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
					.keyboardShortcut(.defaultAction)
					.disabled(self.milestone.name.isEmpty || self.milestone.extendedDescription.isEmpty || self.milestone.progressType == nil || self.milestone.goals.count < 1 || self.selectedKeyPair == nil)
			}
		}
			.padding()
			.toolbar {
				ToolbarItem {
					Button {
						WindowManager.show(.keyManager)
					} label: {
						Label("Key Manager", systemImage: "key")
					}
				}
				ToolbarItem {
					Button {
						WindowManager.show(.milestoneManager)
					} label: {
						Label("Milestone Manager", systemImage: "list.bullet.rectangle")
					}
				}
			}
			.alert(isPresented: self.$error.isNotNil, error: self.error) {
				Button("Continue") { }
			}
			.alert("The submission was successful!", isPresented: self.$doShowSuccessAlert) {
				Button("Continue") { }
			}
	}
	
	private func clear() {
		self.milestone.name = ""
		self.milestone.extendedDescription = ""
		self.milestone.progressType = nil
		self.selectedKeyPair = nil
	}
	
}

struct ContentViewPreviews: PreviewProvider {
	
	static var previews: some View {
		ContentView()
	}
	
}
