import Foundation

class EventController {
    func updateEvent(with beer: Beer, broughtBy attendee: Attendee, completion: @escaping (Bool) -> Void) {

        do {
            let event = Event()
            try? event.findOne(orderBy: "id")   // FIXME: in the future we should allow more than one event at a time

            if event.id == 0 {
                try event.save { id in
                    event.id = id as! Int
                }
            }

            if attendee.token.hasPrefix("P-") {
                event.pourerId = attendee.id
            } else if attendee.token.hasPrefix("D-") {
                event.drinkerIds.append(attendee.id)
            } else {
                completion(false)
                return
            }

            let eventBeer = EventBeer()
            eventBeer.userId = attendee.id
            eventBeer.attendeeUUId = attendee.token
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
