import Foundation
import StORM
import PostgresStORM

class Event: DAO {
    // MARK: - Properties: basic properties
    var id: Int = 0
    var name: String = ""
    var address: String = ""
    var date: String = ""
    var createdBy: Int = 0
    var pourerId: Int = 0
    
    // MARK: embeded properties
    var _pourer: User = User()
    var _drinkers: [[String: Any]] = []
    var _eventBeers: [[String: Any]] = []
    
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
    func asDictionary(attendees: Attendee = Attendee(), user: User = User(), eventBeers: EventBeer = EventBeer()) -> [String: Any] {
        
        var json: [String: Any] = [
            "id": self.id,
            "name": self.name,
            "address": self.address,
            "date": self.date,
            "pourerId": self.pourerId,
            "createdBy": self.createdBy,
        ]
        
        try? attendees.search(whereClause: "eventid == $1", params: [self.id], orderby: ["id"])
        let ids = attendees.rows().compactMap { "\($0.id)" }
        let idsString = "(\(ids.toString()))"
//        try? user.search(whereClause: "id", params: <#T##[Any]#>, orderby: <#T##[String]#>)
//        //SELECT * FROM member_copy WHERE id IN (17579, 17580, 17582)
//        
//        for attendee in attendees.rows() {
//            guard id != 0 else { continue }
//
//            let drinker = User()
//            try? drinker.get(id)
//            guard drinker.id > 0 else { return [:] }
//
//            self._drinkers.append(drinker.asSimpleDictionary())
//        }
//        
//        json["attendees"] = self._drinkers
//
//        // FIXME: make more performant (don't access DB so many times)
//        for id in eventBeerIds {
//            guard id != 0 else { continue }
//
//            let eventBeer = EventBeer()
//            try? eventBeer.get(id)
//            guard eventBeer.id > 0 else { return [:] }
//
//            self._eventBeers.append(eventBeer.asDictionary())
//        }
        
        json["eventBeers"] = self._eventBeers

        return json
    }
}
