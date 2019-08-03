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
        routes.add(Route(method: .post, uri: "beer", handler: addBeer))
        routes.add(Route(method: .get, uri: "beer", handler: getBeers))
        routes.add(Route(method: .get, uri: "beers", handler: allBeers))
    }
    
    func addBeer(request: HTTPRequest, response: HTTPResponse) {
        BeerController().addBeer(request: request, response: response)
    }
    
    func getBeers(request: HTTPRequest, response: HTTPResponse) {
        if let searchQuery = request.queryParamsAsDictionary()["query"] {
            BeerController().searchBeers(request: request, response: response, query: searchQuery)
        } else {
            BeerController().beersForCurrentUser(request: request, response: response)
        }
    }
    
    func allBeers(request: HTTPRequest, response: HTTPResponse) {
        BeerController().allBeers(request: request, response: response)
    }
}
