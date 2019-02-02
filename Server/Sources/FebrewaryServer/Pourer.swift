//
//  Pourer.swift
//  COpenSSL
//
//  Created by Matthew Dias on 1/26/19.
//

import Foundation
import StORM
import PostgresStORM

class Pourer: PostgresStORM {
    var id: Int = 0
    var pourerToken: String = ""

    override open func table() -> String { return "pourer" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        if let token = this.data["pourertoken"] as? String, !token.isEmpty {
            pourerToken = token
        } else {
            pourerToken = "P-\(Foundation.UUID())"
        }
    }

    func rows() -> [Pourer] {

        guard let row = self.results.rows.first else { return []}

        let pourer = Pourer()
        pourer.to(row)

        return [pourer]
    }

    func asDictionary() -> [String: Any] {
        return [
            "id": self.id,
            "pourerToken": self.pourerToken,
        ]
    }
}
