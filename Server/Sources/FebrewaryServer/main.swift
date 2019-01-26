import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import StORM
import PostgresStORM

PostgresConnector.host = "localhost"
PostgresConnector.username = "perfect"
PostgresConnector.password = "perfect"
PostgresConnector.database = "febrewary"
PostgresConnector.port = 5432

let server = HTTPServer()
server.serverPort = 8080

let pourer = Pourer()
try? pourer.setup()

let drinker = Drinker()
try? drinker.setup()

var routes = Routes()

func getPourerToken(request: HTTPRequest, response: HTTPResponse) {
    do {
        let objectQuery = Pourer()
        try objectQuery.findAll()
        var responseJson: [String: Any] = [:]

        for row in objectQuery.rows() {
            responseJson = row.asDictionary()
        }

        if !responseJson.isEmpty {
            try response.setBody(json: responseJson)
                        .completed(status: .ok)
        } else {
            let pourer = Pourer()

            try pourer.save { id in
                pourer.id = id as! Int
            }

            try response.setBody(json: pourer.asDictionary())
                        .completed(status: .ok)
        }

    } catch let error as StORMError {
        response.setBody(string: error.string())
                .completed(status: .internalServerError)
    } catch let error {
        response.setBody(string: "\(error)")
                .completed(status: .internalServerError)
    }
}

func getDrinkerToken(request: HTTPRequest, response: HTTPResponse) {
    do {

        let drinker = Drinker()

        try drinker.save { id in
            drinker.id = id as! Int
        }

        try response.setBody(json: drinker.asDictionary())
                    .completed(status: .ok)

    } catch let error as StORMError {
        response.setBody(string: error.string())
                .completed(status: .internalServerError)
    } catch let error {
        response.setBody(string: "\(error)")
                .completed(status: .internalServerError)
    }
}

func getAllDrinkers(request: HTTPRequest, response: HTTPResponse) {
    do {

        let objectQuery = Drinker()
        try objectQuery.findAll()
        var responseJson: [[String: Any]] = []

        for row in objectQuery.rows() {
            responseJson.append(row.asDictionary())
        }

        try response.setBody(json: responseJson)
                    .completed(status: .ok)

    } catch let error as StORMError {
        response.setBody(string: error.string())
                .completed(status: .internalServerError)
    } catch let error {
        response.setBody(string: "\(error)")
                .completed(status: .internalServerError)
    }
}

routes.add(Route(method: .get, uri: "pourerToken", handler: getPourerToken))
routes.add(Route(method: .get, uri: "drinkerToken", handler: getDrinkerToken))
routes.add(Route(method: .get, uri: "drinker", handler: getAllDrinkers))

server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
