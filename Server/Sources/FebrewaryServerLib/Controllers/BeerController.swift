import PerfectHTTP
import StORM
import Foundation

public class BeerController: RouteController {
    override func initRoutes() {
        routes.add(Route(method: .post, uri: "beer", handler: addBeer))
        routes.add(Route(method: .get, uri: "beer", handler: allBeers))
        routes.add(Route(method: .post, uri: "beer/pour", handler: pouring))
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

            guard let json = try? request.postBodyString?.jsonDecode() as? [String: Any] else {
                response.setBody(string: "Bad Request: malformed json")
                        .completed(status: .badRequest)
                return
            }

            guard let beerName = json?["name"] as? String,
                  let brewerName = json?["brewer"] as? String,
                  let abv = json?["abv"] as? Double
                else {
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
            beer.abv = abv
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

    // FIXME: revist this entirely
    func pouring(request: HTTPRequest, response: HTTPResponse) {
        guard let token = request.header(.custom(name: "token")), token.contains("P-") else {
            response.setBody(string: "Bad Request: Bad or Missing Header")
                    .completed(status: .badRequest)
            return
        }

        guard let json = try? request.postBodyString?.jsonDecode() as? [String: Any] else {
            response.setBody(string: "Bad Request: malformed json")
                    .completed(status: .badRequest)
            return
        }

        guard let beerId = json?["beerId"] as? Int else {
            response.setBody(string: "Bad Request: missing beerId")
                    .completed(status: .badRequest)
            return
        }

        guard let userId = json?["userId"] as? Int else {
            response.setBody(string: "Bad Request: missing attendeeToken")
                    .completed(status: .badRequest)
            return
        }

        do {
            // fetch EventBeer for beerId (matching attendeeToken)
            // make new round
            // add the things!

            let eventBeerQuery = EventBeer()
            try eventBeerQuery.findAll()

            let eventBeerRow = eventBeerQuery.rows().first { (eventBeer) -> Bool in
                eventBeer.beerId == beerId && eventBeer.userId == userId
            }

            guard let eventBeer = eventBeerRow else {
                response.setBody(string: "Bad Request: could not find the beer provided")
                        .completed(status: .badRequest)
                return
            }

            let event = Event()
            try? event.findOne(orderBy: "id")   // FIXME: in the future we should allow more than one event at a time

            guard event.id > 0 else {
                response.setBody(string: "No current Event running")
                        .completed(status: .internalServerError)
                return
            }

            let round = Round()
            round.eventBeerId = eventBeer.id
            round.eventId = event.id

            try round.save { (id) in
                round.id = id as! Int
            }

            response.completed(status: .ok)

        } catch {
            // FIXME: better error handling
            response.setBody(string: "Something very bad happened")
                    .completed(status: .internalServerError)
        }
    }
}
