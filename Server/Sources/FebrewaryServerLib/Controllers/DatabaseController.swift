import Foundation
import StORM
import PostgresStORM

public struct DatabaseController {
    public static func setupDatabase() {
        PostgresConnector.host = Configuration.dbHost
        PostgresConnector.username = Configuration.dbUser
        PostgresConnector.password = Configuration.dbPassword
        PostgresConnector.database = Configuration.dbName
        PostgresConnector.port = Configuration.dbPort
    }

    // TODO: database error if fails to setup
    public static func registerTables() {
        let beer = BeerDAO()
        try? beer.setup()

        let event = EventDAO()
        try? event.setup()

        let eventBeer = EventBeerDAO()
        try? eventBeer.setup()

        let round = Vote()
        try? round.setup()
        
        let user = UserDAO()
        try? user.setup()
        
        let attendee = AttendeeDAO()
        try? attendee.setup()
    }
}
