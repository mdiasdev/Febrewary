import Foundation
import StORM
import PostgresStORM

class EventBeer: DAO {
    var id: Int = 0
    var userId: Int = 0
    var beerId: Int = 0
    var eventId: Int = 0
    var round: Int = 0
    var votes: Int = 0
    var score: Int = 0
    var isBeingPoured: Bool = false
    
    // MARK: embeded properties
    var _user: User?
    var _beer: Beer?

    override open func table() -> String { return "eventbeer" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        beerId = this.data["beerid"] as? Int ?? 0
        userId = this.data["userid"] as? Int ?? 0
        eventId = this.data["eventid"] as? Int ?? 0
        round = this.data["round"] as? Int ?? 0
        score = this.data["score"] as? Int ?? 0
        votes = this.data["votes"] as? Int ?? 0
        isBeingPoured = this.data["isbeingpoured"] as? Bool ?? false
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
            "round": self.round,
            "score": self.score,
            "isBeingPoured": self.isBeingPoured,
        ]
    }
}
