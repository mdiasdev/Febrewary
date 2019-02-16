import Foundation
import StORM
import PostgresStORM

class Round: PostgresStORM {
    var id: Int = 0
    var eventId: Int = 0
    var eventBeerId: Int = 0
    var totalScore: Int = 0

    override open func table() -> String { return "round" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        eventId = this.data["eventid"] as? Int ?? 0
        eventBeerId = this.data["eventbeerid"] as? Int ?? 0
        totalScore = this.data["totalscore"] as? Int ?? 0
    }

    func rows() -> [Round] {
        var rounds = [Round]()
        let rows = self.results.rows

        guard !rows.isEmpty else { return [] }

        for row in rows {
            let round = Round()
            round.to(row)

            rounds.append(round)
        }

        return rounds
    }

    func asDictionary() -> [String: Any] {
        return [
            "id": self.id,
        ]
    }
}
