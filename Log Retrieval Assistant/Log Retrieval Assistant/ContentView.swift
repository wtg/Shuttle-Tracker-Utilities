//
//  ContentView.swift
//  Log Retrieval Assistant
//
//  Created by Gabriel Jacoby-Cooper on 11/3/22.
//

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
	private var logs: [Log]? = [
		Log(id: UUID(), content: "Hello, world!", clientPlatform: .macos, date: .now)
	]
	
	@State
	private var selectedLog: Log?
	
	@AppStorage("KeyPairs", store: DefaultsUtilities.store)
	private var keyPairs: [KeyPair] = []
	
	@State
	private var selectedKeyPair: KeyPair?
	
	@State
	private var baseURL = URL(string: "https://shuttletracker.app")!
	
	@State
	private var error: WrappedError?
	
	var body: some View {
		NavigationView {
			Group {
				if let logs = self.logs {
					if logs.isEmpty {
						Text("No Logs")
							.font(.title2)
							.multilineTextAlignment(.center)
							.foregroundColor(.secondary)
							.padding()
					} else {
						List(logs, selection: self.$selectedLog) { (log) in
							NavigationLink {
								LogDetailView(log: log, baseURL: self.baseURL, keyPair: self.selectedKeyPair, deletionHandler: self.refresh)
							} label: {
								VStack(spacing: 0) {
									HStack {
										Text(log.id.uuidString)
											.bold()
										Spacer()
									}
									HStack(spacing: 5) {
										Text(log.date.formatted())
										Text(log.clientPlatform.name)
											.padding(.horizontal, 5)
											.padding(.vertical, 1)
											.background {
												RoundedRectangle(cornerRadius: 10, style: .continuous)
													.fill(.gray)
											}
										Spacer()
									}
								}
							}
						}
					}
				} else {
					ProgressView("Loading")
						.font(.callout)
						.textCase(.uppercase)
						.foregroundColor(.secondary)
						.padding()
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
							await self.refresh()
						}
					} label: {
						Label("Refresh", systemImage: "arrow.clockwise")
					}
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
			Text("No Log Selected")
				.font(.title2)
				.multilineTextAlignment(.center)
				.foregroundColor(.secondary)
				.padding()
				.toolbar {
					ToolbarItem {
						Button { } label: {
							Label("Delete", systemImage: "trash")
						}
						.disabled(true)
					}
				}
		}
			.alert(isPresented: self.$error.isNotNil, error: self.error) {
				Button("Continue") { }
			}
			.sheet(item: self.$sheetType) {
				Task {
					await self.refresh()
				}
			} content: { (sheetType) in
				switch sheetType {
				case .serverSelection:
					ServerSelectionSheet(baseURL: self.$baseURL, sheetType: self.$sheetType)
				}
			}
			.task {
				await self.refresh()
			}
	}
	
	private func refresh() async {
		self.selectedLog = nil
		self.logs = nil
		let url = self.baseURL.appending(component: "logs")
		do {
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
		} catch let newError {
			self.error = WrappedError(newError)
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
		guard let httpResponse = response as? HTTPURLResponse else {
			throw OperationError.malformedResponse
		}
		switch httpResponse.statusCode {
		case 200:
			return try decoder.decode(Log.self, from: data)
		case 401:
			throw OperationError.keyNotVerified
		case 403:
			throw OperationError.keyRejected
		case 500:
			throw OperationError.internalServerError
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
