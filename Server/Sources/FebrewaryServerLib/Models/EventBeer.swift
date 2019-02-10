import Foundation
import StORM
import PostgresStORM

class EventBeer: PostgresStORM {
    var id: Int = 0
    var attendeeId: Int = 0
    var beerId: Int = 0
    var _attendee: Attendee?
    var _beer: Beer?
    var eventScore: Int = 0

    override open func table() -> String { return "eventbeer" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        beerId = this.data["beerid"] as? Int ?? 0
        attendeeId = this.data["attendeeid"] as? Int ?? 0
        eventScore = this.data["eventscore"] as? Int ?? 0
    }

    func rows() -> [EventBeer] {
        let rows = self.results.rows

        guard !rows.isEmpty else { return [] }

        var beers = [EventBeer]()

        for row in rows {
            let beer = EventBeer()
            beer.to(row)
            beers.append(beer)
        }

        return beers
    }

    func asDictionary() -> [String: Any] {
        let pourer = Pourer()
        try? pourer.get(self.attendeeId)

        let drinker = Drinker()
        try? drinker.get(self.attendeeId)

        if pourer.id != 0 {
            _attendee = pourer
        } else if drinker.id != 0 {
            _attendee = drinker
        } else {
            return [:]
        }

        let beer = Beer()
        try? beer.get(self.beerId)

        guard let attendee = _attendee, beer.id > 0 else { return [:] }

        return [
            "id": self.id,
            "attendee": attendee.asDictionary(),
            "beer": beer.asDictionary(),
            "eventScore": self.eventScore
        ]
    }
}
