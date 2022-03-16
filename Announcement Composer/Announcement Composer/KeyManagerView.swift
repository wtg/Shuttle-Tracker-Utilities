//
//  KeyManagerView.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import SwiftUI

struct KeyManagerView: View {
	
	enum SheetType: IdentifiableByHashValue {
		
		case keyCreation
		
	}
	
	@State private var sheetType: SheetType?
	
	@State private var doShowConfirmationDialog = false
	
	@State private var doShowFileExporter = false
	
	@State private var selectedKeyPairs = Set<KeyPair>()
	
	@State private var selectedKeyPairForExport: KeyPair?
	
	@AppStorage("KeyPairs", store: DefaultsUtilities.store) private var keyPairs: [KeyPair] = []
	
	var body: some View {
		List(self.keyPairs, selection: self.$selectedKeyPairs) { (keyPair) in
			Text(keyPair.name)
				.contextMenu {
					Button("Export…") {
						self.selectedKeyPairForExport = keyPair
						self.doShowFileExporter = true
					}
					Divider()
					Button("Delete…", role: .destructive) {
						if !self.selectedKeyPairs.contains(keyPair) {
							self.selectedKeyPairs = [keyPair]
						}
						self.doShowConfirmationDialog = true
					}
				}
		}
			.listStyle(.inset(alternatesRowBackgrounds: true))
			.navigationTitle("Key Manager")
			.toolbar {
				ToolbarItem {
					Button {
						self.sheetType = .keyCreation
					} label: {
						Label("Create", systemImage: "plus")
					}
						.keyboardShortcut("n", modifiers: [.command, .shift])
				}
			}
			.fileExporter(isPresented: self.$doShowFileExporter, document: self.selectedKeyPairForExport, contentType: .text, defaultFilename: "Key.pem") { (_) in }
			.confirmationDialog("Delete \(self.selectedKeyPairs.count) \(self.selectedKeyPairs.count == 1 ? "Key" : "Keys")", isPresented: self.$doShowConfirmationDialog) {
				Button("Cancel", role: .cancel) { }
					.keyboardShortcut(.cancelAction)
				Button("Delete", role: .destructive) {
					for selectedKeyPair in selectedKeyPairs {
						self.keyPairs.removeAll { (keyPair) in
							return keyPair == selectedKeyPair
						}
					}
				}
			} message: {
				Text("Are you sure that you want to delete the selected \(self.selectedKeyPairs.count == 1 ? "key" : "keys")? You can’t undo this action.")
			}
			.sheet(item: self.$sheetType) { (sheetType) in
				switch sheetType {
				case .keyCreation:
					KeyCreationSheet(sheetType: self.$sheetType)
				}
			}
	}
	
}

struct KeyManagerViewPreviews: PreviewProvider {
	
	static var previews: some View {
		KeyManagerView()
	}
	
}
