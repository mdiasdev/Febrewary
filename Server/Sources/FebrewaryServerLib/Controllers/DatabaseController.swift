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

    // TODO: database error if fails to setup
    public static func registerTables() {
        let beer = Beer()
        try? beer.setup()

        let drinker = Drinker()
        try? drinker.setup()

        let eventBeer = EventBeer()
        try? eventBeer.setup()

        let pourer = Pourer()
        try? pourer.setup()
    }
}
