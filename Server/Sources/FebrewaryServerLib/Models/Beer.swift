import Foundation
import StORM
import PostgresStORM

class Beer: PostgresStORM {

    var id: Int = 0
    var name: String = ""
    var brewerName: String = ""
    var totalScore: Int = 0

    override open func table() -> String { return "beer" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        name = this.data["name"] as? String ?? ""
        brewerName = this.data["brewername"] as? String ?? ""
        totalScore = this.data["totalscore"] as? Int ?? 0
    }

    func rows() -> [Beer] {
        let rows = self.results.rows

        guard !rows.isEmpty else { return [] }

        var beers = [Beer]()

        for row in rows {
            let beer = Beer()
            beer.to(row)
            beers.append(beer)
        }

        return beers
    }

    func asDictionary() -> [String: Any] {
        return [
            "id": self.id,
            "brewerName": self.brewerName,
            "name": self.name,
            "totalScore": self.totalScore
        ]
    }
}
