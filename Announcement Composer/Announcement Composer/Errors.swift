//
//  Errors.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import Foundation

enum SubmissionError: LocalizedError {
	
	case noKeySelected
	
	case invalidBaseURL
	
	case malformedResponse
	
	case keyNotVerified
	
	case keyRejected
	
	case internalServerError
	
	case unknown
	
	var errorDescription: String? {
		get {
			switch self {
			case .noKeySelected:
				return "No key is selected."
			case .invalidBaseURL:
				return "The server base URL is invalid."
			case .malformedResponse:
				return "The server sent a malformed response."
			case .keyNotVerified:
				return "The server couldn’t verify the selected key."
			case .keyRejected:
				return "The server rejected the selected key."
			case .internalServerError:
				return "The server encountered an internal error."
			case .unknown:
				return "An unknown submission error occurred."
			}
		}
	}
	
}

enum DeletionError: LocalizedError {
	
	case noKeySelected
	
	case invalidBaseURL
	
	case malformedResponse
	
	case keyNotVerified
	
	case keyRejected
	
	case internalServerError
	
	case unknown
	
	var errorDescription: String? {
		get {
			switch self {
			case .noKeySelected:
				return "No key is selected."
			case .invalidBaseURL:
				return "The server base URL is invalid."
			case .malformedResponse:
				return "The server sent a malformed response."
			case .keyNotVerified:
				return "The server couldn’t verify the selected key."
			case .keyRejected:
				return "The server rejected the selected key."
			case .internalServerError:
				return "The server encountered an internal error."
			case .unknown:
				return "An unknown deletion error occurred."
			}
		}
	}
	
}
