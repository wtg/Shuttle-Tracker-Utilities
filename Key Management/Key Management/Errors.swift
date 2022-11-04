//
//  Errors.swift
//  Key Management
//
//  Created by Gabriel Jacoby-Cooper on 3/15/22.
//

enum KeyError: String, Error {
	
	case creationFailed = "Failed to create a new key"
	
	case serializationFailed = "Failed to serialize the public key"
	
	case importUnsupported = "Importing keys is unsupported"
	
}

enum UnknownError: String, Error {
	
	case unknown = "Unknown error"
	
}

public struct WrappedError: LocalizedError {
	
	private var error: any Error
	
	public var errorDescription: String? {
		get {
			if let error = self.error as? any RawRepresentable<String> {
				return error.rawValue
			} else {
				return self.error.localizedDescription
			}
		}
	}
	
	public init(_ error: any Error) {
		self.error = error
	}
	
	mutating func replace(with error: any Error) {
		self.error = error
	}
	
}

extension Optional where Wrapped == WrappedError {
	
	public var isNotNil: Bool {
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
