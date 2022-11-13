//
//  Errors.swift
//  Milestone Composer
//
//  Created by Gabriel Jacoby-Cooper on 3/29/22.
//

enum SubmissionError: String, Error {
	
	case noKeySelected = "No key is selected"
	
	case invalidBaseURL = "Invalid base URL for the server"
	
	case malformedResponse = "Received a malformed response from the server"
	
	case keyNotVerified = "The selected key couldn’t be verified by the server"
	
	case keyRejected = "The selected key was rejected by the server"
	
	case internalServerError = "The server encountered an internal error"
	
	case unknown = "Unknown submission error"
	
}

enum DeletionError: String, Error {
	
	case noKeySelected = "No key is selected"
	
	case invalidBaseURL = "Invalid base URL for the server"
	
	case malformedResponse = "Received a malformed response from the server"
	
	case keyNotVerified = "The selected key couldn’t be verified by the server"
	
	case keyRejected = "The selected key was rejected by the server"
	
	case internalServerError = "The server encountered an internal error"
	
	case unknown = "Unknown deletion error"
	
}
