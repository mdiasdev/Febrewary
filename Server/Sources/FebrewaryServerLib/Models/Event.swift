import Foundation
import StORM
import PostgresStORM

class Event: DAO {
    // MARK: - Properties: basic properties
    var id: Int = 0
    var name: String = ""
    var address: String = ""
    var date: String = ""
    
    // MARK: - Properties: used to allow only the creator to edit an event
    var createdBy: Int = 0
    
    // MARK: - Properties: used to allow one user to know what beer is assigned to a round
    var pourerId: Int = 0
    var _pourer: User = User()
    
    // MARK: - Properties: all users planned in attendance
    var drinkerIds: [Int] = []
    var _drinkers: [[String: Any]] = []
    
    // MARK: all beers brought by attendees
    var eventBeerIds: [Int] = []
    var _eventBeers: [[String: Any]] = []
    
    // MARK: - Properties: voting tracking
    var roundIds: [Int] = []
    var _rounds: [Round] = []
    var currentRound: Int = -1
    
    // MARK: -
    // MARK: - StORM functions
    override open func table() -> String { return "event" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        name = this.data["name"] as? String ?? ""
        address = this.data["address"] as? String ?? ""
        date = this.data["date"] as? String ?? ""
        pourerId = this.data["pourerid"] as? Int ?? 0
        createdBy = this.data["createdby"] as? Int ?? 0

        let drinkerIdString = this.data["drinkerids"] as? String ?? ""
        drinkerIds = drinkerIdString.replacingOccurrences(of: "[", with: "")
                                    .replacingOccurrences(of: "]", with: "")
                                    .toIdArray()

        let eventBeerString = this.data["eventbeerids"] as? String ?? ""
        eventBeerIds = eventBeerString.replacingOccurrences(of: "[", with: "")
                                      .replacingOccurrences(of: "]", with: "")
                                      .toIdArray()
        
        let roundIdString = this.data["roundids"] as? String ?? ""
        roundIds = roundIdString.replacingOccurrences(of: "[", with: "")
                                .replacingOccurrences(of: "]", with: "")
                                .toIdArray()
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

}

    // MARK: - Data Representation
extension Event {
    func asDictionary() -> [String: Any] {
        
        var json: [String: Any] = [
            "id": self.id,
            "name": self.name,
            "address": self.address,
            "date": self.date,
            "pourerId": self.pourerId,
            "createdBy": self.createdBy,
        ]
        
        // FIXME: make more performant (don't access DB so many times)
        for id in drinkerIds {
            guard id != 0 else { continue }

            let drinker = User()
            try? drinker.get(id)
            guard drinker.id > 0 else { return [:] }

            self._drinkers.append(drinker.asSimpleDictionary())
        }
        
        json["attendees"] = self._drinkers

        // FIXME: make more performant (don't access DB so many times)
        for id in eventBeerIds {
            guard id != 0 else { continue }

            let eventBeer = EventBeer()
            try? eventBeer.get(id)
            guard eventBeer.id > 0 else { return [:] }

            self._eventBeers.append(eventBeer.asDictionary())
        }
        
        json["eventBeers"] = self._eventBeers

        return json
    }
}
