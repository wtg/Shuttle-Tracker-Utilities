//
//  ContentView.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import SwiftUI

struct ContentView: View {
	
	@State private var announcement = Announcement()
	
	var body: some View {
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
			HStack {
				Button("Clear", role: .destructive) {
					print("Not implemented")
				}
				Spacer()
				Button("Submit to Server") {
					print("Not implemented")
				}
			}
		}
			.padding()
	}
	
}

struct ContentViewPreviews: PreviewProvider {
	
	static var previews: some View {
		ContentView()
	}
	
}
