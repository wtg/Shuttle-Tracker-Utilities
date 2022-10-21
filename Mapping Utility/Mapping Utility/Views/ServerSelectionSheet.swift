//
//  ServerSelectionSheet.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 5/14/22.
//

import SwiftUI

struct ServerSelectionSheet: View {
	
	@State private var baseURLString: String
	
	@State private var hasSubmitted = false
	
	@State private var doShowAlert = false
	
	@Binding private(set) var sheetType: ContentView.SheetType?
	
	var body: some View {
		VStack {
			HStack {
				Text("Select Server")
					.font(.title3)
					.bold()
				Spacer()
			}
			Form {
				TextField("Base URL", text: self.$baseURLString)
					.onSubmit {
						if let baseURL = self.sanitizedBaseURL() {
							API.baseURL = baseURL
							self.sheetType = nil
							Task {
								await MapState.shared.refresh()
							}
						}
					}
				if self.sanitizedBaseURL() == nil {
					Text("This URL is invalid.")
				}
			}
			HStack {
				Spacer()
				Button("Cancel", role: .cancel) {
					self.sheetType = nil
				}
					.keyboardShortcut(.cancelAction)
				Button("Save") {
					if let baseURL = URL(string: self.baseURLString) {
						API.baseURL = baseURL
					}
					self.sheetType = nil
				}
					.keyboardShortcut(.defaultAction)
					.disabled(self.sanitizedBaseURL() == nil)
			}
				.padding(.top)
		}
			.padding()
			.frame(minWidth: 300)
	}
	
	init(sheetType: Binding<ContentView.SheetType?>) {
		self._sheetType = sheetType
		self._baseURLString = State(initialValue: API.baseURL.absoluteString)
	}
	
	func sanitizedBaseURL() -> URL? {
		let isEmpty = self.baseURLString
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.isEmpty
		guard !isEmpty, let baseURL = URL(string: self.baseURLString) else {
			return nil
		}
		return baseURL
	}
	
}

struct ServerSelectionSheetPreviews: PreviewProvider {
	
	static var previews: some View {
		ServerSelectionSheet(
			sheetType: .constant(.serverSelection)
		)
	}
	
}
