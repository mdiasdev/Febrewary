import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import FebrewaryServerLib

DatabaseController.setupDatabase()

// FIXME: move to environment file
let server = HTTPServer()
server.serverPort = 8080

DatabaseController.registerTables()

server.addRoutes(PourerController().routes)
server.addRoutes(DrinkerController().routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
