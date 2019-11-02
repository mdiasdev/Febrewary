import PerfectHTTP
import StORM

class EventController {
    func createEvent(request: HTTPRequest, response: HTTPResponse, userDataHandler: UserDataHandler = UserDataHandler(), eventDataHandler: EventDataHandler = EventDataHandler(), attendeeDataHandler: AttendeeDataHandler = AttendeeDataHandler()) {
        
        do {
            let user = try userDataHandler.user(from: request)
            var event = try eventDataHandler.event(from: request, by: user)
            
            try eventDataHandler.save(event: &event)
            
            if event.id > 0 {
                var attendee = try attendeeDataHandler.attendee(fromEventId: event.id, andUserId: user.id)
                try attendeeDataHandler.save(attendee: &attendee)
            } else {
                throw DatabaseError()
            }
            
            let responseJson = try eventDataHandler.json(from: event)
            
            response.setBody(string: responseJson)
                    .completed(status: .created)
            
        } catch let error as DatabaseError {
            response.completed(with: error)
        } catch let error as MalformedJSONError {
            response.completed(with: error)
        } catch let error as MissingPropertyError {
            response.completed(with: error)
        } catch let error as UnauthenticatedError {
            response.completed(with: error)
        } catch let error as BadTokenError {
            response.completed(with: error)
        } catch let error as UserNotFoundError {
            response.completed(with: error)
        } catch {
            response.completed(with: DatabaseError())
        }
    }
    
    func getEventForUser(request: HTTPRequest, response: HTTPResponse, userDataHandler: UserDataHandler = UserDataHandler(), eventDataHandler: EventDataHandler = EventDataHandler(), attendeeDataHandler: AttendeeDataHandler = AttendeeDataHandler()) {
        
        do {
            let user = try userDataHandler.user(from: request)
            let attendees = try attendeeDataHandler.attendees(fromUserId: user.id)
            
            guard attendees.count > 0 else {
                try response.setBody(json: [])
                            .completed(status: .ok)
                return
            }
            
            let events = try eventDataHandler.events(fromAttendees: attendees)
        
            try response.setBody(string: eventDataHandler.jsonArray(from: events))
                        .completed(status: .ok)
            
        } catch {
            response.completed(status: .internalServerError)
        }
    }
    
    func addEventBeer(request: HTTPRequest, response: HTTPResponse, userDataHandler: UserDataHandler = UserDataHandler(), eventDataHandler: EventDataHandler = EventDataHandler(), eventBeerDataHandler: EventBeerDataHandler = EventBeerDataHandler(), attendeeDataHandler: AttendeeDataHandler = AttendeeDataHandler()) {
        
        guard let postBody = try? request.postBodyString?.jsonDecode() as? [String: Any],
              let json = postBody else {
            response.setBody(string: "Bad Request: malformed json")
                    .completed(status: .badRequest)
            return
        }
        
        guard let beerId = json["beerId"] as? Int else {
            // FIXME: swap out with a real error
            response.setBody(string: "Missing data")
                    .completed(status: .badRequest)
            return
        }
        
        do {
            let user = try userDataHandler.user(from: request)
            let event = try eventDataHandler.event(from: request)
            
            guard attendeeDataHandler.attendeeExists(withUserId: user.id, inEventId: event.id) else { throw UserNotInvitedError() }
            guard !eventBeerDataHandler.eventBeerExists(fromEventId: event.id, andUserId: user.id) else { throw EventBeerExistsError() }
            
            var eventBeer = try EventBeer(userId: user.id, beerId: beerId, eventId: event.id)

            try eventBeerDataHandler.save(eventBeer: &eventBeer)
            
            response.setBody(string: "").completed(status: .created)
            
        } catch {
            response.completed(status: .internalServerError)
        }
    }
    
