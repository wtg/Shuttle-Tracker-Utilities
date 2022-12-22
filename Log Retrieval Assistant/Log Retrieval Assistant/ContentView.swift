//
//  ContentView.swift
//  Log Retrieval Assistant
//
//  Created by Gabriel Jacoby-Cooper on 11/3/22.
//

import HTTPStatus
import KeyManagement
import ServerSelection
import SwiftUI

struct ContentView: View {
	
	enum SheetType: Int, IdentifiableByRawValue {
		
		case serverSelection
		
		typealias ID = RawValue
		
	}
	
	@State
	private var sheetType: SheetType?
	
	@State
	private var logs: [Log]?
	
	@State
	private var selectedLogs: Set<Log> = []
	
	@AppStorage("KeyPairs", store: DefaultsUtilities.store)
	private var keyPairs: [KeyPair] = []
	
	@State
	private var selectedKeyPair: KeyPair?
	
	@State
	private var baseURL = URL(string: "https://shuttletracker.app")!
	
	@State
	private var logListMessage: String?
	
	@State
	private var searchText: String = ""
	
	@State
	private var searchScope: Log.SearchScope = .id
	
	@State
	private var doTriggerDeletion = false
	
	@WrappedError
	private var error: (any Error)?
	
	var body: some View {
		NavigationSplitView {
			Group {
				if let logs = self.logs {
					if logs.isEmpty {
						Text("No Logs")
							.font(.title2)
							.multilineTextAlignment(.center)
							.foregroundColor(.secondary)
							.padding()
					} else {
						List(
							logs.filter(on: self.searchText, in: self.searchScope),
							selection: self.$selectedLogs
						) { (log) in
							NavigationLink(value: log) {
								VStack(spacing: 0) {
									HStack {
										Text(log.id.uuidString)
											.bold()
										Spacer()
									}
									HStack(spacing: 5) {
										Text(log.clientPlatform.name)
											.padding(.horizontal, 5)
											.padding(.vertical, 1)
											.background {
												RoundedRectangle(cornerRadius: 10, style: .continuous)
													.fill(.gray)
											}
										Text(log.date.formatted())
										Spacer()
									}
								}
							}
						}
							.contextMenu(forSelectionType: Log.self) { (_) in
								Button("Delete…", role: .destructive) {
									self.doTriggerDeletion = true
								}
									.keyboardShortcut(.delete, modifiers: [])
							}
							.onDeleteCommand {
								self.doTriggerDeletion = true
							}
					}
				} else {
					if let error = self.error {
						VStack(alignment: .center) {
							Text("Couldn’t Refresh Logs")
								.font(.title2)
								.foregroundColor(.secondary)
							if error is OperationError {
								Text(error.localizedDescription)
									.foregroundColor(.secondary)
									.multilineTextAlignment(.center)
							} else {
								Text("An error occurred.")
									.foregroundColor(.secondary)
									.multilineTextAlignment(.center)
							}
						}
							.padding()
					} else {
						ProgressView("Loading")
							.font(.callout)
							.textCase(.uppercase)
							.foregroundColor(.secondary)
							.padding()
					}
				}
			}
				.frame(width: 350)
				.toolbar {
					Button {
						self.sheetType = .serverSelection
					} label: {
						Label("Select Server", systemImage: "server.rack")
					}
					Button {
						Task {
							do {
								try await self.refresh()
							} catch let error {
								self.error = error
							}
						}
					} label: {
						Label("Refresh", systemImage: "arrow.clockwise")
					}
						.keyboardShortcut("r", modifiers: .command)
						.disabled(self.selectedKeyPair == nil)
					HStack {
						Divider()
					}
					Picker("Key", selection: self.$selectedKeyPair) {
						ForEach(self.keyPairs) { (keyPair) in
							Text(keyPair.name)
								.tag(Optional(keyPair))
						}
					}
						.disabled(self.keyPairs.isEmpty)
					Button {
						WindowManager.show(.keyManager)
					} label: {
						Label("Key Manager", systemImage: "key")
					}
				}
		} detail: {
			LogDetailView(
				logs: self.$selectedLogs,
				baseURL: self.baseURL,
				keyPair: self.selectedKeyPair,
				refresh: self.refresh
			)
		}
			.searchable(text: self.$searchText)
			.searchScopes(self.$searchScope) {
				Text("ID")
					.tag(Log.SearchScope.id)
				Text("Content")
					.tag(Log.SearchScope.content)
			}
			.alert(isPresented: self.$error.$doShowAlert, error: self.$error) {
				Button("Continue") { }
			}
			.sheet(item: self.$sheetType) {
				Task {
					do {
						try await self.refresh()
					} catch let error {
						self.error = error
					}
				}
			} content: { (sheetType) in
				switch sheetType {
				case .serverSelection:
					ServerSelectionSheet(baseURL: self.$baseURL, item: self.$sheetType)
				}
			}
			.task {
				do {
					try await self.refresh()
				} catch let error {
					self.error = error
				}
			}
			.logDeletion(
				self.$selectedLogs,
				isTriggered: self.$doTriggerDeletion,
				baseURL: self.baseURL,
				keyPair: self.selectedKeyPair,
				errorProjection: self.$error,
				refresh: self.refresh
			)
	}
	
