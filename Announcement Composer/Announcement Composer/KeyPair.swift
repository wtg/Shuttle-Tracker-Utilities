//
//  KeyPair.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import Foundation
import CryptoKit

public class KeyPair: Codable, Identifiable, Hashable {
	
	let name: String
	
	private let privateKey: SecureEnclave.P256.Signing.PrivateKey
	
	init(withName name: String) throws {
		self.name = name
		self.privateKey = try SecureEnclave.P256.Signing.PrivateKey()
	}
	
	public static func == (lhs: KeyPair, rhs: KeyPair) -> Bool {
		return lhs.privateKey.dataRepresentation == rhs.privateKey.dataRepresentation
	}
	
	func sign(_ data: Data) throws -> Data {
		let signature = try self.privateKey.signature(for: data)
		return signature.rawRepresentation
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.privateKey)
	}
	
}
