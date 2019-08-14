import Foundation
import StORM
import PostgresStORM

class Beer: DAO {
    var name: String = ""
    var brewer: String = ""
    var abv: Float = 0.0
    var totalScore: Int = 0
    var totalVotes: Int = 0
    var addedBy: Int = 0

    override open func table() -> String { return "beer" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        name = this.data["name"] as? String ?? ""
        brewer = this.data["brewer"] as? String ?? ""
        abv = this.data["abv"] as? Float ?? 0.0
        totalScore = this.data["totalscore"] as? Int ?? 0
        totalVotes = this.data["totalvotes"] as? Int ?? 0
        addedBy = this.data["addedby"] as? Int ?? 0
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
}

// MARK: - Data Representation
extension Beer {
    func asDictionary() -> [String: Any] {
        var average = 0
        if totalVotes > 0 && totalScore > 0 {
            average = totalScore/totalVotes
        }
        
        return [
            "id": self.id,
            "brewerName": self.brewer,
            "name": self.name,
            "abv": self.abv,
            "totalScore": self.totalScore,
            "totalVotes": self.totalVotes,
            "averageScore": average,
            "addedBy": self.addedBy,
        ]
    }
}

// MARK: - Equatable
extension Beer: Equatable {
    static func == (lhs: Beer, rhs: Beer) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension Beer: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
