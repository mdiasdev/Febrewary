import PerfectHTTP
import StORM

class EventController {
    func createEvent(request: HTTPRequest, response: HTTPResponse, user: User = User(), event: Event = Event(), attendee: Attendee = Attendee()) {
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
        
        guard let postBody = try? request.postBodyString?.jsonDecode() as? [String: Any],
              let json = postBody else {
            response.setBody(string: "Bad Request: malformed json")
                    .completed(status: .badRequest)
            return
        }

        guard let name = json["name"] as? String,
              let date = json["date"] as? String,
              let address = json["address"] as? String,
              let isPourer = json["isPourer"] as? Bool else {
                response.setBody(string: "Bad Request: missing required property")
                        .completed(status: .badRequest)
                return
        }
        
        do {
            try user.find(by: ["email": email])
            
            guard user.id > 0 else {
                response.setBody(string: "Could not find current User")
                        .completed(status: .internalServerError)
                return
            }
            
            event.name = name
            event.date = date
            event.address = address
            event.createdBy = user.id
            
            if isPourer {
                event.pourerId = user.id
            }
            
            try event.store { id in
                event.id = id as! Int
            }
            
            if event.id > 0 {
                attendee.eventId = event.id
                attendee.userId = user.id
                try attendee.store { id in
                    attendee.id = id as! Int
                }
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
    
    func getEventForUser(request: HTTPRequest, response: HTTPResponse, user: User = User(), events: Event = Event(), attendees: Attendee = Attendee()) {
        guard request.hasValidToken(), let email = request.emailFromAuthToken() else {
            response.setBody(string: "Unauthorized")
                    .completed(status: .unauthorized)
            return
        }
        
        do {
            try user.find(by: ["email": email])

            guard user.id != 0 else {
                response.setBody(string: "Bad Request: could not find User")
                        .completed(status: .badRequest)
                return
            }
            
            try attendees.find(by: [("userid", user.id)])
            
            guard attendees.rows().count > 0 else {
                try response.setBody(json: [])
                            .completed(status: .ok)
                return
            }
            
            let query = "id IN (\(attendees.rows().compactMap { "\($0.eventId)" }.toString()))"
            try? events.search(whereClause: query, params: [], orderby: ["id"])
            
            var responseJson = [[String: Any]]()
            
            for event in events.rows() {
                responseJson.append(event.asDictionary())
            }
            
            try response.setBody(json: responseJson)
                        .completed(status: .ok)
            
        } catch {
            response.completed(status: .internalServerError)
        }
        
        response.completed(status: .internalServerError)
    }
    
    func addEventBeer(request: HTTPRequest, response: HTTPResponse, user: User = User(), event: Event = Event(), eventBeer: EventBeer = EventBeer(), attendee: Attendee = Attendee()) {
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
            try user.find(by: ["email": email])
            
            guard user.id != 0 else {
                response.setBody(string: "Bad Request: could not find User")
                        .completed(status: .badRequest)
                return
            }
            
            try event.find(by: [("id", id)])
            
            guard event.id > 0 else {
                response.setBody(string: "Could not find event with id: \(id).")
                        .completed(status: .notFound)
                return
            }
            
            try attendee.find(by: [("userid", user.id), ("eventid", event.id)])
            guard attendee.rows().count > 0 else {
                response.setBody(string: "User not invited")
                        .completed(status: .unauthorized)
                return
            }
            
            try eventBeer.find(by: [
                ("userId", user.id),
                ("eventId", event.id)
                ])
            
            guard eventBeer.id == 0 else {
                response.setBody(string: "User has already added a beer to this event")
                        .completed(status: .conflict)
                return
            }
            
            eventBeer.userId = user.id
            eventBeer.beerId = beerId
            eventBeer.eventId = event.id
            
            try eventBeer.store { id in
                eventBeer.id = id as! Int
            }
            
            try response.setBody(json: [String: Any]()).completed(status: .created)
            
        } catch {
            response.completed(status: .internalServerError)
        }
    }
    
    func addAttendee(request: HTTPRequest, response: HTTPResponse, user: User = User(), event: Event = Event(), attendee: Attendee = Attendee()) {
        guard request.hasValidToken() else {
            response.setBody(string: "Unauthorized")
                    .completed(status: .unauthorized)
            return
        }
        
        guard let eventId = Int(request.urlVariables["id"] ?? "0"), eventId > 0 else {
            response.completed(status: .badRequest)
            return
        }
        
        guard let postBody = try? request.postBodyString?.jsonDecode() as? [String: Any],
            let json = postBody else {
                response.setBody(string: "Bad Request: malformed json")
                        .completed(status: .badRequest)
                return
        }
        
        guard let userId = json["userId"] as? Int,
              let isPourer = json["isPourer"] as? Bool else {
            response.setBody(string: "Missing data")
                    .completed(status: .badRequest)
            return
        }
        
        do {
            try user.find(by: [("id", userId)])
            guard user.id > 0 else {
                response.setBody(string: "Could not find user")
                        .completed(status: .notFound)
                return
            }
            
            try event.find(by: [("id", eventId)])
            guard event.id > 0 else {
                response.setBody(string: "Could not find event")
                        .completed(status: .notFound)
                return
            }
            
            if isPourer && event.pourerId == 0 {
                event.pourerId = user.id
                try event.store()
            } else if isPourer && event.pourerId > 0 {
                response.setBody(string: "Event already has a pourer")
                        .completed(status: .conflict)
                return
            }
            
            try attendee.find(by: [("userid", user.id), ("eventid", event.id)])
            guard attendee.id == 0 else {
                response.setBody(string: "Person already invited")
                        .completed(status: .notFound)
                return
            }
            
            attendee.eventId = event.id
            attendee.userId = user.id
            
            try attendee.store { id in
                attendee.id = id as! Int
            }
            
            try response.setBody(json: [String: Any]()).completed(status: .created)
            
        } catch {
            response.completed(status: .internalServerError)
        }
    }
    
    func pourEventBeer(request: HTTPRequest, response: HTTPResponse, event: Event = Event(), user: User = User(), eventBeer: EventBeer = EventBeer(), attendee: Attendee = Attendee()) {
        
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
        
        guard let eventId = Int(request.urlVariables["id"] ?? "0"), eventId > 0 else {
            response.completed(status: .badRequest)
            return
        }
        
        var shouldForcePour = false
        
        if let isForced = request.queryParamsAsDictionary()["force"] {
            shouldForcePour = Bool(isForced) ?? false
        }
        
        do {
            try event.find(by: [("id", eventId)])
            guard event.id > 0 else {
                response.setBody(string: "Could not find event with id: \(eventId)")
                        .completed(status: .badRequest)
                return
            }
            
            try user.find(by: [("email", email)])
            guard user.id > 0, event.pourerId == user.id else {
                response.setBody(string: "Unauthorized")
                        .completed(status: .unauthorized)
                return
            }
            
            try attendee.find(by: [("eventId", eventId)])
            guard attendee.rows().count > 1 else {
                response.setBody(string: "Event must have more than one attendee")
                        .completed(status: .badRequest)
                return
            }
            
            try eventBeer.find(by: [("eventid", eventId)])
            
            guard eventBeer.rows().count > 0 else {
                response.setBody(string: "No beers added to event \(eventId)")
                        .completed(status: .notFound)
                return
            }
            
            if let currentlyPouringEventBeer = eventBeer.rows().first(where: { $0.isBeingPoured }) {
                if currentlyPouringEventBeer.votes == attendee.rows().count || shouldForcePour {
                    currentlyPouringEventBeer.isBeingPoured = false
                    try currentlyPouringEventBeer.store()
                } else {
                    response.setBody(string: "Warning: not all votes are in. Pass force if you still want to proceed.")
                            .completed(status: .preconditionFailed)
                    return
                }
            }
            
            let unpouredEventBeers = eventBeer.rows().filter { $0.round == 0 && $0.votes == 0 && !$0.isBeingPoured }
            let pouredEventBeers = eventBeer.rows().filter { $0.round > 0 }.sorted(by: { $0.round > $1.round})
            
            guard let randomBeer = unpouredEventBeers.randomElement() else {
                // TODO: event over, do a thing (#117)
                return
            }
            
            let lastRound = pouredEventBeers.last?.round ?? 0
            randomBeer.round = lastRound + 1
            randomBeer.isBeingPoured = true
            try randomBeer.store()
            
            let payload = randomBeer.asDictionary()
            
            try response.setBody(json: payload).completed(status: .ok)
            
        } catch {
            // FIXME: error handling
            print("do something in a minute")
        }
    }
    
    func getCurrentEventBeer(request: HTTPRequest, response: HTTPResponse, event: Event = Event(), eventBeer: EventBeer = EventBeer(), user: User = User()) {
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
        
        guard let eventId = Int(request.urlVariables["id"] ?? "0"), eventId > 0 else {
            response.completed(status: .badRequest)
            return
        }
        
        do {
            try event.find(by: [("id", eventId)])
            guard event.id > 0 else {
                response.setBody(string: "Could not find event with id: \(eventId)")
                        .completed(status: .badRequest)
                return
            }
            
            try user.find(by: [("email", email)])
            guard user.id > 0, event.pourerId == user.id else {
                response.setBody(string: "Unauthorized")
                        .completed(status: .unauthorized)
                return
            }
            
            try eventBeer.find(by: [("eventid", eventId), ("isbeingpoured", true)])
            guard eventBeer.rows().count == 1, let currentlyPouring = eventBeer.rows().first else {
                response.setBody(string: "No beer in event \(eventId) is currently being poured")
                        .completed(status: .notFound)
                return
            }
            
            let payload = currentlyPouring.asDictionary()
            
            try response.setBody(json: payload).completed(status: .ok)
        } catch {
            response.completed(status: .internalServerError)
        }
        
    }
    
    func vote(request: HTTPRequest, response: HTTPResponse, event: Event = Event(), vote: Vote = Vote(), user: User = User(), eventBeer: EventBeer = EventBeer()) {
        
        
    }
}
