import Foundation
import StORM
import PostgresStORM

class Pourer: PostgresStORM, Attendee {
    var id: Int = 0
    var token: String = "P-\(Foundation.UUID())"
    var name: String = ""

    override open func table() -> String { return "pourer" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        token = this.data["token"] as? String ?? "P-\(Foundation.UUID())"
        name = this.data["name"] as? String ?? ""
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
            "token": self.token,
            "name": self.name,
        ]
    }
}
