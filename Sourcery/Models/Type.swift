//
// Created by Krzysztof Zablocki on 11/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// Defines Swift Type
class Type: NSObject {
    internal var isExtension: Bool

    var kind: String { return isExtension ? "extension" : "class" }
    var accessLevel: AccessLevel

    /// Name in global scope 
    var name: String {
        guard let parentName = parent?.name else { return localName }
        return "\(parentName).\(localName)"
    }

    /// Is this type generic? regardless whether it's this type directly or one of its parent types
    var isGeneric: Bool {
        return (parent?.isGeneric ?? false) || hasGenericComponent
    }

    /// Name in parent scope
    var localName: String

    /// All type static variables
    var staticVariables: [Variable]

    /// All instance variables
    var variables: [Variable]

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    var annotations: [String: NSObject] = [:]

    /// Only computed instance variables
    var computedVariables: [Variable] {
        return variables.filter { $0.isComputed }
    }

    /// Only stored instance variables
    var storedVariables: [Variable] {
        return variables.filter { !$0.isComputed }
    }

    /// Types / Protocols we inherit from
    var inheritedTypes: [String]

    /// Contained types
    var containedTypes: [Type] {
        didSet {
            containedTypes.forEach { $0.parent = self }
        }
    }

    /// Parent name
    var parentName: String?

    /// Parent type
    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var parent: Type? {
        didSet {
            parentName = parent?.name
        }
    }

    /// Whether the type has generic component
    /// This is not the same as `isGeneric` because this is only local information, you should use `isGeneric`
    var hasGenericComponent: Bool = false

    /// sourcery: skipEquality
    /// Underlying parser data, never to be used by anything else
    /// sourcery: skipDescription
    internal var __parserData: Any?

    init(name: String = "", parent: Type? = nil, accessLevel: AccessLevel = .internal, isExtension: Bool = false, variables: [Variable] = [], staticVariables: [Variable] = [], inheritedTypes: [String] = [], containedTypes: [Type] = [], annotations: [String: NSObject] = [:], hasGenericComponent: Bool = false) {
        self.localName = name
        self.accessLevel = accessLevel
        self.isExtension = isExtension
        self.variables = variables
        self.staticVariables = staticVariables
        self.inheritedTypes = inheritedTypes
        self.containedTypes = containedTypes
        self.parent = parent
        self.parentName = parent?.name
        self.annotations = annotations
        self.hasGenericComponent = hasGenericComponent

        super.init()
        containedTypes.forEach { $0.parent = self }
    }

    /// Extends this type with an extension
    ///
    /// - Parameter type: Extension of this type
    func extend(_ type: Type) {
        self.variables += type.variables

        type.annotations.forEach { self.annotations[$0.key] = $0.value }
        self.inheritedTypes = Array(Set(self.inheritedTypes + type.inheritedTypes))
    }
}