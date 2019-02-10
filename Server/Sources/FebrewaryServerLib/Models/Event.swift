import Foundation
import StORM
import PostgresStORM

class Event: PostgresStORM {
    var id: Int = 0
    var pourerId: Int = 0
    var _pourer: Pourer = Pourer()
    var drinkerIds: [Int] = []
    var _drinkers: [[String: Any]] = []
    var eventBeerIds: [Int] = []
    var _eventBeers: [[String: Any]] = []

    override open func table() -> String { return "event" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        pourerId = this.data["pourerid"] as? Int ?? 0
        drinkerIds = this.data["drinkerids"] as? [Int] ?? []
        eventBeerIds = this.data["eventbeerids"] as? [Int] ?? []
    }

    func rows() -> [Event] {
        let rows = self.results.rows

        guard !rows.isEmpty else { return [] }

        var drinkers = [Event]()

        for row in rows {
            let drinker = Event()
            drinker.to(row)
            drinkers.append(drinker)
        }

        return drinkers
    }

    func asDictionary() -> [String: Any] {
        // FIXME: make more performant (don't access DB so many times)
        for id in drinkerIds {
            guard id != 0 else { continue }

            let drinker = Drinker()
            try? drinker.get(id)
            guard drinker.id > 0 else { return [:] }

            self._drinkers.append(drinker.asDictionary())
        }

        for id in eventBeerIds {
            guard id != 0 else { continue }

            let eventBeer = EventBeer()
            try? eventBeer.get(id)
            guard eventBeer.id > 0 else { return [:] }

            self._eventBeers.append(eventBeer.asDictionary())
        }

        let pourer = Pourer()
        try? pourer.get(self.pourerId)

        guard pourer.id > 0 else { return [:] }

        let json: [String: Any] = [
            "id": self.id,
            "pourer": pourer.asDictionary(),
            "drinkers": self._drinkers,
            "eventBeers": self._eventBeers,
        ]

        return json
    }
}
