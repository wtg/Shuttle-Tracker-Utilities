//
//  ServerSelectionSheet.swift
//  Server Selection
//
//  Created by Gabriel Jacoby-Cooper on 11/12/22.
//

import RegexBuilder
import SwiftUI

public struct ServerSelectionSheet<Item>: View {
	
	@State
	private var hasSubmitted = false
	
	@State
	private var doShowAlert = false
	
	@Binding
	private(set) var baseURL: URL
	
	private var newBaseURL: URL? {
		get {
			let regex = Regex {
				.url()
			}
			
			// wholeMatch(in:) crashes when the provided string doesn’t have a URL host component, so exit this getter early instead
			guard !self.baseURLString.hasSuffix("://") else {
				return nil
			}
			
			return try? regex.wholeMatch(in: self.baseURLString)?.output
		}
	}
	
	@State
	private var baseURLString: String
	
	@Binding
	private(set) var item: Item?
	
	public var body: some View {
		VStack {
			HStack {
				Text("Select Server")
					.font(.title3)
					.bold()
				Spacer()
			}
			Form {
				// TextField has issues with data formatters, so proxy the value through a string instead
				TextField("Base URL", text: self.$baseURLString)
					.onSubmit {
						if let newBaseURL = self.newBaseURL {
							self.baseURL = newBaseURL
							self.item = nil
						}
					}
				
				if self.newBaseURL == nil {
					Text("This URL is invalid.")
				}
			}
			HStack {
				Spacer()
				Button(role: .cancel) {
					self.item = nil
				} label: {
					Text("Cancel")
				}
					.keyboardShortcut(.cancelAction)
				Button("Save") {
					self.baseURL = self.newBaseURL! // newBaseURL should not be nil because this button would otherwise be disabled
					self.item = nil
				}
					.keyboardShortcut(.defaultAction)
					.disabled(self.newBaseURL == nil)
			}
				.padding(.top)
		}
			.padding()
			.frame(minWidth: 300)
	}
	
	public init(baseURL: Binding<URL>, item: Binding<Item?>) {
		self._baseURL = baseURL
		self._baseURLString = State(initialValue: baseURL.wrappedValue.absoluteString)
		self._item = item
	}
	
}
