//
//  ServerSelectionSheet.swift
//  Mapping Utility
//
//  Created by Gabriel Jacoby-Cooper on 5/14/22.
//

import SwiftUI

struct ServerSelectionSheet: View {
	
	@State
	private var baseURLString = API.baseURL.absoluteString
	
	@State
	private var hasSubmitted = false
	
	@State
	private var doShowAlert = false
	
	@Binding
	private var sheetType: ContentView.SheetType?
	
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
								await MapState.shared.refreshAll()
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
					guard let baseURL = self.sanitizedBaseURL() else {
						return
					}
					API.baseURL = baseURL
					self.sheetType = nil
				}
					.disabled(self.sanitizedBaseURL() == nil)
					.keyboardShortcut(.defaultAction)
			}
				.padding(.top)
		}
			.padding()
			.frame(minWidth: 300)
	}
	
	init(sheetType: Binding<ContentView.SheetType?>) {
		self._sheetType = sheetType
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

#Preview {
	ServerSelectionSheet(sheetType: .constant(.serverSelection))
}
