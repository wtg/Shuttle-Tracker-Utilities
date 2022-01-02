//
//  AnnouncementDetailView.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/21/21.
//

import SwiftUI

struct AnnouncementDetailView: View {
	
	@State private var doShowConfirmationDialog = false
	
	@State private var error: WrappedError?
	
	@State private var selectedKeyPair: KeyPair?
	
	@AppStorage("KeyPairs") private var keyPairs = [KeyPair]()
	
	let announcement: Announcement
	
	let baseURL: URL
	
	var body: some View {
		ScrollView {
			Spacer()
			HStack {
				Text(self.announcement.body)
				Spacer()
			}
			Spacer()
			HStack {
				switch self.announcement.scheduleType {
				case .none:
					EmptyView()
				case .startOnly:
					Text("Posted \(self.announcement.startString)")
				case .endOnly:
					Text("Expires \(self.announcement.endString)")
				case .startAndEnd:
					Text("Posted \(self.announcement.startString); expires \(self.announcement.endString)")
				}
				Spacer()
			}
				.font(.footnote)
				.foregroundColor(.secondary)
		}
			.padding(.horizontal, 10)
			.frame(minWidth: 300)
			.navigationTitle(self.announcement.subject)
			.toolbar {
				ToolbarItem {
					Picker("Key", selection: self.$selectedKeyPair) {
						ForEach(self.keyPairs) { (keyPair) in
							Text(keyPair.name)
								.tag(Optional(keyPair))
						}
					}
						.disabled(self.keyPairs.isEmpty)
				}
				ToolbarItem {
					HStack {
						Divider()
					}
				}
				ToolbarItem {
					Button {
						self.doShowConfirmationDialog = true
					} label: {
						Label("Delete…", systemImage: "trash")
					}
						.disabled(self.selectedKeyPair == nil)
				}
			}
			.confirmationDialog("Delete Announcement", isPresented: self.$doShowConfirmationDialog) {
				Button("Cancel", role: .cancel) { }
					.keyboardShortcut(.cancelAction)
				Button("Delete", role: .destructive) {
					Task {
						let url = self.baseURL
							.appendingPathComponent("announcements")
							.appendingPathComponent(self.announcement.id.uuidString)
						guard let selectedKeyPair = self.selectedKeyPair else {
							self.error = WrappedError(SubmissionError.noKeySelected)
							return
						}
						var request = URLRequest(url: url)
						request.httpMethod = "DELETE"
						do {
							let signature = try self.announcement.signatureForDeletion(using: selectedKeyPair)
							_ = try await URLSession.shared.upload(for: request, from: signature)
						} catch let newError {
							self.error = WrappedError(newError)
						}
					}
				}
			} message: {
				Text("Are you sure that you want to delete this announcement? You can’t undo this action.")
			}
			.alert(isPresented: self.$error.isNotNil, error: self.error) {
				Button("Continue") { }
			}
	}
	
}
