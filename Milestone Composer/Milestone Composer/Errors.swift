//
//  Errors.swift
//  Milestone Composer
//
//  Created by Gabriel Jacoby-Cooper on 3/29/22.
//

import Foundation

enum SignatureError: String, Error, RawRepresentableByString {
	
	case dataConversionFailed = "Failed to convert the content of the announcement into raw data"
	
}

enum SubmissionError: String, Error, RawRepresentableByString {
	
	case noKeySelected = "No key is selected"
	
	case invalidBaseURL = "Invalid base URL for the server"
	
	case malformedResponse = "Received a malformed response from the server"
	
	case keyNotVerified = "The selected key couldn’t be verified by the server"
	
	case keyRejected = "The selected key was rejected by the server"
	
	case internalServerError = "The server encountered an internal error"
	
	case unknown = "Unknown submission error"
	
}

enum DeletionError: String, Error, RawRepresentableByString {
	
	case noKeySelected = "No key is selected"
	
	case invalidBaseURL = "Invalid base URL for the server"
	
	case malformedResponse = "Received a malformed response from the server"
	
	case keyNotVerified = "The selected key couldn’t be verified by the server"
	
	case keyRejected = "The selected key was rejected by the server"
	
	case internalServerError = "The server encountered an internal error"
	
	case unknown = "Unknown deletion error"
	
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
