//
//  LazyServer.swift
//  ServerSelection
//
//  Created by Gabriel Jacoby-Cooper on 12/1/23.
//

import SwiftUI

@propertyWrapper
public struct LazyServer: DynamicProperty {
	
	@State
	private var value: Server?
	
	private let initialValue: () -> Server
	
	public var wrappedValue: Server {
		get {
			return self.value ?? self.initialValue()
		}
		nonmutating set {
			self.value = newValue
		}
	}
	
	public var projectedValue: Binding<Server> {
		get {
			return Binding {
				return self.wrappedValue
			} set: { (newValue) in
				self.wrappedValue = newValue
			}
		}
	}
	
	public init(wrappedValue: @autoclosure @escaping () -> Server) {
		self.initialValue = wrappedValue
	}
	
}
