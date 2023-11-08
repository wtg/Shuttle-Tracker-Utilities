//
//  LogDetailView.swift
//  Log Retrieval Assistant
//
//  Created by Gabriel Jacoby-Cooper on 11/11/22.
//

import KeyManagement
import SwiftUI

struct LogDetailView: View {
	
	@Binding
	private var logs: Set<Log>
	
	private let baseURL: URL
	
	private let keyPair: KeyPair?
	
	private let refresh: () async throws -> Void
	
	@State
	private var doTriggerDeletion = false
	
	@WrappedError
	private var error: (any Error)?
	
	var body: some View {
		Group {
			if self.logs.isEmpty {
				Text("No Log Selected")
					.font(.title2)
					.multilineTextAlignment(.center)
					.foregroundColor(.secondary)
					.padding()
			} else {
				ScrollView {
					HStack {
						VStack(alignment: .leading) {
							if self.logs.count == 1 {
								let log = self.logs.first!
								LogContentView(log: log)
									.navigationSubtitle(log.id.uuidString)
							} else { // There are guaranteed to be two or more logs at this point
								Group {
									let sortedLogs = Array(self.logs)
										.sorted { (first, second) in
											return first.date < second.date
										}
										.reversed()
									LogContentView(log: sortedLogs.first!, doShowID: true)
									ForEach(sortedLogs.dropFirst()) { (log) in
										Divider()
										LogContentView(log: log, doShowID: true)
									}
								}
									.navigationSubtitle("\(self.logs.count) Logs Selected")
							}
						}
						Spacer(minLength: 0)
					}
						.padding(.horizontal, 10)
						.padding(.vertical)
				}
			}
		}
			.frame(minWidth: 500)
			.toolbar {
				Button(role: .destructive) {
					self.doTriggerDeletion = true
				} label: {
					Label("Delete…", systemImage: "trash")
				}
					.keyboardShortcut(.delete, modifiers: [])
					.disabled(self.logs.isEmpty || self.keyPair == nil)
				if self.logs.count == 1, let url = try? self.logs.first!.writeToDisk() {
					ShareLink(item: url)
					Button {
						NSWorkspace.shared.open(url)
					} label: {
						Label("Open in Log Viewer", systemImage: "arrowshape.turn.up.forward")
					}
				}
			}
			.alert(isPresented: self.$error.$doShowAlert, error: self.$error) {
				Button("Dismiss") { }
			}
			.logDeletion(
				self.$logs,
				isTriggered: self.$doTriggerDeletion,
				baseURL: self.baseURL,
				keyPair: self.keyPair,
				errorProjection: self.$error,
				refresh: self.refresh
			)
	}
	
	init(
		logs: Binding<Set<Log>>,
		baseURL: URL,
		keyPair: KeyPair?,
		refresh: @escaping () async throws -> Void
	) {
		self._logs = logs
		self.baseURL = baseURL
		self.keyPair = keyPair
		self.refresh = refresh
	}
	
}

struct LogDeletion: ViewModifier {
	
	@Binding
	private var logs: Set<Log>
	
	@Binding
	private var isTriggered: Bool
	
	private let baseURL: URL
	
	private let keyPair: KeyPair?
	
	private let errorProjection: WrappedError.Projection
	
	private let refresh: () async throws -> Void
	
	@State
	private var doShowSuccessAlert = false
	
	func body(content: Content) -> some View {
		return content
			.confirmationDialog("Delete Log\(self.logs.count == 1 ? "" : "s")", isPresented: self.$isTriggered) {
				Button("Cancel", role: .cancel) { }
					.keyboardShortcut(.cancelAction)
				if !self.logs.isEmpty {
					Button("Delete", role: .destructive) {
						Task {
							do {
								guard let keyPair = self.keyPair else {
									throw OperationError.noKeySelected
								}
								try await self.logs.delete(baseURL: self.baseURL, keyPair: keyPair)
								self.doShowSuccessAlert = true
								try await self.refresh()
							} catch {
								self.errorProjection.error = error
							}
						}
					}
				}
			} message: {
				if self.logs.count == 1 {
					Text("Are you sure that you want to delete this log? You can’t undo this action.")
				} else if self.logs.count > 1 {
					Text("Are you sure that you want to delete these \(self.logs.count) logs? You can’t undo this action.")
				} else {
					Text("No logs are selected.")
				}
			}
			.alert("The deletion was successful!", isPresented: self.$doShowSuccessAlert) {
				Button("Dismiss") { }
			}
	}
	
	init(
		_ logs: Binding<Set<Log>>,
		isTriggered: Binding<Bool>,
		baseURL: URL,
		keyPair: KeyPair?,
		errorProjection: WrappedError.Projection,
		refresh: @escaping () async throws -> Void
	) {
		self._logs = logs
		self._isTriggered = isTriggered
		self.baseURL = baseURL
		self.keyPair = keyPair
		self.errorProjection = errorProjection
		self.refresh = refresh
	}
	
}

extension View {
	
	func logDeletion(
		_ logs: Binding<Set<Log>>,
		isTriggered: Binding<Bool>,
		baseURL: URL,
		keyPair: KeyPair?,
		errorProjection: WrappedError.Projection,
		refresh: @escaping () async throws -> Void
	) -> some View {
		return self.modifier(
			LogDeletion(
				logs,
				isTriggered: isTriggered,
				baseURL: baseURL,
				keyPair: keyPair,
				errorProjection: errorProjection,
				refresh: refresh
			)
		)
	}
	
}
