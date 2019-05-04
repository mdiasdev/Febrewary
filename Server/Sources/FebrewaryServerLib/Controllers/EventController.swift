import Foundation

class EventController: RouteController {
    override func initRoutes() {
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
