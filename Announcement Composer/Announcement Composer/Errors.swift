//
//  Errors.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import SwiftUI

enum KeyError: String, Error, RawRepresentableByString {
	
	case creationFailed = "Failed to create a new key"
	
	case serializationFailed = "Failed to serialize the public key"
	
	case importUnsupported = "Importing keys is unsupported"
	
}

enum SignatureError: String, Error, RawRepresentableByString {
	
	case dataConversionFailed = "Failed to convert the content of the announcement into raw data"
	
}

enum SubmissionError: String, Error, RawRepresentableByString {
	
	case noKeySelected = "No key is selected"
	
	case invalidBaseURL = "Invalid base URL for the server"
	
}

enum UnknownError: String, Error, RawRepresentableByString {
	
	case unknown = "Unknown error"
	
}

struct WrappedError: LocalizedError {
	
	private var error: Error
	
	var errorDescription: String? {
		get {
			if let error = self.error as? RawRepresentableByString {
				return error.rawValue
			} else {
				return self.error.localizedDescription
			}
		}
	}
	
	init(_ error: Error) {
		self.error = error
	}
	
	mutating func replace(with error: Error) {
		self.error = error
	}
	
}

extension Optional where Wrapped == WrappedError {
	
	var isNotNil: Bool {
		get {
			return self != nil
		}
		set {
			if newValue {
				if self == nil {
					self = WrappedError(UnknownError.unknown)
				}
			} else {
				self = nil
			}
		}
	}
	
}
