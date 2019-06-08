//
//  UserController.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 6/1/19.
//

import Foundation
import PerfectHTTP
import PerfectCrypto
import StORM

public class UserController: RouteController {
    override func initRoutes() {
        routes.add(Route(method: .get, uri: "user", handler: getUser))
        routes.add(Route(method: .get, uri: "user/{id}", handler: getUserById))
    }
    
    // MARK: - Endpoints
    func getUser(request: HTTPRequest, response: HTTPResponse) {
    }
    
    func getUserById(request: HTTPRequest, response: HTTPResponse) {
    }
}
