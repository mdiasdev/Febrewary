//
//  OptionalExtension.swift
//  Febrewary
//
//  Created by Matthew Dias on 6/16/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

/// https://stackoverflow.com/a/55221308
extension Optional: Comparable where Wrapped: Comparable {
    
    // MARK: - Optional <=> Optional
    
    public static func < (lhs: Optional<Wrapped>, rhs: Optional<Wrapped>) -> Bool {
        switch lhs {
        case .some(let v): return v < rhs
        case .none: return false
        }
    }
    
    public static func <= (lhs: Optional<Wrapped>, rhs: Optional<Wrapped>) -> Bool {
        switch lhs {
        case .some(let v): return v <= rhs
        case .none: return false
        }
    }
    
    public static func >= (lhs: Optional<Wrapped>, rhs: Optional<Wrapped>) -> Bool {
        switch lhs {
        case .some(let v): return v >= rhs
        case .none: return false
        }
    }
    
    public static func > (lhs: Optional<Wrapped>, rhs: Optional<Wrapped>) -> Bool {
        switch lhs {
        case .some(let v): return v > rhs
        case .none: return false
        }
    }
    
    
    // MARK: - Optional <=> Wrapped
    
    public static func < (lhs: Optional<Wrapped>, rhs: Wrapped) -> Bool {
        switch lhs {
        case .some(let v): return v < rhs
        case .none: return false
        }
    }
    
    public static func <= (lhs: Optional<Wrapped>, rhs: Wrapped) -> Bool {
        switch lhs {
        case .some(let v): return v <= rhs
        case .none: return false
        }
    }
    
    public static func >= (lhs: Optional<Wrapped>, rhs: Wrapped) -> Bool {
        switch lhs {
        case .some(let v): return v >= rhs
        case .none: return false
        }
    }
    
    public static func > (lhs: Optional<Wrapped>, rhs: Wrapped) -> Bool {
        switch lhs {
        case .some(let v): return v > rhs
        case .none: return false
        }
    }
    
    
    // MARK: - Wrapped <=> Optional
    
    public static func < (lhs: Wrapped, rhs: Optional<Wrapped>) -> Bool {
        switch rhs {
        case .some(let v): return lhs < v
        case .none: return false
        }
    }
    
    public static func <= (lhs: Wrapped, rhs: Optional<Wrapped>) -> Bool {
        switch rhs {
        case .some(let v): return lhs <= v
        case .none: return false
        }
    }
    
    public static func >= (lhs: Wrapped, rhs: Optional<Wrapped>) -> Bool {
        switch rhs {
        case .some(let v): return lhs >= v
        case .none: return false
        }
    }
    
    public static func > (lhs: Wrapped, rhs: Optional<Wrapped>) -> Bool {
        switch rhs {
        case .some(let v): return lhs > v
        case .none: return false
        }
    }
}
