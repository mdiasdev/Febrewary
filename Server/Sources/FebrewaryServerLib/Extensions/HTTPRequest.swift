import Foundation
import PerfectHTTP
import PerfectCrypto

extension HTTPRequest {

    func queryParamsAsDictionary() -> [String: String] {
        var params: [String: String] = [:]
        for param in queryParams {
            params[param.0] = param.1
        }

        return params
    }
    
    func hasValidToken() -> Bool {
        guard let token = self.header(.authorization) else { return false }
        
        do {
            let validator = JWTVerifier(token)
            try validator?.verify(algo: .hs256, key: Configuration.salt)
             
            return true
        } catch {
            return false
        }
        
    }
    
    func emailFromAuthToken() -> String? {
        guard let token = self.header(.authorization) else { return nil }
        
        do {
            let validator = JWTVerifier(token)
            try validator?.verify(algo: .hs256, key: Configuration.salt)
            
            return validator?.payload["email"] as? String
        } catch {
            return nil
        }
    }
}
