import Foundation
import StORM
import PostgresStORM

public struct DatabaseController {
    public static func setupDatabase() {
        // FIXME: move to environment file
        PostgresConnector.host = "localhost"
        PostgresConnector.username = "perfect"
        PostgresConnector.password = "perfect"
        PostgresConnector.database = "febrewary"
        PostgresConnector.port = 5432
    }

    public static func registerTables() {
        let pourer = Pourer()
        try? pourer.setup()

        let drinker = Drinker()
        try? drinker.setup()
    }
}
