//
//  Drinker.swift
//  COpenSSL
//
//  Created by Matthew Dias on 1/26/19.
//

import Foundation
import StORM
import PostgresStORM

class Drinker: PostgresStORM {
    var id: Int = 0
    var drinkerToken: String = "D-\(Foundation.UUID())"
    var name: String?

    override open func table() -> String { return "drinker" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        drinkerToken = this.data["drinkertoken"] as? String ?? "D-\(Foundation.UUID())"
        name = this.data["name"] as? String
    }

    func rows() -> [Drinker] {
        let rows = self.results.rows

        guard !rows.isEmpty else { return [] }

        var drinkers = [Drinker]()

        for row in rows {
            let drinker = Drinker()
            drinker.to(row)
            drinkers.append(drinker)
        }

        return drinkers
    }

    func asDictionary() -> [String: Any] {
        var json: [String: Any] = [
            "id": self.id,
            "drinkerToken": "\(self.drinkerToken)",
        ]

        if let name = self.name {
            json["name"] = name
        }

        return json
    }
}
