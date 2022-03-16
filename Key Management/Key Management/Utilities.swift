//
//  Utilities.swift
//  Key Management
//
//  Created by Gabriel Jacoby-Cooper on 3/15/22.
//

import Foundation
import CryptoKit

extension SecureEnclave.P256.Signing.PrivateKey: Codable, Hashable {
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let dataRepresentation = try container.decode(Data.self)
		try self.init(dataRepresentation: dataRepresentation)
	}
	
	public static func == (lhs: SecureEnclave.P256.Signing.PrivateKey, rhs: SecureEnclave.P256.Signing.PrivateKey) -> Bool {
		return lhs.dataRepresentation == rhs.dataRepresentation
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(self.dataRepresentation)
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.dataRepresentation)
	}
	
}

protocol RawRepresentableByString {
	
	var rawValue: String { get }
	
}
