import Foundation
import StORM
import PostgresStORM

class Event: PostgresStORM {
    var id: Int = 0
    var name: String = ""
    var address: String = ""
    var date: String = ""
    var pourerId: Int = 0
    var _pourer: User = User()
    var drinkerIds: [Int] = []
    var _drinkers: [[String: Any]] = []
    var eventBeerIds: [Int] = []
    var _eventBeers: [[String: Any]] = []
    var roundIds: [Int] = []
    var _rounds: [Round] = []
    var currentRound: Int = -1
    

    override open func table() -> String { return "event" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        name = this.data["name"] as? String ?? ""
        address = this.data["address"] as? String ?? ""
        date = this.data["date"] as? String ?? ""
        pourerId = this.data["pourerid"] as? Int ?? 0

        let drinkerIdString = this.data["drinkerids"] as? String ?? ""
        drinkerIds = drinkerIdString.dropFirst().dropLast().components(separatedBy: ",").compactMap({ (idString) -> Int? in
            return Int(idString)
        })

        let eventBeerString = this.data["eventbeerids"] as? String ?? ""
        eventBeerIds = eventBeerString.dropFirst().dropLast().components(separatedBy: ",").compactMap({ (idString) -> Int? in
            return Int(idString)
        })
        
        let roundIdString = this.data["roundids"] as? String ?? ""
        roundIds = roundIdString.dropFirst().dropLast().components(separatedBy: ",").compactMap({ (idString) -> Int? in
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
        
        var json: [String: Any] = [
            "id": self.id,
            "name": self.name,
            "address": self.address,
            "date": self.date,
        ]
        
        for id in drinkerIds {
            guard id != 0 else { continue }

            let drinker = User()
            try? drinker.get(id)
            guard drinker.id > 0 else { return [:] }

            self._drinkers.append(drinker.asDictionary())
        }
        json["attendees"] = self._drinkers

        for id in eventBeerIds {
            guard id != 0 else { continue }

            let eventBeer = EventBeer()
            try? eventBeer.get(id)
            guard eventBeer.id > 0 else { return [:] }

            self._eventBeers.append(eventBeer.asDictionary())
        }
        json["eventBeers"] = self._eventBeers

//        let pourer = User()
//        try? pourer.get(self.pourerId)
//    
//        guard pourer.id > 0 else { return [:] }
//        json["pourer"] = pourer.asDictionary()

        return json
    }
}
