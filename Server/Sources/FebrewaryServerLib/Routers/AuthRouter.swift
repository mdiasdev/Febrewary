//
//  AuthRouter.swift
//  COpenSSL
//
//  Created by Matthew Dias on 7/30/19.
//

import Foundation
import PerfectHTTP

public class AuthRouter: Router {
    override func initRoutes() {
        routes.add(Route(method: .post, uri: "register", handler: register))
        routes.add(Route(method: .post, uri: "login", handler: login))
    }
    
    func register(request: HTTPRequest, response: HTTPResponse) {
        AuthController().register(request: request, response: response)
    }
    
    func login(request: HTTPRequest, response: HTTPResponse) {
        AuthController().login(request: request, response: response)
    }
}
