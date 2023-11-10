//
//  Errors.swift
//  Key Management
//
//  Created by Gabriel Jacoby-Cooper on 3/15/22.
//

enum KeyError: LocalizedError {
	
	case serializationFailed
	
	case importUnsupported
	
	var errorDescription: String? {
		get {
			switch self {
			case .serializationFailed:
				return "Serialization of the public key failed."
			case .importUnsupported:
				return "Importing public keys is unsupported."
			}
		}
	}
	
}

enum SignatureError: LocalizedError {
	
	case dataConversionFailed
	
	var errorDescription: String? {
		get {
			switch self {
			case .dataConversionFailed:
				return "Conversion of the content into raw data failed."
			}
		}
	}
	
}

enum UnknownError: LocalizedError {
	
	case unknown
	
	var errorDescription: String? {
		get {
			switch self {
			case .unknown:
				return "An unknown error occurred."
			}
		}
	}
	
}

public struct WrappedError: LocalizedError {
	
	private var error: any Error
	
	public var errorDescription: String? {
		get {
			return self.error.localizedDescription
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
