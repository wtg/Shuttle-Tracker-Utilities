//
//  KeyPair.swift
//  Announcement Composer
//
//  Created by Gabriel Jacoby-Cooper on 11/16/21.
//

import SwiftUI
import CryptoKit
import UniformTypeIdentifiers

public struct KeyPair: Codable, Identifiable, Hashable, FileDocument {
	
	public static var readableContentTypes: [UTType] = [.text]
	
	public var id = UUID()
	
	let name: String
	
	private let privateKey: SecureEnclave.P256.Signing.PrivateKey
	
	var publicKey: P256.Signing.PublicKey {
		get {
			return self.privateKey.publicKey
		}
	}
	
	init(name: String) throws {
		self.name = name
		self.privateKey = try SecureEnclave.P256.Signing.PrivateKey()
	}
	
	public init(configuration: ReadConfiguration) throws {
		throw KeyError.importUnsupported
	}
	
	public static func == (lhs: KeyPair, rhs: KeyPair) -> Bool {
		return lhs.privateKey.dataRepresentation == rhs.privateKey.dataRepresentation
	}
	
	func signature(for data: Data) throws -> Data {
		let signature = try self.privateKey.signature(for: data)
		return signature.rawRepresentation
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.privateKey)
	}
	
	public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		guard let contents = self.publicKey.pemRepresentation.data(using: .utf8) else {
			throw KeyError.serializationFailed
		}
		return FileWrapper(regularFileWithContents: contents)
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
