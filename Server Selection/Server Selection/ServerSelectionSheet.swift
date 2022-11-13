//
//  ServerSelectionSheet.swift
//  Server Selection
//
//  Created by Gabriel Jacoby-Cooper on 11/12/22.
//

import KeyManagement
import SwiftUI

public struct ServerSelectionSheet<SheetType>: View {
	
	@State
	private var hasSubmitted = false
	
	@State
	private var doShowAlert = false
	
	@State
	private var error: WrappedError?
	
	@Binding
	private(set) var baseURL: URL
	
	@State
	private var baseURLString: String
	
	@Binding
	private(set) var sheetType: SheetType?
	
	private var isValidURLString: Bool {
		get {
			let isEmpty = self.baseURLString
				.trimmingCharacters(in: .whitespacesAndNewlines)
				.isEmpty
			return !isEmpty && URL(string: self.baseURLString) != nil
		}
	}
	
	public var body: some View {
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
						if !self.isValidURLString {
							self.baseURL = URL(string: self.baseURLString)!
							self.sheetType = nil
						}
					}
				if !self.isValidURLString {
					Text("This URL is invalid.")
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
				Button("Save") {
					self.baseURL = URL(string: self.baseURLString)!
					self.sheetType = nil
				}
				.keyboardShortcut(.defaultAction)
				.disabled(!self.isValidURLString)
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
	
	public init(baseURL: Binding<URL>, sheetType: Binding<SheetType?>) {
		self._baseURL = baseURL
		self._baseURLString = State(initialValue: baseURL.wrappedValue.absoluteString)
		self._sheetType = sheetType
	}
	
}
