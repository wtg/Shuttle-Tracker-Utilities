//
//  IdentifiableByRawValue.swift
//  KeyManagement
//
//  Created by Gabriel Jacoby-Cooper on 11/3/22.
//

public protocol IdentifiableByRawValue: RawRepresentable, Identifiable where ID == RawValue { }

extension IdentifiableByRawValue {
	
	public var id: RawValue {
		get {
			return self.rawValue
		}
	}
	
}
