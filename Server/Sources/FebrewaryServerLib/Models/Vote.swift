import Foundation
import StORM
import PostgresStORM

class Vote: DAO {
    var eventId: Int = 0 // the event the user is at
    var eventBeerId: Int = 0 // beer the user is voting on
    var userId: Int = 0 // user whose vote it is
    var score: Int = 0

    override open func table() -> String { return "vote" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        eventId = this.data["eventid"] as? Int ?? 0
        eventBeerId = this.data["eventbeerid"] as? Int ?? 0
        score = this.data["score"] as? Int ?? 0
    }

    func rows() -> [Vote] {
        var votes = [Vote]()
        let rows = self.results.rows

        guard !rows.isEmpty else { return [] }

        for row in rows {
            let round = Vote()
            round.to(row)

            votes.append(round)
        }

        return votes
    }

    func asDictionary() -> [String: Any] {
        return [
            "id": self.id,
        ]
    }
}
