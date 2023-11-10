//
//  Errors.swift
//  Log Retrieval Assistant
//
//  Created by Gabriel Jacoby-Cooper on 11/11/22.
//

import Foundation
import SwiftUI

enum OperationError: LocalizedError {
	
	case noKeySelected
	
	case invalidBaseURL
	
	case malformedResponse
	
	case keyNotVerified
	
	case keyRejected
	
	case unknown
	
	var errorDescription: String? {
		get {
			switch self {
			case .noKeySelected:
				return "No key is selected."
			case .invalidBaseURL:
				return "The server base URL is invalid."
			case .malformedResponse:
				return "A malformed response from the server was received."
			case .keyNotVerified:
				return "The selected key couldn’t be verified by the server."
			case .keyRejected:
				return "The selected key was rejected by the server."
			case .unknown:
				return "An unknown operation error occurred."
			}
		}
	}
	
}

@propertyWrapper
struct WrappedError: DynamicProperty {
	
	struct Projection: LocalizedError {
		
		private static let unknownDescription = "An unknown error occurred."
		
		@Binding
		var error: (any Error)? {
			didSet {
				if self.error != nil {
					self.doShowAlert = true
				}
			}
		}
		
		@Binding
		var doShowAlert: Bool
		
		var errorDescription: String? {
			get {
				return self.error?.localizedDescription ?? Self.unknownDescription
			}
		}
		
		fileprivate init(error: Binding<(any Error)?>, doShowAlert: Binding<Bool>) {
			self._error = error
			self._doShowAlert = doShowAlert
		}
		
	}
	
	@State
	private var error: (any Error)?
	
	@State
	private var doShowAlert = false
	
	var wrappedValue: (any Error)? {
		get {
			return self.error
		}
		nonmutating set {
			self.error = newValue
			if self.error != nil {
				self.doShowAlert = true
			}
		}
	}
	
	var projectedValue: Projection {
		get {
			return Projection(error: self.$error, doShowAlert: self.$doShowAlert)
		}
	}
	
	init(wrappedValue: (any Error)?) {
		self.wrappedValue = wrappedValue
	}
	
}
