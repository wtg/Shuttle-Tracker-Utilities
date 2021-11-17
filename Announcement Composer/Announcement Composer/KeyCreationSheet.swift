//
//  KeyCreationSheet.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import SwiftUI

struct KeyCreationSheet: View {
	
	@State private var name = ""
	
	@State private var doShowAlert = false
	
	@State private var error: KeyError?
	
	@Binding private(set) var sheetType: KeyManagerView.SheetType?
	
	@AppStorage("KeyPairs") private var keyPairs = [KeyPair]()
	
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
						self.createKeyPair()
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
					self.createKeyPair()
				}
					.keyboardShortcut(.defaultAction)
			}
				.padding(.top)
		}
			.padding()
			.frame(minWidth: 300)
			.navigationTitle("Create a Key")
			.alert(isPresented: self.$doShowAlert, error: self.error) { (error) in
				Text("Continue")
			} message: { (error) in
				Text(error.rawValue)
			}
	}
	
	private func createKeyPair() {
		defer {
			self.sheetType = nil
		}
		guard let keyPair = try? KeyPair(withName: self.name) else {
			self.doShowAlert = true
			self.error = .creationFailed
			return
		}
		self.keyPairs.append(keyPair)
	}
	
}

struct KeyCreationSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		KeyCreationSheet(sheetType: .constant(.keyCreation))
	}
	
}
