import PerfectHTTP
import StORM
import Foundation

class BeerController {
    func addBeer(request: HTTPRequest, response: HTTPResponse, userDataHandler: UserDataHandler = UserDataHandler(), beerDataHandler: BeerDataHandler = BeerDataHandler()) {
        do {
            
            let user = try userDataHandler.user(from: request)

            guard let postBody = try? request.postBodyString?.jsonDecode() as? [String: Any], let json = postBody else {
                throw MalformedJSONError()
            }

            guard let beerName = json["name"] as? String,
                  let brewerName = json["brewer"] as? String,
                  let abv = json["abv"] as? NSNumber else {
                throw MissingPropertyError()
            }

            guard !beerDataHandler.beerExists(withName: beerName, by: brewerName) else {
                throw BeerExistsError()
            }

            var beer = Beer(name: beerName,
                            brewer: brewerName,
                            abv: abv.floatValue,
                            addedBy: user.id)

            try beerDataHandler.save(beer: &beer)
            
            let payload = try beerDataHandler.json(from: beer)
            
            response.setBody(string: payload)
                    .completed(status: .created)

        } catch let error as BadTokenError {
            response.completed(with: error)
        } catch let error as MalformedJSONError {
            response.completed(with: error)
        } catch let error as MissingPropertyError {
            response.completed(with: error)
        } catch let error as BeerExistsError {
            response.completed(with: error)
        } catch {
            response.completed(status: .internalServerError)
        }
    }
    
    func beersForCurrentUser(request: HTTPRequest, response: HTTPResponse, userDataHandler: UserDataHandler = UserDataHandler(), beerDataHandler: BeerDataHandler = BeerDataHandler(), eventBeerDataHandler: EventBeerDataHandler = EventBeerDataHandler()) {
        
        do {
            let user = try userDataHandler.user(from: request)
            let beers = beerDataHandler.beers(addedBy: user.id)
            let eventBeers = eventBeerDataHandler.eventBeers(broughtBy: user.id, userDataHandler: userDataHandler)
            let beersFromEventBeer = beerDataHandler.beers(from: eventBeers)
            let allUserBeers = Set(beers + beersFromEventBeer)
            
            let payload = try beerDataHandler.jsonArray(from: Array(allUserBeers))
            
            response.setBody(string: payload)
                    .completed(status: .ok)
            
        } catch {
            
        }
    }
    
    func searchBeers(request: HTTPRequest, response: HTTPResponse, beers: BeerDAO = BeerDAO(), brewers: BeerDAO = BeerDAO()) {
        do {
            guard let query = request.queryParamsAsDictionary()["query"] else {
                try response.setBody(json: MissingQueryError()).completed(status: .badRequest)
                return
            }
            var responseJson = [[String: Any]]()
            var uniqueBeers: Set<BeerDAO> = []
            
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

    func allBeers(request: HTTPRequest, response: HTTPResponse, beers: BeerDAO = BeerDAO()) {
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
