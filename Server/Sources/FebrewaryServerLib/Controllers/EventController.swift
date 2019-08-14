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
            
            guard user.isValid() else {
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
            
            if event.isValid() {
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

            guard user.isValid() else {
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
            
            guard user.isValid() else {
                response.setBody(string: "Bad Request: could not find User")
                        .completed(status: .badRequest)
                return
            }
            
            try event.find(by: [("id", id)])
            
            guard event.isValid() else {
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
            
            guard !eventBeer.isValid() else {
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
            guard user.isValid() else {
                response.setBody(string: "Could not find user")
                        .completed(status: .notFound)
                return
            }
            
            try event.find(by: [("id", eventId)])
            guard event.isValid() else {
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
            guard !attendee.isValid() else {
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
    
    func pourEventBeer(request: HTTPRequest, response: HTTPResponse, event: Event = Event(), user: User = User(), eventBeer: EventBeer = EventBeer()) {
        
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
            try user.find(by: [("email", email)])
            
            try event.find(by: [("id", eventId)])
            
            guard event.isValid(), user.isValid(), event.pourerId == user.id else {
                return
            }
            
        } catch {
            print("do something in a minute")
        }
    }
}
