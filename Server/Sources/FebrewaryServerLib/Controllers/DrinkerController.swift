import PerfectHTTP
import StORM

public class DrinkerController: Router {
    override func initRoutes() {
        routes.add(Route(method: .get, uri: "drinkers", handler: getAllDrinkers))
    }

    func getAllDrinkers(request: HTTPRequest, response: HTTPResponse) {
        do {
            var responseJson: [[String: Any]] = []

            let drinkerQuery = User()
            try drinkerQuery.findAll()

            for row in drinkerQuery.rows() {
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
