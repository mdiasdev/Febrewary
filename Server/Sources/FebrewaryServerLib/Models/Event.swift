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

        let drinkerIdString = this.data["drinkerids"] as? String ?? ""
        drinkerIds = drinkerIdString.dropFirst().dropLast().components(separatedBy: ",").compactMap({ (idString) -> Int? in
            return Int(idString)
        })

        let eventBeerString = this.data["eventbeerids"] as? String ?? ""
        eventBeerIds = eventBeerString.dropFirst().dropLast().components(separatedBy: ",").compactMap({ (idString) -> Int? in
            return Int(idString)
        })
    }

    func rows() -> [Event] {
        let rows = self.results.rows

        guard !rows.isEmpty else { return [] }

        var events = [Event]()

        for row in rows {
            let event = Event()
            event.to(row)
            events.append(event)
        }

        return events
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
