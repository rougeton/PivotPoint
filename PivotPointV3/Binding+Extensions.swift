import SwiftUI

extension Binding {
    /// Safely unwraps an optional Binding for UI controls, providing a default value.
    /// This allows binding optional model properties to UI that requires a non-optional value.
    func unwrapped<T>(with defaultValue: T) -> Binding<T> where Value == T? {
        Binding<T>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}
