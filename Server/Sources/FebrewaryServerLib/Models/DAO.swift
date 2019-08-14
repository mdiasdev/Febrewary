//
//  DAO.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 7/30/19.
//

import Foundation
import StORM
import PostgresStORM

class DAO: PostgresStORM {
    
    var id: Int = 0
    
    // MARK: - Functions
    func isValid() -> Bool {
        return id > 0
    }
    
    // MARK: - Wrappers for abstraction/overriding
    /// Wrapper to PostgresStORM's `findAll()`
    ///
    /// - Throws:
    func getAll() throws {
        try findAll()
    }
    
    
    /// Wrapper to PostgresStORM's `find()`
    ///
    /// - Parameter data: dictionary of properties to base find on
    /// - Throws:
    func find(by data: [String: Any]) throws {
        try find(data)
    }
    
    
    /// Wrapper to PostgresStORM's `find()`
    ///
    /// - Parameter data: array of tuples representing properto to base find on
    /// - Throws: 
    func find(by data: [(String, Any)]) throws {
        try find(data)
    }
    
    
    /// Wrapper to PostgresStORM's `save(set:)`
    ///
    /// - Parameter set: closure to set `id` from
    /// - Throws:
    func store(set: (Any) -> Void) throws {
        try save(set: set)
    }
    
    
    /// Wrapper to PostgresStORM's `save()`
    ///
    /// - Throws:
    func store() throws {
        try save()
    }
    
    
    /// Wrapper to PostgresStORM's `select(whereclause:, params:, orderby:)`
    ///
    /// - Parameters:
    ///   - whereClause: query meeting postgres formatting
    ///   - params: paramters to pass into whereclause
    ///   - orderby: sort the rows by column names
    func search(whereClause: String, params: [Any], orderby: [String]) throws {
        try select(whereclause: whereClause, params: params, orderby: orderby)
    }
}
