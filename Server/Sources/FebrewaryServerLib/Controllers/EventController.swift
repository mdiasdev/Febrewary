import PerfectHTTP
import StORM

public class EventController: RouteController {
    override func initRoutes() {
        routes.add(Route(method: .post, uri: "events", handler: createEvent))
    }
    
    func createEvent(request: HTTPRequest, response: HTTPResponse) {
        guard let postBody = try? request.postBodyString?.jsonDecode() as? [String: Any], let json = postBody else {
            response.setBody(string: "Bad Request: malformed json")
                    .completed(status: .badRequest)
            return
        }

        guard let name = json["name"] as? String,
              let date = json["date"] as? String,
              let address = json["address"] as? String,
              let pourerId = json["pourerId"] as? Int,
              var attendees = json["attendees"] as? [Int] else {
                response.setBody(string: "Bad Request: missing required property")
                        .completed(status: .badRequest)
                return
        }
        
        if !attendees.contains(pourerId) {
            attendees.append(pourerId)
        }
        
        do {
            let event = Event()
            
            event.name = name
            event.date = date
            event.address = address
            event.pourerId = pourerId
            event.drinkerIds = attendees
            
            try event.save { id in
                event.id = id as! Int
            }
            
            let responseJson = event.asDictionary()
            
            guard !responseJson.isEmpty else {
                response.setBody(string: "Internal Server Error: Could not save Event")
                        .completed(status: .internalServerError)
                return
            }
            
            try response.setBody(json: responseJson)
                        .completed(status: .created)
        } catch {
            response.setBody(string: "Internal Server Error: Could not save Event")
                    .completed(status: .internalServerError)
        }
    }
    
    // MARK: internal functions
    func update(event eventId: Int, with beer: Beer, broughtBy attendee: User, isPourer: Bool, completion: @escaping (Bool) -> Void) {

        do {
            let event = Event()
            try? event.find(["id": eventId])

            if event.id == 0 {
                try event.save { id in
                    event.id = id as! Int
                }
            }

            if isPourer {
                event.pourerId = attendee.id
            } else {
                event.drinkerIds.append(attendee.id)
            }

            let eventBeer = EventBeer()
            eventBeer.userId = attendee.id
            eventBeer.beerId = beer.id

            if eventBeer.id == 0 {
                try eventBeer.save { id in
                    eventBeer.id = id as! Int
                    event.eventBeerIds.append(eventBeer.id)
                }
            } else {
                event.eventBeerIds.append(eventBeer.id)
            }

            try event.save()

            completion(true)
        } catch {
            completion(false)
        }
    }
}
