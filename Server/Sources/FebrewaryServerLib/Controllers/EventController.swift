import PerfectHTTP
import StORM

public class EventController: Router {
    
    
    func createEvent(request: HTTPRequest, response: HTTPResponse, user: User = User(), event: Event = Event()) {
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
            try user.find(["email": email])
            
            guard user.id > 0 else {
                response.setBody(string: "Could not find current User")
                        .completed(status: .internalServerError)
                return
            }
            
            if !attendees.contains(user.id){
                attendees.append(user.id)
            }
            
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
    
    func getEventForUser(request: HTTPRequest, response: HTTPResponse, user: User = User(), events: Event = Event()) {
        guard request.hasValidToken(), let email = request.emailFromAuthToken() else {
            response.setBody(string: "Unauthorized")
                    .completed(status: .unauthorized)
            return
        }
        
        do {
            try user.find(["email": email])

            guard user.id != 0 else {
                response.setBody(string: "Bad Request: could not find User")
                        .completed(status: .badRequest)
                return
            }
            
            try events.select(whereclause: "drinkerIds ~ $1", params: [user.id], orderby: ["id"])
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
    
    func addEventBeer(request: HTTPRequest, response: HTTPResponse, user: User = User(), event: Event = Event(), eventBeer: EventBeer = EventBeer()) {
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
            try user.find(["email": email])
            
            guard user.id != 0 else {
                response.setBody(string: "Bad Request: could not find User")
                        .completed(status: .badRequest)
                return
            }
            
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
            
            try eventBeer.find([("userId", user.id), ("eventId", event.id)])
            
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
            
            try response.setBody(json: [String: Any]()).completed(status: .created)
            
        } catch {
            response.completed(status: .internalServerError)
        }
    }
}
