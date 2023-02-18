//
//  KeyPair.swift
//  Key Management
//
//  Created by Gabriel Jacoby-Cooper on 3/15/22.
//

import CryptoKit
import SwiftUI
import UniformTypeIdentifiers

public struct KeyPair: Codable, Identifiable, Hashable, FileDocument {
	
	public static let readableContentTypes: [UTType] = [.text]
	
	public let id: UUID
	
	public let name: String
	
	private let privateKey: SecureEnclave.P256.Signing.PrivateKey
	
	var publicKey: P256.Signing.PublicKey {
		get {
			return self.privateKey.publicKey
		}
	}
	
	public init(name: String) throws {
		self.id = UUID()
		self.name = name
		self.privateKey = try SecureEnclave.P256.Signing.PrivateKey()
	}
	
	public init(configuration: ReadConfiguration) throws {
		throw KeyError.importUnsupported
	}
	
	public func signature(for data: some DataProtocol) throws -> Data {
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
	
	public static func == (lhs: KeyPair, rhs: KeyPair) -> Bool {
		return lhs.privateKey.dataRepresentation == rhs.privateKey.dataRepresentation
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
