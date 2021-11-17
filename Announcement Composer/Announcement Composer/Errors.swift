//
//  Errors.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import Foundation

enum KeyError: String, LocalizedError {
	
	case creationFailed = "Failed to create a new key"
	
}

enum SignatureError: String, LocalizedError {
	
	case dataConversionFailed = "Failed to convert the content of the announcement into raw data"
	
}
