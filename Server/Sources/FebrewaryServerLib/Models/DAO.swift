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
    func retrieve(_ data: [String: Any]) throws {
        try find(data)
    }
    
    
    /// Wrapper to PostgresStORM's `save()`
    ///
    /// - Parameter set: closure to set `id` from
    /// - Throws:
    func store(set: (Any) -> Void) throws {
        try save(set: set)
    }
    
    
    /// Wrapper to PostgresStORM's `select()`
    ///
    /// - Parameters:
    ///   - whereClause: query meeting postgres formatting
    ///   - params: paramters to pass into whereclause
    ///   - orderby: sort the rows by column names
    func search(whereClause: String, params: [Any], orderby: [String]) throws {
        try select(whereclause: whereClause, params: params, orderby: orderby)
    }
}
