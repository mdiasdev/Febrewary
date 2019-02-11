import PerfectHTTP
import StORM
import Foundation

public class BeerController: RouteController {
    override func initRoutes() {
        routes.add(Route(method: .post, uri: "beer", handler: addBeer))
        routes.add(Route(method: .get, uri: "beer", handler: allBeers))
    }

    func addBeer(request: HTTPRequest, response: HTTPResponse) {
        do {
            guard let token = request.header(.custom(name: "token")) else {
                response.setBody(string: "Bad Request: Missing Header")
                        .completed(status: .badRequest)
                return
            }

            guard let json = try? request.postBodyString?.jsonDecode() as? [String: Any] else {
                response.setBody(string: "Bad Request: malformed json")
                        .completed(status: .badRequest)
                return
            }

            guard let beerName = json?["beerName"] as? String else {
                response.setBody(string: "Bad Request: missing beerName")
                        .completed(status: .badRequest)
                return
            }

            guard let brewerName = json?["brewerName"] as? String else {
                response.setBody(string: "Bad Request: missing brewerName")
                        .completed(status: .badRequest)
                return
            }

            let objectQuery = Beer()
            try objectQuery.find(["name" : beerName])

            var beer = Beer()

            var exists = false

            for beerRow in objectQuery.rows() {
                if beerRow.brewerName == brewerName {
                    beer = beerRow
                    exists = true
                    break
                }
            }

            if !exists {
                beer.name = beerName
                beer.brewerName = brewerName

                try beer.save { id in
                    beer.id = id as! Int
                }
            }

            // add to Event as EventBeer
            guard let attendee = AttendeeController().attendee(from: token) else {
                response.setBody(string: "Bad Request: could not find attendee")
                        .completed(status: .badRequest)
                return
            }

            EventController().updateEvent(with: beer, broughtBy: attendee) { wasSuccessful in

                guard wasSuccessful else {
                    response.setBody(string: "Failed to add beer to event.")
                            .completed(status: .internalServerError)
                    return
                }

                response.completed(status: .created)
            }

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
