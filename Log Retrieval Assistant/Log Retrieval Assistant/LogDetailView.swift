//
//  LogDetailView.swift
//  Log Retrieval Assistant
//
//  Created by Gabriel Jacoby-Cooper on 11/11/22.
//

import KeyManagement
import SwiftUI

struct LogDetailView: View {
	
	let log: Log
	
	let baseURL: URL
	
	let keyPair: KeyPair?
	
	let deletionHandler: () async -> Void
	
	@State
	private var doShowConfirmationDialog = false
	
	@State
	private var doShowSuccessAlert = false
	
	@State
	private var error: WrappedError?
	
	var body: some View {
		ScrollView {
			Spacer()
			HStack {
				Text(log.content)
					.fontDesign(.monospaced)
				Spacer()
			}
		}
			.padding(.horizontal, 10)
			.frame(minWidth: 500)
			.toolbar {
				Button {
					self.doShowConfirmationDialog = true
				} label: {
					Label("Delete…", systemImage: "trash")
				}
					.disabled(self.keyPair == nil)
				if let url = try? self.log.writeToDisk() {
					ShareLink(item: url)
					Button {
						NSWorkspace.shared.open(url)
					} label: {
						Label("Open in Log Viewer", systemImage: "arrowshape.turn.up.forward")
					}
				}
			}
			.confirmationDialog("Delete Log", isPresented: self.$doShowConfirmationDialog) {
				Button("Cancel", role: .cancel) { }
					.keyboardShortcut(.cancelAction)
				Button("Delete", role: .destructive) {
					Task {
						do {
							let url = self.baseURL.appending(components: "logs", self.log.id.uuidString)
							guard let keyPair = self.keyPair else {
								throw OperationError.noKeySelected
							}
							var request = URLRequest(url: url)
							request.httpMethod = "DELETE"
							let response: URLResponse
							let deletionRequest = try self.log.deletionRequest(signedUsing: keyPair)
							let data = try JSONEncoder().encode(deletionRequest)
							(_, response) = try await URLSession.shared.upload(for: request, from: data)
							await self.deletionHandler()
							guard let httpResponse = response as? HTTPURLResponse else {
								throw OperationError.malformedResponse
							}
							switch httpResponse.statusCode {
							case 200:
								self.doShowSuccessAlert = true
								return
							case 401:
								throw OperationError.keyNotVerified
							case 403:
								throw OperationError.keyRejected
							case 500:
								throw OperationError.internalServerError
							default:
								throw OperationError.unknown
							}
						} catch let newError {
							self.error = WrappedError(newError)
						}
					}
				}
			} message: {
				Text("Are you sure that you want to delete this log? You can’t undo this action.")
			}
			.alert(isPresented: self.$error.isNotNil, error: self.error) {
				Button("Continue") { }
			}
			.alert("The deletion was successful!", isPresented: self.$doShowSuccessAlert) {
				Button("Continue") { }
			}
	}
	
}
