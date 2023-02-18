//
//  KeyCreationSheet.swift
//  Key Management
//
//  Created by Gabriel Jacoby-Cooper on 11/3/22.
//

import SwiftUI

struct KeyCreationSheet: View {
	
	@State
	private var name = ""
	
	private var isEmptyName: Bool {
		get {
			return self.name
				.trimmingCharacters(in: .whitespacesAndNewlines)
				.isEmpty
		}
	}
	
	private var isDuplicateName: Bool {
		get {
			return self.keyPairs.contains { (keyPair) in
				return keyPair.name == self.name
			}
		}
	}
	
	@State
	private var hasSubmitted = false
	
	@State
	private var error: WrappedError?
	
	@Binding
	private(set) var sheetType: KeyManagerView.SheetType?
	
	@AppStorage("KeyPairs", store: DefaultsUtilities.store)
	private var keyPairs: [KeyPair] = []
	
	var body: some View {
		VStack {
			HStack {
				Text("Create Key")
					.font(.title3)
					.bold()
				Spacer()
			}
			Form {
				TextField("Name", text: self.$name)
					.onSubmit {
						if !self.isEmptyName && !self.isDuplicateName {
							do {
								try self.createKeyPair()
							} catch let error {
								self.error = WrappedError(error)
							}
						}
					}
				if self.isDuplicateName && !self.hasSubmitted {
					Text("This name is already taken.")
				}
			}
			HStack {
				Spacer()
				Button(role: .cancel) {
					self.sheetType = nil
				} label: {
					Text("Cancel")
				}
					.keyboardShortcut(.cancelAction)
				Button("Create") {
					do {
						try self.createKeyPair()
					} catch let error {
						self.error = WrappedError(error)
					}
				}
					.keyboardShortcut(.defaultAction)
					.disabled(self.isEmptyName || self.isDuplicateName)
			}
				.padding(.top)
		}
			.padding()
			.frame(minWidth: 300)
			.alert(isPresented: self.$error.isNotNil, error: self.error) { (error) in
				Button("Continue") { }
			} message: { (error) in
				EmptyView()
			}
	}
	
	private func createKeyPair() throws {
		defer {
			self.sheetType = nil
		}
		let keyPair = try KeyPair(name: self.name)
		self.keyPairs.append(keyPair)
		self.hasSubmitted = true
	}
	
}

struct KeyCreationSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		KeyCreationSheet(sheetType: .constant(.keyCreation))
	}
	
}
