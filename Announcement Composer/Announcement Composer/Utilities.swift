//
//  Utilities.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import Foundation
import CryptoKit

protocol IdentifiableByHashValue: Identifiable, Hashable { }

extension IdentifiableByHashValue {
	
	var id: Int {
		get {
			return self.hashValue
		}
	}
	
}

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

extension Array: RawRepresentable where Element == KeyPair {
	
	public var rawValue: String {
		let encoder = JSONEncoder()
		let data = try! encoder.encode(self)
		return data.base64EncodedString()
	}
	
	public init?(rawValue: String) {
		guard let data = Data(base64Encoded: rawValue) else {
			return nil
		}
		let decoder = JSONDecoder()
		guard let keyPairs = try? decoder.decode(Self.self, from: data) else {
			return nil
		}
		self = keyPairs
	}
	
}
