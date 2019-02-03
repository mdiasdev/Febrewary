import Foundation
import PerfectHTTP

extension HTTPRequest {

    func queryParamsAsDictionary() -> [String: String] {
        var params: [String: String] = [:]
        for param in queryParams {
            params[param.0] = param.1
        }

        return params
    }
}
