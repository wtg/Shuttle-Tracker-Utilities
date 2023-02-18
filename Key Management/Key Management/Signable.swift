//
//  Signable.swift
//  Key Management
//
//  Created by Gabriel Jacoby-Cooper on 11/11/22.
//

public typealias Signable = SignableForSubmission & SignableForDeletion

public protocol SignableForSubmission {
	
	var signature: Data? { get set }
	
	var dataToSign: Data? { get }
	
	init(asSignedVersionOf unsigned: Self, using keyPair: KeyPair) throws
	
}

extension SignableForSubmission {
	
	public init(asSignedVersionOf unsigned: Self, using keyPair: KeyPair) throws {
		self = unsigned
		guard let data = self.dataToSign else {
			throw SignatureError.dataConversionFailed
		}
		self.signature = try keyPair.signature(for: data)
	}
	
	public func signed(using keyPair: KeyPair) throws -> Self {
		return try Self(asSignedVersionOf: self, using: keyPair)
	}
	
}

public protocol SignableForDeletion {
	
	associatedtype DeletionRequest
	
	func signatureForDeletion(using keyPair: KeyPair) throws -> Data
	
	func deletionRequest(signedUsing keyPair: KeyPair) throws -> DeletionRequest
	
}

extension SignableForDeletion where Self: Identifiable, ID == UUID {
	
	public func signatureForDeletion(using keyPair: KeyPair) throws -> Data {
		guard let data = self.id.uuidString.data(using: .utf8) else {
			throw SignatureError.dataConversionFailed
		}
		return try keyPair.signature(for: data)
	}
	
}

public struct SimpleDeletionRequest: Encodable {
	
	let signature: Data
	
}

extension SignableForDeletion where DeletionRequest == SimpleDeletionRequest {
	
	public func deletionRequest(signedUsing keyPair: KeyPair) throws -> DeletionRequest {
		let signature = try self.signatureForDeletion(using: keyPair)
		return SimpleDeletionRequest(signature: signature)
	}
	
}
