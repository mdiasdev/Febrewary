import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import FebrewaryServerLib

DatabaseController.setupDatabase()

let server = HTTPServer()
server.serverPort = 8080

DatabaseController.registerTables()

server.addRoutes(AuthRouter().routes)
server.addRoutes(BeerRouter().routes)
server.addRoutes(EventRouter().routes)
server.addRoutes(UserController().routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