    func addAttendee(request: HTTPRequest, response: HTTPResponse, user: UserDAO = UserDAO(), event: EventDAO = EventDAO(), attendee: AttendeeDAO = AttendeeDAO()) {

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
            try user.find(by: [("id", userId)]) // MATT RIGHT HERE
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
    
    func pourEventBeer(request: HTTPRequest, response: HTTPResponse, event: EventDAO = EventDAO(), userDataHandler: UserDataHandler = UserDataHandler(), eventBeer: EventBeerDAO = EventBeerDAO(), attendee: AttendeeDAO = AttendeeDAO()) {
        
        guard let eventId = Int(request.urlVariables["id"] ?? "0"), eventId > 0 else {
            response.completed(status: .badRequest)
            return
        }
        
        var shouldForcePour = false
        
        if let isForced = request.queryParamsAsDictionary()["force"] {
            shouldForcePour = Bool(isForced) ?? false
        }
        
        do {
            let user = try userDataHandler.user(from: request)
            try event.find(by: [("id", eventId)])
            
            guard event.id > 0 else {
                response.setBody(string: "Could not find event with id: \(eventId)")
                        .completed(status: .badRequest)
                return
            }
            
            guard event.pourerId == user.id else {
                response.setBody(string: "Unauthorized")
                    .completed(status: .unauthorized)
                return
            }
            
            if !event.hasStarted {
                event.hasStarted = true
                try event.store()
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
                if currentlyPouringEventBeer.votes == attendee.rows().count - 1 || shouldForcePour { // -1 is to account for Pourer being an Attendee
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
            
            guard unpouredEventBeers.count > 0, let randomBeer = unpouredEventBeers.randomElement() else {
                try end(event: event, pouredBeers: pouredEventBeers)
                
                response.completed(status: .noContent)
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
    
    func getCurrentEventBeer(request: HTTPRequest, response: HTTPResponse, event: EventDAO = EventDAO(), eventBeer: EventBeerDAO = EventBeerDAO(), user: UserDAO = UserDAO()) {
        
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
            
            guard !event.isOver else {
                response.completed(status: .noContent)
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
    
    func vote(request: HTTPRequest, response: HTTPResponse, event: EventDAO = EventDAO(), vote: Vote = Vote(), userDataHandler: UserDataHandler = UserDataHandler(), eventBeer: EventBeerDAO = EventBeerDAO(), attendee: AttendeeDAO = AttendeeDAO()) {
        
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
        
        guard let voteEventBeerId = json["eventBeerId"] as? Int,
              let score = json["vote"] as? Int else {
                response.setBody(string: "Bad Request: missing required property")
                        .completed(status: .badRequest)
                return
        }
        
        do {
            let user = try userDataHandler.user(from: request)
            try event.find(by: [("id", eventId)])
            guard event.id > 0, event.hasStarted && !event.isOver else {
                response.setBody(string: "Could not find event with id: \(eventId)")
                        .completed(status: .badRequest)
                return
            }
            
            try attendee.find(by: [("eventid", event.id), ("userid", user.id)])
            guard attendee.rows().count == 1 else {
                response.setBody(string: "User not invited to this Event")
                        .completed(status: .unauthorized)
                return
            }
            
            try eventBeer.find(by: [("eventid", eventId), ("id", voteEventBeerId), ("isbeingpoured", true)])
            guard eventBeer.rows().count == 1, let currentBeer = eventBeer.rows().first else {
                response.setBody(string: "No beer in event \(eventId) is currently being poured")
                    .completed(status: .notFound)
                return
            }
            
            guard currentBeer.id == voteEventBeerId else {
                response.setBody(string: "Voting for this beer has ended. Please vote for next")
                        .completed(status: .notFound)
                return
            }
            
            try vote.find(by: [("eventid", event.id), ("eventbeerid", eventBeer.id), ("userid", user.id)])
            guard vote.id == 0 else {
                response.setBody(string: "You have already voted for this beer! Please wait until the next round to vote again")
                        .completed(status: .badRequest)
                return
            }
            
            vote.eventId = event.id
            vote.eventBeerId = eventBeer.id
            vote.userId = user.id
            vote.score = score
            
            try vote.store(set: { id in
                vote.id = id as! Int
            })
            
            response.completed(status: .ok)
            
            currentBeer.votes += 1
            currentBeer.score += vote.score
            try currentBeer.store()
            
        } catch {
            response.completed(status: .internalServerError)
        }
    }
    
    func end(event: EventDAO, pouredBeers: [EventBeerDAO], beer: Beer = Beer()) throws {
        guard !event.isOver else { return }
        
        event.isOver = true
        try event.store()
        
        for eventBeer in pouredBeers {
            if eventBeer.isBeingPoured {
                eventBeer.isBeingPoured.toggle()
                try eventBeer.store()
            }
            
            try beer.find(by: [("id", eventBeer.beerId)])
            
            guard beer.id > 0 else {
                throw StORMError.noRecordFound
            }
            
            beer.totalVotes += eventBeer.votes
            beer.totalScore += eventBeer.score
            
            try beer.store()
        }
    }
}
