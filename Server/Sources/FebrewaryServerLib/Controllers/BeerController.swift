import PerfectHTTP
import StORM
import Foundation

class BeerController {
    func addBeer(request: HTTPRequest, response: HTTPResponse, userDataHandler: UserDataHandler = UserDataHandler(), beer: Beer = Beer()) {
        do {
            
            let user = try userDataHandler.user(from: request)

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

        } catch is BadTokenError {
            let error = BadTokenError()
            try! response.setBody(json: error).completed(status: HTTPResponseStatus.statusFrom(code: error.code))
        } catch {
            response.completed(status: .internalServerError)
        }
    }
    
    func beersForCurrentUser(request: HTTPRequest, response: HTTPResponse, userDataHandler: UserDataHandler = UserDataHandler(), beers: Beer = Beer(), eventBeers: EventBeer = EventBeer()) {
        
        do {
            let user = try userDataHandler.user(from: request)
            
            try beers.find(by: [("addedBy", user.id)])
            try eventBeers.find(by: [("userid", user.id)])
            
            let beerFromEventBeer = Beer()
            let eBeers: [Beer] = eventBeers.rows().compactMap {
                // FIXME: change into a select statement
                try? beerFromEventBeer.find(by: [("id", $0.beerId)])
                return beerFromEventBeer.rows().first
            }
            
            let allUserBeers = Set(beers.rows() + eBeers)
            
            var responseJson = [[String: Any]]()
            for beer in allUserBeers {
                responseJson.append(beer.asDictionary())
            }
            
            try response.setBody(json: responseJson).completed(status: .ok)
            
        } catch {
            
        }
    }
    
    func searchBeers(request: HTTPRequest, response: HTTPResponse, beers: Beer = Beer(), brewers: Beer = Beer()) {
        do {
            guard let query = request.queryParamsAsDictionary()["query"] else {
                try response.setBody(json: MissingQueryError()).completed(status: .badRequest)
                return
            }
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
