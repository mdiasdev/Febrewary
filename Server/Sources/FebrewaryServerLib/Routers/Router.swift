import Foundation
import PerfectHTTP

infix operator &&&
func &&& (lhs: @escaping (HTTPRequest, HTTPResponse) -> Result<(), Error>, rhs: @escaping (HTTPRequest, HTTPResponse) -> Void) -> (HTTPRequest, HTTPResponse) -> Void {
    return { request, response in
        guard case .success(_) = lhs(request, response) else {
            return
        }
        rhs(request, response)
    }
}

public class Router {
    public var routes = Routes()

    public init() {
        initRoutes()
    }

    func initRoutes() {
        assertionFailure("this should be override by subclasses!")
    }
    
    func auth(request: HTTPRequest, response: HTTPResponse) -> Result<(), Error> {
        do {
            try validateAuth(request: request)
            
            return Result.success({}())
        } catch let error as ServerError {
            let errorCode = HTTPResponseStatus.statusFrom(code: error.code)
            let json = error.debugDescription
            response.setBody(string: json)
                    .completed(status: errorCode)
            
            return Result.failure(error)
        } catch {
            print("unexpected issue with authentication.")
            return Result.failure(UnknownError())
        }
    }
    
    func validateAuth(request: HTTPRequest) throws {
        guard request.hasValidToken() else {
            throw UnauthenticatedError()
        }
        
        guard request.emailFromAuthToken() != nil else {
           throw BadTokenError()
        }
    }

}
