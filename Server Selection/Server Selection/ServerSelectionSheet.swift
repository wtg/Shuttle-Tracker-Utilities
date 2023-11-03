//
//  ServerSelectionSheet.swift
//  Server Selection
//
//  Created by Gabriel Jacoby-Cooper on 11/12/22.
//

import RegexBuilder
import SwiftData
import SwiftUI

public struct ServerSelectionSheet<Item>: View {
	
	@State
	private var hasSubmitted = false
	
	@State
	private var doShowAlert = false
	
	@Binding
	private(set) var server: Server
	
	@State
	private var selectedServer: Server?
	
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
	private var newName: String = ""
	
	@State
	private var newBaseURLString: String = ""
	
	@Binding
	private(set) var item: Item?
	
	@Environment(\.dismiss)
	private var dismiss
	
	@Environment(\.modelContext)
	private var modelContext
	
	@Query
	private var servers: [Server]
	
	public var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text("Select Server")
					.font(.title3)
					.bold()
				Spacer()
			}
			Picker("Server", selection: self.$selectedServer) {
				ForEach(self.servers) { (server) in
					HStack {
						VStack {
							Text(server.name)
							Text(server.baseURL.absoluteString)
						}
						if server.isEditable {
							Button("Delete", systemImage: "x.circle.fill") {
								self.modelContext.delete(server)
							}
								.buttonStyle(.borderless)
						}
					}
				}
			}
				.pickerStyle(.inline)
				.labelsHidden()
			Form {
				Section("New Server") {
					TextField("Name", text: self.$newName)
					
					// TextField has issues with data formatters, so we proxy the value through a string instead.
					TextField("Base URL", text: self.$newBaseURLString)
					
					if self.newBaseURL == nil {
						Text("This URL is invalid.")
					}
					Button("Add") {
						guard !self.newName.isEmpty, let newBaseURL = self.newBaseURL else {
							return
						}
						let newServer = Server(name: newName, baseURL: newBaseURL)
						self.modelContext.insert(newServer)
						try! self.modelContext.save()
						self.newName = ""
						self.newBaseURLString = ""
					}
						.disabled(self.newName.isEmpty || self.newBaseURL == nil)
				}
			}
			HStack {
				Spacer()
				Button(role: .cancel) {
					self.item = nil
				} label: {
					Text("Cancel")
				}
					.keyboardShortcut(.cancelAction)
				Button("Save") {
					guard let selectedServer = self.selectedServer else {
						return
					}
					self.server = selectedServer
					self.dismiss()
				}
					.keyboardShortcut(.defaultAction)
					.disabled(self.selectedServer == nil)
			}
				.padding(.top)
		}
			.padding()
			.frame(minWidth: 300)
			.modelContainer(for: Server.self, isAutosaveEnabled: false)
	}
	
	public init(server: Binding<Server>, item: Binding<Item?>) {
		self._server = server
		self._item = item
	}
	
}
