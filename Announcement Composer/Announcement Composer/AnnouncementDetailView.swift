//
//  AnnouncementDetailView.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/21/21.
//

import KeyManagement
import SwiftUI

struct AnnouncementDetailView: View {
	
	let announcement: Announcement
	
	let baseURL: URL
	
	let deletionHandler: () async -> Void
	
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
	
	var body: some View {
		ScrollView {
			Spacer()
			HStack {
				Text(self.announcement.body)
					.textSelection(.enabled)
				Spacer()
			}
			Spacer()
			HStack {
				VStack(alignment: .leading) {
					switch self.announcement.scheduleType {
					case .none:
						EmptyView()
					case .startOnly:
						Text("\(self.announcement.start > .now ? "Will be posted" : "Posted") \(self.announcement.startString)")
					case .endOnly:
						Text("\(self.announcement.end > .now ? "Expires" : "Expired") \(self.announcement.endString)")
					case .startAndEnd:
						Text("\(self.announcement.start > .now ? "Will be posted" : "Posted") \(self.announcement.startString); \(self.announcement.end > .now ? "expires" : "expired") \(self.announcement.endString)")
					}
					switch self.announcement.interruptionLevel {
					case .passive:
						Text("Passive")
					case .active:
						Text("Active")
					case .timeSensitive:
						Text("Time-sensitive")
					case .critical:
						Text("Critical")
					}
				}
					.font(.footnote)
					.foregroundColor(.secondary)
				Spacer()
			}
				.padding(.bottom)
		}
			.padding(.horizontal, 10)
			.frame(minWidth: 300)
			.navigationTitle(self.announcement.subject)
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
			.confirmationDialog("Delete Announcement", isPresented: self.$doShowConfirmationDialog) {
				Button("Cancel", role: .cancel) { }
					.keyboardShortcut(.cancelAction)
				Button("Delete", role: .destructive) {
					Task.detached {
						let url = self.baseURL
							.appendingPathComponent("announcements")
							.appendingPathComponent(self.announcement.id.uuidString)
						guard let selectedKeyPair = self.selectedKeyPair else {
							let error = DeletionError.noKeySelected
							self.error = WrappedError(error)
							throw error
						}
						var request = URLRequest(url: url)
						request.httpMethod = "DELETE"
						let response: URLResponse
						do {
							let deletionRequest = try self.announcement.deletionRequest(signedUsing: selectedKeyPair)
							let data = try JSONEncoder().encode(deletionRequest)
							(_, response) = try await URLSession.shared.upload(for: request, from: data)
							await self.deletionHandler()
						} catch {
							self.error = WrappedError(error)
							throw error
						}
						guard let httpResponse = response as? HTTPURLResponse else {
							let error = DeletionError.malformedResponse
							self.error = WrappedError(error)
							throw error
						}
						let error: DeletionError
						switch httpResponse.statusCode {
						case 200:
							self.doShowSuccessAlert = true
							return
						case 401:
							error = .keyNotVerified
						case 403:
							error = .keyRejected
						case 500:
							error = .internalServerError
						default:
							error = .unknown
						}
						self.error = WrappedError(error)
					}
				}
			} message: {
				Text("Are you sure that you want to delete this announcement? You can’t undo this action.")
			}
			.alert(isPresented: self.$error.isNotNil, error: self.error) {
				Button("Continue") { }
			}
			.alert("The deletion was successful!", isPresented: self.$doShowSuccessAlert) {
				Button("Continue") { }
			}
	}
	
}
