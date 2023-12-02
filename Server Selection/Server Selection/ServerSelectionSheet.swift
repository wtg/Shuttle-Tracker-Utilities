//
//  ServerSelectionSheet.swift
//  Server Selection
//
//  Created by Gabriel Jacoby-Cooper on 11/12/22.
//

import OSLog
import RegexBuilder
import SwiftData
import SwiftUI

public struct ServerSelectionSheet<Item>: View {
	
	private var newBaseURL: URL? {
		get {
			let regex = Regex {
				.url()
			}
			
			// wholeMatch(in:) crashes when the provided string doesn’t have a URL host component, so we exit this getter early instead.
			guard !self.newBaseURLString.hasSuffix("://") else {
				return nil
			}
			
			return try? regex.wholeMatch(in: self.newBaseURLString)?.output
		}
	}
	
	@State
	private var newName = ""
	
	@State
	private var newBaseURLString = ""
	
	@State
	private var doShowResetSavedServersAlert = false
	
	@State
	private var didResetSavedServers = false
	
	@Environment(\.dismiss)
	private var dismiss
	
	@Environment(\.modelContext)
	private var modelContext
	
	@Query
	private var servers: [Server]
	
	@Binding
	private(set) var server: Server
	
	@State
	private var selectedServer: Server
	
	@Binding
	private(set) var item: Item?
	
	private let logger = Logger(subsystem: "com.gerzer.shuttletracker.serverselection", category: "ServerSelectionSheet")
	
	public var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text("Select Server")
					.font(.title3)
					.bold()
				Spacer()
			}
			Form {
				Section {
					Picker("Server", selection: self.$selectedServer) {
						ForEach(self.servers) { (server) in
							VStack {
								HStack(alignment: .top) {
									VStack(alignment: .leading) {
										Text(server.name)
										Text(server.baseURL.absoluteString)
											.monospaced()
											.textSelection(.enabled)
									}
									Spacer()
									if server.isEditable {
										Button("Delete", systemImage: "minus.circle.fill") {
											self.modelContext.delete(server)
										}
											.buttonStyle(.borderless)
											.labelStyle(.iconOnly)
									}
								}
								Divider()
							}
								.tag(server)
						}
					}
						.pickerStyle(.radioGroup)
					HStack {
						Button(role: .destructive) {
							self.doShowResetSavedServersAlert = true
						} label: {
							HStack {
								Text("Reset Saved Servers")
								if self.didResetSavedServers {
									Text("✓")
								}
							}
						}
							.disabled(self.servers.allAreNonEditable)
						Spacer()
					}
				}
				Divider()
				Section {
					TextField("Name", text: self.$newName)
					
					// TextField has issues with data formatters, so we proxy the value through a string instead.
					TextField("Base URL", text: self.$newBaseURLString)
					
					if self.newBaseURL == nil && !self.newBaseURLString.isEmpty {
						Text("This base URL is invalid.")
					} else if let newBaseURL = self.newBaseURL, self.servers.hasServer(for: newBaseURL) {
						Text("There’s already a saved server with this base URL.")
							.lineLimit(nil)
					}
					Button("Add") {
						guard !self.newName.isEmpty, let newBaseURL = self.newBaseURL, !self.servers.hasServer(for: newBaseURL) else {
							self.logger.log("The new server cannot be added because the data are in an invalid state.")
							return
						}
						let newServer = Server(name: self.newName, baseURL: newBaseURL)
						self.modelContext.insert(newServer)
						self.newName = ""
						self.newBaseURLString = ""
					}
						.disabled(
							self.newName.isEmpty || self.newBaseURL == nil || self.newBaseURL.map { (newBaseURL) in
								return self.servers.hasServer(for: newBaseURL)
							} ?? false
						)
				} header: {
					Text("New Server")
						.bold()
				}
			}
		}
			.padding()
			.frame(minWidth: 300, idealWidth: 500)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						do {
							try self.modelContext.save()
						} catch {
							self.logger.log(level: .error, "Failed to save server data: \(error, privacy: .public)")
						}
						self.server = self.selectedServer
						self.dismiss()
					}
						.keyboardShortcut(.defaultAction)
						.disabled(!self.modelContext.hasChanges && self.selectedServer.baseURL == self.server.baseURL)
				}
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel", role: .cancel) {
						self.modelContext.rollback()
						self.dismiss()
					}
						.keyboardShortcut(.cancelAction)
				}
			}
			.alert("Reset Saved Servers", isPresented: self.$doShowResetSavedServersAlert) {
				Button("Reset", role: .destructive) {
					for server in self.servers where server.isEditable {
						self.modelContext.delete(server)
					}
					self.insertDefaultServers()
					do {
						try self.modelContext.save()
						self.didResetSavedServers = true
					} catch {
						self.logger.log(level: .error, "Failed to save server data: \(error, privacy: .public)")
					}
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("Are you sure that you want to reset the saved servers? This action cannot be undone.")
			}
			.task {
				self.insertDefaultServers()
				do {
					try self.modelContext.save()
				} catch {
					self.logger.log(level: .error, "Failed to save server data: \(error, privacy: .public)")
				}
				let currentServer = self.servers.first { (candidate) in
					return candidate.baseURL == self.server.baseURL
				}
				if let currentServer {
					self.selectedServer = currentServer
				}
			}
			.onChange(of: self.servers.allAreNonEditable) { (_, newValue) in
				if !newValue {
					self.didResetSavedServers = false
				}
			}
	}
	
	public init(server: Binding<Server>, item: Binding<Item?>) {
		self._server = server
		self._selectedServer = State(initialValue: server.wrappedValue)
		self._item = item
	}
	
	private func insertDefaultServers() {
		for server in Server.defaultServers {
			let isDuplicate = self.servers.contains { (candidate) in
				return candidate.baseURL == server.baseURL && !candidate.isEditable
			}
			guard !isDuplicate else {
				continue
			}
			self.modelContext.insert(server)
		}
	}
	
}
