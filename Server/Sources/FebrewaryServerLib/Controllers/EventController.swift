import PerfectHTTP
import StORM

public class EventController: RouteController {
    override func initRoutes() {
        routes.add(method: .post, uri: "/event", handler: createEvent)
        routes.add(method: .get, uri: "/event/{id}", handler: getEvent)
        routes.add(method: .get, uri: "/event", handler: getEventForUser)
        routes.add(method: .post, uri: "/event/{id}/beer", handler: addEventBeer)
    }
    
    func createEvent(request: HTTPRequest, response: HTTPResponse) {
        guard request.hasValidToken() else {
            response.setBody(string: "Unauthorized")
                    .completed(status: .unauthorized)
            return
        }
        
        guard let email = request.emailFromAuthToken() else {
            response.setBody(string: "Bad Request")
                    .completed(status: .badRequest)
            return
        }
        
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
            
            let user = User()
            try user.find(["email": email])
            
            guard user.id > 0 else {
                response.setBody(string: "Could not find current User")
                        .completed(status: .internalServerError)
                return
            }
            
            if !attendees.contains(user.id){
                attendees.append(user.id)
            }
            
            let event = Event()
            
            event.name = name
            event.date = date
            event.address = address
            event.createdBy = user.id
            event.pourerId = pourerId
            event.drinkerIds = Array(attendees)
            
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
    
    func getEvent(request: HTTPRequest, response: HTTPResponse) {
        guard let id = Int(request.urlVariables["id"] ?? "0"), id > 0 else {
            response.completed(status: .badRequest)
            return
        }
        
        // FIXME: implement?
        response.completed(status: .notFound)
    }
    
    func getEventForUser(request: HTTPRequest, response: HTTPResponse) {
        guard request.hasValidToken(), let email = request.emailFromAuthToken() else {
            response.setBody(string: "Unauthorized")
                    .completed(status: .unauthorized)
            return
        }
        
        do {
            let user = User()
            try user.find(["email": email])

            guard user.id != 0 else {
                response.setBody(string: "Bad Request: could not find User")
                        .completed(status: .badRequest)
                return
            }
            
            let allEvents = Event()
            try allEvents.findAll() // TODO: performance?
            
            let userEvents = allEvents.rows().filter { $0.drinkerIds.contains(user.id) }
            var responseJson = [[String: Any]]()
            
            for event in userEvents {
                responseJson.append(event.asDictionary())
            }
            
            try response.setBody(json: responseJson)
                        .completed(status: .ok)
            
        } catch {
            response.completed(status: .internalServerError)
        }
        
        response.completed(status: .internalServerError)
    }
    
    func addEventBeer (request: HTTPRequest, response: HTTPResponse) {
        guard request.hasValidToken(), let email = request.emailFromAuthToken() else {
            response.setBody(string: "Unauthorized")
                .completed(status: .unauthorized)
            return
        }
        
        guard let id = Int(request.urlVariables["id"] ?? "0"), id > 0 else {
            response.completed(status: .badRequest)
            return
        }
        
        guard let postBody = try? request.postBodyString?.jsonDecode() as? [String: Any],
              let json = postBody else {
            response.setBody(string: "Bad Request: malformed json")
                    .completed(status: .badRequest)
            return
        }
        
        guard let beerId = json["beerId"] as? Int else {
            response.setBody(string: "Missing data")
                    .completed(status: .badRequest)
            return
        }
        
        do {
            let user = User()
            try user.find(["email": email])
            
            guard user.id != 0 else {
                response.setBody(string: "Bad Request: could not find User")
                        .completed(status: .badRequest)
                return
            }
            
            let event = Event()
            try event.find([("id", id)])
            
            guard event.id > 0 else {
                response.setBody(string: "Could not find event with id: \(id).")
                        .completed(status: .notFound)
                return
            }
            
            guard event.drinkerIds.contains(user.id) else {
                response.setBody(string: "User not invited")
                        .completed(status: .unauthorized)
                return
            }
            
            let eventBeer = EventBeer()
            
            try eventBeer.find([("userId", user.id)])
            
            guard eventBeer.id == 0 else {
                response.setBody(string: "User has already added a beer to this event")
                        .completed(status: .conflict)
                return
            }
            
            eventBeer.userId = user.id
            eventBeer.beerId = beerId
            eventBeer.eventId = event.id
            
            try eventBeer.save { id in
                eventBeer.id = id as! Int
            }
            
            event.eventBeerIds.append(eventBeer.id)
            try event.save()
            
            response.completed(status: .created)
            
        } catch {
            response.completed(status: .internalServerError)
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
