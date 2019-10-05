import Foundation
import PerfectHTTP

extension HTTPResponse {
    func completed<T: ServerError>(with error: T) {
        let errorCode = HTTPResponseStatus.statusFrom(code: error.code)
        
        self.setBody(string: error.debugDescription)
                .completed(status: errorCode)
    }
}
