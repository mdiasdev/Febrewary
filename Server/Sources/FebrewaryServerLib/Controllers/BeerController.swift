import PerfectHTTP
import StORM
import Foundation

public class BeerController: Router {
    override func initRoutes() {
        routes.add(Route(method: .post, uri: "beer", handler: addBeer))
        routes.add(Route(method: .get, uri: "beer", handler: getBeers))
        routes.add(Route(method: .get, uri: "beers", handler: allBeers))
    }

    func addBeer(request: HTTPRequest, response: HTTPResponse) {
        do {
            
            guard request.hasValidToken(), let email = request.emailFromAuthToken() else {
                response.setBody(string: "Unauthorized")
                        .completed(status: .unauthorized)
                return
            }
            
            let user = User()
            try user.find(["email": email])
            
            guard user.id != 0 else {
                response.setBody(string: "Unauthorized")
                        .completed(status: .unauthorized)
                return
            }

            guard let postBody = try? request.postBodyString?.jsonDecode() as? [String: Any], let json = postBody else {
                response.setBody(string: "Bad Request: malformed json")
                        .completed(status: .badRequest)
                return
            }

            guard let beerName = json["name"] as? String,
                  let brewerName = json["brewer"] as? String,
                  let abv = json["abv"] as? NSNumber else {
                response.setBody(string: "Missing data.")
                        .completed(status: .badRequest)
                return
            }

            let beer = Beer()
            try beer.find(
                ["name": beerName,
                 "brewer": brewerName
                ]
            )

            guard beer.id == 0 else {
                response.setBody(string: "Beer already exists")
                        .completed(status: .conflict)
                return
            }

            beer.name = beerName
            beer.brewer = brewerName
            beer.abv = abv.floatValue
            beer.addedBy = user.id

            try beer.save { id in
                beer.id = id as! Int
            }
            
            try response.setBody(json: beer.asDictionary())
                        .completed(status: .created)

        } catch {
            response.completed(status: .internalServerError)
        }
    }
    
    func getBeers(request: HTTPRequest, response: HTTPResponse) {
        if let searchQuery = request.queryParamsAsDictionary()["query"] {
            
            searchBeers(request: request, response: response, query: searchQuery)
        } else {
            beersForCurrentUser(request: request, response: response)
        }
    }
    
    func beersForCurrentUser(request: HTTPRequest, response: HTTPResponse) {
        guard request.hasValidToken(), let email = request.emailFromAuthToken() else {
            response.setBody(string: "Unauthorized")
                .completed(status: .unauthorized)
            return
        }
        
        do {
            let user = User()
            try user.find(["email": email])
            
            guard user.id != 0 else {
                response.setBody(string: "Unauthorized")
                    .completed(status: .unauthorized)
                return
            }
            
            let beers = Beer()
            try beers.find([("addedBy", user.id)])
            
            var responseJson = [[String: Any]]()
            for beer in beers.rows() {
                responseJson.append(beer.asDictionary())
            }
            
            try response.setBody(json: responseJson).completed(status: .ok)
            
        } catch {
            
        }
    }
    
    func searchBeers(request: HTTPRequest, response: HTTPResponse, query: String) {
        do {
            var responseJson = [[String: Any]]()
            var uniqueBeers: Set<Beer> = []
            
            let beers = Beer()
            try beers.select(whereclause: "LOWER(name) ~ LOWER($1)", params: [query], orderby: ["name"])
            for beer in beers.rows() {
                uniqueBeers.insert(beer)
            }
            
            let brewers = Beer()
            try brewers.select(whereclause: "LOWER(brewer) ~ LOWER($1)", params: [query], orderby: ["brewer"])
            for brewer in brewers.rows() {
                uniqueBeers.insert(brewer)
            }
            
            for uniqueBeer in uniqueBeers {
                responseJson.append(uniqueBeer.asDictionary())
            }
            
            try response.setBody(json: responseJson).completed(status: .ok)
            
        } catch {
            response.completed(status: .internalServerError)
        }
    }

    func allBeers(request: HTTPRequest, response: HTTPResponse) {
        do {
            let objectQuery = Beer()
            try objectQuery.findAll()
            var responseJson: [[String: Any]] = []

            for row in objectQuery.rows() {
                responseJson.append(row.asDictionary())
            }

            try response.setBody(json: responseJson)
                        .completed(status: .ok)

        } catch let error as StORMError {
            response.setBody(string: error.string())
                    .completed(status: .internalServerError)
        } catch let error {
            response.setBody(string: "\(error)")
                    .completed(status: .internalServerError)
        }
    }
}
