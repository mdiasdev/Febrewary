import PerfectHTTP
import StORM

public class DrinkerController: RouteController {
    override func initRoutes() {
        routes.add(Route(method: .get, uri: "drinkerToken", handler: getDrinkerToken))
        routes.add(Route(method: .get, uri: "drinkers", handler: getAllDrinkers))
    }

    func getDrinkerToken(request: HTTPRequest, response: HTTPResponse) {
        do {
            let queryParams = request.queryParamsAsDictionary()

            guard let name = queryParams["name"] else {
                response.appendBody(string: "Missing required name").completed(status: .badRequest)
                return
            }

            let drinker = Drinker()
            drinker.name = name

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
}
