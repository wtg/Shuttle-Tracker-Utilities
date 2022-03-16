//
//  Errors.swift
//  Key Management
//
//  Created by Gabriel Jacoby-Cooper on 3/15/22.
//

public enum KeyError: String, Error, RawRepresentableByString {
	
	case creationFailed = "Failed to create a new key"
	
	case serializationFailed = "Failed to serialize the public key"
	
	case importUnsupported = "Importing keys is unsupported"
	
}
