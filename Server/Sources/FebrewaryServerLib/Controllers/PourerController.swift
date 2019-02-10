import PerfectHTTP
import StORM

public class PourerController: RouteController {
    override func initRoutes() {
        routes.add(Route(method: .get, uri: "pourerToken", handler: getPourerToken))
    }

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
                let queryParams = request.queryParamsAsDictionary()

                guard let name = queryParams["name"] else {
                    response.appendBody(string: "Missing required name").completed(status: .badRequest)
                    return
                }

                let pourer = Pourer()
                pourer.name = name
                
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
}
