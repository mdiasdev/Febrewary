import PerfectHTTP
import StORM

class EventController {
    func createEvent(request: HTTPRequest, response: HTTPResponse, userDataHandler: UserDataHandler = UserDataHandler(), eventDataHandler: EventDataHandler = EventDataHandler(), attendeeDataHandler: AttendeeDataHandler = AttendeeDataHandler()) {
        
        do {
            let user = try userDataHandler.user(from: request)
            var event = try eventDataHandler.event(from: request, by: user)
            
            try eventDataHandler.save(event: &event)
            
            if event.id > 0 {
                var attendee = try attendeeDataHandler.createAttendee(fromEventId: event.id, andUserId: user.id)
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
                response.completed(with: MalformedJSONError())
                return
        }
        
        guard let beerId = json["beerId"] as? Int else {
            response.completed(with: MissingPropertyError())
            return
        }
        
        do {
            let user = try userDataHandler.user(from: request)
            let event = try eventDataHandler.event(from: request)
            
            guard attendeeDataHandler.attendeeExists(withUserId: user.id, inEventId: event.id) else { throw UserNotInvitedError() }
            guard !eventBeerDataHandler.eventBeerExists(fromEventId: event.id, andUserId: user.id) else { throw EventBeerExistsError() }
            
            var eventBeer = try EventBeer(userId: user.id, beerId: beerId, eventId: event.id, userDataHandler: userDataHandler)

            try eventBeerDataHandler.save(eventBeer: &eventBeer)
            
            response.setBody(string: "").completed(status: .created)
            
        } catch let error as UserNotInvitedError {
            response.completed(with: error)
        } catch let error as EventBeerExistsError {
            response.completed(with: error)
        } catch {
            // FIXME: Catch all the errors (user, event, eventBeer)
            response.completed(status: .internalServerError)
        }
    }
    
    func addAttendee(request: HTTPRequest, response: HTTPResponse, userDataHandler: UserDataHandler = UserDataHandler(), eventDataHandler: EventDataHandler = EventDataHandler(), attendeeDataHandler: AttendeeDataHandler = AttendeeDataHandler()) {
        
        guard let postBody = try? request.postBodyString?.jsonDecode() as? [String: Any],
            let json = postBody else {
                response.completed(with: MalformedJSONError())
                return
        }
        
        guard let userId = json["userId"] as? Int,
              let isPourer = json["isPourer"] as? Bool else {
            response.completed(with: MissingPropertyError())
            return
        }
        
        do {
            let user = try userDataHandler.user(from: userId)
            var event = try eventDataHandler.event(from: request)
            var attendee = try attendeeDataHandler.attendee(fromEventId: event.id, andUserId: user.id)

            attendee.eventId = event.id
            attendee.userId = user.id
            
            try attendeeDataHandler.save(attendee: &attendee)
            
            if isPourer && event.pourerId == 0 {
                event.pourerId = user.id
                try eventDataHandler.save(event: &event)
            } else if isPourer && event.pourerId > 0 {
                response.completed(with: PourerConflictError())
                return
            }
            
            response.setBody(string: "").completed(status: .created)
            
        } catch {
            // FIXME: Catch all the errors
            response.completed(status: .internalServerError)
        }
    }
    
    func pourEventBeer(request: HTTPRequest, response: HTTPResponse, eventDataHandler: EventDataHandler = EventDataHandler(), userDataHandler: UserDataHandler = UserDataHandler(), eventBeerDataHandler: EventBeerDataHandler = EventBeerDataHandler(), attendeeDataHandler: AttendeeDataHandler = AttendeeDataHandler()) {

        var shouldForcePour = false
        
        if let isForced = request.queryParamsAsDictionary()["force"] {
            shouldForcePour = Bool(isForced) ?? false
        }
        
        do {
            let user = try userDataHandler.user(from: request)
            var event = try eventDataHandler.event(from: request)
            
            guard event.pourerId == user.id else {
                response.completed(with: UnauthorizedPourerError())
                return
            }
            
            let attendees = attendeeDataHandler.attendees(fromEventId: event.id)

            guard attendees.count > 1 else {
                response.completed(with: NotEnoughAttendeesError())
                return
            }
            
            if !event.hasStarted {
                event.hasStarted = true
                try eventDataHandler.save(event: &event)
            }
            
            let eventBeers = eventBeerDataHandler.eventBeers(fromEventId: event.id)
            
            guard eventBeers.count > 0 else {
                response.completed(with: NoEventBeersError())
                return
            }
            
            if var currentlyPouringEventBeer = eventBeers.first(where: { $0.isBeingPoured }) {
                if currentlyPouringEventBeer.votes == attendees.count - 1 || shouldForcePour { // -1 is to account for Pourer being an Attendee
                    currentlyPouringEventBeer.isBeingPoured = false
                    try eventBeerDataHandler.save(eventBeer: &currentlyPouringEventBeer)
                } else {
                    response.completed(with: VotingIncompleteError())
                    return
                }
            }
            
            let unpouredEventBeers = eventBeers.filter { $0.round == 0 && $0.votes == 0 && !$0.isBeingPoured }
            let pouredEventBeers = eventBeers.filter { $0.round > 0 }.sorted(by: { $0.round > $1.round})
            
            guard unpouredEventBeers.count > 0, var randomBeer = unpouredEventBeers.randomElement() else {
                try end(event: event, pouredBeers: pouredEventBeers)
                
                response.completed(status: .noContent)
                return
            }
            
            let lastRound = pouredEventBeers.last?.round ?? 0
            randomBeer.round = lastRound + 1
            randomBeer.isBeingPoured = true
            try eventBeerDataHandler.save(eventBeer: &randomBeer)
            
            let payload = try eventBeerDataHandler.json(from: randomBeer)
            
            response.setBody(string: payload).completed(status: .ok)
            
        } catch {
            // FIXME: Catch all the errors
            print("do something in a minute")
        }
    }
    
    func getCurrentEventBeer(request: HTTPRequest, response: HTTPResponse, eventDataHandler: EventDataHandler = EventDataHandler(), eventBeerDataHandler: EventBeerDataHandler = EventBeerDataHandler()) {
        
        do {
            let event = try eventDataHandler.event(from: request)
            
            guard !event.isOver else {
                response.completed(status: .noContent)
                return
            }
            
            let currentlyPouring = try eventBeerDataHandler.eventBeer(fromEventId: event.id, isBeingPoured: true)
            
            let payload = try eventBeerDataHandler.json(from: currentlyPouring)
            
            response.setBody(string: payload).completed(status: .ok)
        } catch {
            // FIXME: Catch all the errors
            response.completed(status: .internalServerError)
        }
        
    }
    
    func vote(request: HTTPRequest, response: HTTPResponse, eventDataHandler: EventDataHandler = EventDataHandler(), voteDataHandler: VoteDataHandler = VoteDataHandler(), userDataHandler: UserDataHandler = UserDataHandler(), eventBeerDataHandler: EventBeerDataHandler = EventBeerDataHandler(), attendeeDataHandler: AttendeeDataHandler = AttendeeDataHandler()) {
        
        guard let postBody = try? request.postBodyString?.jsonDecode() as? [String: Any], let json = postBody else {
                response.setBody(string: "Bad Request: malformed json")
                        .completed(status: .badRequest)
                return
        }
        
        guard let voteEventBeerId = json["eventBeerId"] as? Int, let score = json["vote"] as? Int else {
                response.setBody(string: "Bad Request: missing required property")
                        .completed(status: .badRequest)
                return
        }
        
        do {
            let user = try userDataHandler.user(from: request)
            let event = try eventDataHandler.event(from: request)
            var eventBeer = try eventBeerDataHandler.eventBeer(withId: voteEventBeerId, inEvent: event.id)
            
            guard attendeeDataHandler.attendeeExists(withUserId: user.id, inEventId: event.id) else { throw UserNotInvitedError() }
            guard !voteDataHandler.voteExists(forEventBeer: eventBeer.id, byUser: user.id, inEvent: event.id) else { throw VoteAlreadyCastError() }
            
            var vote = Vote(eventId: event.id, eventBeerId: eventBeer.id, userId: user.id, score: score)
            
            try voteDataHandler.save(vote: &vote)
            
            response.completed(status: .ok)
            
            eventBeer.votes += 1
            eventBeer.score += vote.score
            
            try eventBeerDataHandler.save(eventBeer: &eventBeer)
            
        } catch {
            // FIXME: Catch all the errors
            response.completed(status: .internalServerError)
        }
    }
    
    func end(event: Event, eventDataHandler: EventDataHandler = EventDataHandler(), pouredBeers: [EventBeer], eventBeerDataHandler: EventBeerDataHandler = EventBeerDataHandler(), beerDataHandler: BeerDataHandler = BeerDataHandler()) throws {

        guard !event.isOver else { return }

        var event = event
        event.isOver = true
        try eventDataHandler.save(event: &event)
        
        for var eventBeer in pouredBeers {
            if eventBeer.isBeingPoured {
                eventBeer.isBeingPoured.toggle()
                try eventBeerDataHandler.save(eventBeer: &eventBeer)
            }
            
            var beer = try beerDataHandler.beer(with: eventBeer.beerId)
            
            beer.totalVotes += eventBeer.votes
            beer.totalScore += eventBeer.score
            
            try beerDataHandler.save(beer: &beer)
        }
    }
}
