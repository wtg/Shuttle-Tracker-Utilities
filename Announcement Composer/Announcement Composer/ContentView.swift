//
//  ContentView.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import SwiftUI

struct ContentView: View {
	
	@State private var announcement = Announcement()
	
	@State private var selectedKeyPair: KeyPair?
	
	@AppStorage("KeyPairs") private var keyPairs = [KeyPair]()
	
	var body: some View {
		VStack {
			Form {
				Section {
					TextField("Subject", text: self.$announcement.subject, prompt: Text("Subject"))
						.labelsHidden()
					TextEditor(text: self.$announcement.body)
				} header: {
					Text("Content")
						.font(.headline)
				}
				Divider()
					.padding(.vertical, 10)
				Section {
					Toggle("Begin showing on a particular date", isOn: self.$announcement.hasStart)
					if self.announcement.hasStart {
						DatePicker("Start", selection: self.$announcement.start)
							.labelsHidden()
					}
					if self.announcement.hasStart || self.announcement.hasEnd {
						Spacer()
							.frame(height: 5)
							.padding(.bottom, 5)
					}
					Toggle("Finish showing on a particular date", isOn: self.$announcement.hasEnd)
					if self.announcement.hasEnd {
						DatePicker("End", selection: self.$announcement.end)
							.labelsHidden()
					}
				} header: {
					Text("Schedule")
						.font(.headline)
				}
				Divider()
					.padding(.vertical, 10)
				Section {
					HStack {
						Picker("Key", selection: self.$selectedKeyPair) {
							ForEach(self.keyPairs) { (keyPair) in
								Text(keyPair.name)
									.tag(Optional(keyPair))
							}
						}
							.labelsHidden()
							.disabled(self.keyPairs.isEmpty)
						Button("Open Key Manager…") {
							WindowManager.open(.keyManager)
						}
					}
				} header: {
					Text("Key")
						.font(.headline)
				}
			}
			Divider()
				.padding(.vertical, 10)
			HStack {
				Button("Clear", role: .destructive) {
					self.announcement.subject = ""
					self.announcement.body = ""
					self.announcement.hasStart = false
					self.announcement.hasEnd = false
					self.selectedKeyPair = nil
				}
				Spacer()
				Button("Submit") {
					print("Not yet implemented")
				}
					.keyboardShortcut(.defaultAction)
					.disabled(self.announcement.subject.isEmpty || self.announcement.body.isEmpty || self.selectedKeyPair == nil)
			}
		}
			.padding()
			.animation(.default, value: self.announcement.hasStart)
			.animation(.default, value: self.announcement.hasEnd)
			.toolbar {
				ToolbarItem {
					Button {
						WindowManager.open(.keyManager)
					} label: {
						Label("Key Manager", systemImage: "key")
					}
				}
			}
	}
	
}

struct ContentViewPreviews: PreviewProvider {
	
	static var previews: some View {
		ContentView()
	}
	
}
