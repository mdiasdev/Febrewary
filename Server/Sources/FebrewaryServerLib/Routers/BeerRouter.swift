//
//  BeerRouter.swift
//  COpenSSL
//
//  Created by Matthew Dias on 7/30/19.
//

import Foundation
import PerfectHTTP

public class BeerRouter: Router {
    override func initRoutes() {
        // MARK: Unauthenticated Routes
        routes.add(Route(method: .get, uri: "beers", handler: allBeers))
        routes.add(Route(method: .get, uri: "beer/search", handler: searchBeers))

        // MARK: Authenticated Routes
        routes.add(Route(method: .get, uri: "beer", handler: auth &&& getBeers))
        routes.add(Route(method: .post, uri: "beer", handler: auth &&& addBeer))
    }
    
    func allBeers(request: HTTPRequest, response: HTTPResponse) {
        BeerController().allBeers(request: request, response: response)
    }
    
    func searchBeers(request: HTTPRequest, response: HTTPResponse) {
        BeerController().searchBeers(request: request, response: response)
    }
    
    func getBeers(request: HTTPRequest, response: HTTPResponse) {
        BeerController().beersForCurrentUser(request: request, response: response)
    }
    
    func addBeer(request: HTTPRequest, response: HTTPResponse) {
        BeerController().addBeer(request: request, response: response)
    }
}
