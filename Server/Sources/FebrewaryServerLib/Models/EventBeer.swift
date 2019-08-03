import Foundation
import StORM
import PostgresStORM

class EventBeer: DAO {
    var id: Int = 0
    var userId: Int = 0
    var _user: User?
    var beerId: Int = 0
    var _beer: Beer?
    var eventId: Int = 0
    var votes: Int = 0
    var eventScore: Int = 0

    override open func table() -> String { return "eventbeer" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        beerId = this.data["beerid"] as? Int ?? 0
        userId = this.data["userid"] as? Int ?? 0
        eventId = this.data["eventid"] as? Int ?? 0
        eventScore = this.data["eventscore"] as? Int ?? 0
        votes = this.data["votes"] as? Int ?? 0
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
}

// MARK: - Data Representation
extension EventBeer {
    func asDictionary() -> [String: Any] {

        let drinker = User()
        try? drinker.get(self.userId)

        _user = drinker

        let beer = Beer()
        try? beer.get(self.beerId)

        guard let user = _user, beer.id > 0 else { return [:] }

        return [
            "id": self.id,
            "attendee": user.asSimpleDictionary(),
            "beer": beer.asDictionary(),
            "eventScore": self.eventScore
        ]
    }
}
