//
//  Utilities.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import Foundation
import CryptoKit

enum DefaultsUtilities {
	
	static let store = UserDefaults(suiteName: "SYBLH277NF.com.gerzer.shuttletracker.composers")
	
}

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

protocol RawRepresentableByString {
	
	var rawValue: String { get }
	
}