	private func refresh() async throws {
		self.error = nil
		self.logs = nil
		self.selectedLogs = []
		let url = self.baseURL.appending(component: "logs")
		let (data, _) = try await URLSession.shared.data(from: url)
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		let ids = try decoder.decode([UUID].self, from: data)
		self.logs = try await withThrowingTaskGroup(of: Log.self, returning: [Log].self) { (taskGroup) in
			for id in ids {
				taskGroup.addTask {
					return try await self.log(withID: id, decoder: decoder)
				}
			}
			return try await taskGroup
				.reduce(into: []) { (partialResult, log) in
					partialResult.append(log)
				}
				.sorted { (first, second) in
					return first.date < second.date
				}
				.reversed()
		}
	}
	
	private func log(withID id: UUID, decoder: JSONDecoder) async throws -> Log {
		guard let keyPair = self.selectedKeyPair else {
			throw OperationError.noKeySelected
		}
		let signature = try keyPair.signature(for: id.uuidString.data(using: .utf8)!)
		let queryItems = signature.map { (byte) in
			return URLQueryItem(name: "signature[]", value: byte.formatted())
		}
		let url = self.baseURL
			.appending(components: "logs", id.uuidString)
			.appending(queryItems: queryItems)
		let (data, response) = try await URLSession.shared.data(from: url)
		guard let httpResponse = response as? HTTPURLResponse, let statusCode = HTTPStatusCodes.statusCode(httpResponse.statusCode) else {
			throw OperationError.malformedResponse
		}
		switch statusCode {
		case HTTPStatusCodes.Success.ok:
			return try decoder.decode(Log.self, from: data)
		case HTTPStatusCodes.ClientError.unauthorized:
			throw OperationError.keyNotVerified
		case HTTPStatusCodes.ClientError.forbidden:
			throw OperationError.keyRejected
		case let statusCodeError as any Error:
			throw statusCodeError
		default:
			throw OperationError.unknown
		}
	}
	
}

struct ContentViewPreviews: PreviewProvider {
	
	static var previews: some View {
		ContentView()
	}
	
}

extension UUID {
	
	var uuidBytes: [UInt8] {
		get {
			return [
				self.uuid.0,
				self.uuid.1,
				self.uuid.2,
				self.uuid.3,
				self.uuid.4,
				self.uuid.5,
				self.uuid.6,
				self.uuid.7,
				self.uuid.8,
				self.uuid.9,
				self.uuid.10,
				self.uuid.11,
				self.uuid.12,
				self.uuid.13,
				self.uuid.14,
				self.uuid.15,
			]
		}
	}
	
	var uuidData: Data {
		get {
			return Data(self.uuidBytes)
		}
	}
	
}
