//
//  Errors.swift
//  Log Retrieval Assistant
//
//  Created by Gabriel Jacoby-Cooper on 11/11/22.
//

enum OperationError: String, Error {
	
	case noKeySelected = "No key is selected"
	
	case invalidBaseURL = "Invalid base URL for the server"
	
	case malformedResponse = "Received a malformed response from the server"
	
	case keyNotVerified = "The selected key couldn’t be verified by the server"
	
	case keyRejected = "The selected key was rejected by the server"
	
	case internalServerError = "The server encountered an internal error"
	
	case unknown = "Unknown operation error"
	
}
