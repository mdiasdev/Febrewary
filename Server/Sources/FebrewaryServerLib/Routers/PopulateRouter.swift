//
//  PopulateRouter.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 9/24/19.
//

import Foundation
import PerfectHTTP

public class PopulateRouter: Router {
    override func initRoutes() {
        routes.add(Route(method: .get, uri: "populate", handler: populate))
    }
    
    func populate(request: HTTPRequest, response: HTTPResponse) {
        PopulateController().populate(request: request, response: response)
    }
}

