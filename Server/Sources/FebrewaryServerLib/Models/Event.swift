import Foundation
import StORM
import PostgresStORM

class Event: DAO {
    // MARK: - Properties: basic properties
    var name: String = ""
    var address: String = ""
    var date: String = ""
    var createdBy: Int = 0
    var pourerId: Int = 0
    var isOver: Bool = false
    var hasStarted: Bool = false
    
    // MARK: embeded properties
    var _pourer: User = User()
    var _attendees: [[String: Any]] = []
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
        isOver = this.data["isover"] as? Bool ?? false
        hasStarted = this.data["hasstarted"] as? Bool ?? false
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
    func asDictionary(attendees: Attendee = Attendee(), users: User = User(), eventBeers: EventBeer = EventBeer()) -> [String: Any] {
        
        var json: [String: Any] = [
            "id": self.id,
            "name": self.name,
            "address": self.address,
            "date": self.date,
            "pourerId": self.pourerId,
            "createdBy": self.createdBy,
            "isOver": self.isOver,
            "hasStarted": self.hasStarted
        ]
        
        try? attendees.find(by: [("eventid", id)])
        if attendees.rows().count > 0 {
            let query = "id IN (\(attendees.rows().compactMap { "\($0.userId)" }.toString()))"
            try? users.search(whereClause: query, params: [], orderby: ["id"])
            
            for user in users.rows() {
                self._attendees.append(user.asSimpleDictionary())
            }
        }
        
        json["attendees"] = self._attendees

        try? eventBeers.find(by: [("eventid", id)])
        
        for eventBeer in eventBeers.rows() {
            self._eventBeers.append(eventBeer.asDictionary())
        }
        
        json["eventBeers"] = self._eventBeers

        return json
    }
}
