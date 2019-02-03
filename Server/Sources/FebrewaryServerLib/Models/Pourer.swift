import Foundation
import StORM
import PostgresStORM

class Pourer: PostgresStORM {
    var id: Int = 0
    var pourerToken: String = "P-\(Foundation.UUID())"

    override open func table() -> String { return "pourer" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        pourerToken = this.data["pourertoken"] as? String ?? "P-\(Foundation.UUID())"
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
