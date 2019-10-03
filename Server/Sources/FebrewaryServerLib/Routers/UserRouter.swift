//
//  UserRouter.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 7/30/19.
//

import Foundation
import PerfectHTTP

public class UserRouter: Router {
    override func initRoutes() {
        routes.add(Route(method: .get, uri: "user", handler: auth &&& getCurrentUser))
        routes.add(Route(method: .get, uri: "user/{id}", handler: auth &&& getUserById))
        routes.add(Route(method: .get, uri: "users", handler: auth &&& getAllUsers))
    }
    
    func getCurrentUser(request: HTTPRequest, response: HTTPResponse) {
        UserController().getCurrentUser(request: request, response: response)
    }
    
    func getUserById(request: HTTPRequest, response: HTTPResponse) {
        UserController().getUserById(request: request, response: response)
    }
    
    func getAllUsers(request: HTTPRequest, response: HTTPResponse) {
        UserController().getAllUsers(request: request, response: response)
    }
}
