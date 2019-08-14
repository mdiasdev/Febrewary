import PerfectHTTP
import StORM
import Foundation

class BeerController {
    func addBeer(request: HTTPRequest, response: HTTPResponse, user: User = User(), beer: Beer = Beer()) {
        do {
            guard request.hasValidToken(), let email = request.emailFromAuthToken() else {
                response.setBody(string: "Unauthorized")
                        .completed(status: .unauthorized)
                return
            }
            
            try user.find(by: ["email": email])
            
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

            try beer.find(
                by: ["name": beerName,
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

            try beer.store { id in
                beer.id = id as! Int
            }
            
            try response.setBody(json: beer.asDictionary())
                        .completed(status: .created)

        } catch {
            response.completed(status: .internalServerError)
        }
    }
    
    func beersForCurrentUser(request: HTTPRequest, response: HTTPResponse, user: User = User(), beers: Beer = Beer()) {
        guard request.hasValidToken(), let email = request.emailFromAuthToken() else {
            response.setBody(string: "Unauthorized")
                .completed(status: .unauthorized)
            return
        }
        
        do {
            try user.find(by: ["email": email])
            
            guard user.id != 0 else {
                response.setBody(string: "Unauthorized")
                        .completed(status: .unauthorized)
                return
            }
            
            try beers.find(by: [("addedBy", user.id)])
            
            var responseJson = [[String: Any]]()
            for beer in beers.rows() {
                responseJson.append(beer.asDictionary())
            }
            
            try response.setBody(json: responseJson).completed(status: .ok)
            
        } catch {
            
        }
    }
    
    func searchBeers(request: HTTPRequest, response: HTTPResponse, query: String, beers: Beer = Beer(), brewers: Beer = Beer()) {
        do {
            var responseJson = [[String: Any]]()
            var uniqueBeers: Set<Beer> = []
            
            try beers.search(whereClause: "LOWER(name) ~ LOWER($1)", params: [query], orderby: ["name"])
            for beer in beers.rows() {
                uniqueBeers.insert(beer)
            }
            
            try brewers.search(whereClause: "LOWER(brewer) ~ LOWER($1)", params: [query], orderby: ["brewer"])
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

    func allBeers(request: HTTPRequest, response: HTTPResponse, beers: Beer = Beer()) {
        do {
            try beers.getAll()
            var responseJson: [[String: Any]] = []

            for row in beers.rows() {
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
