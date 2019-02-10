
import Foundation

protocol Attendee: class {
    var token: String { get }
    var name: String { get }

    func asDictionary() -> [String: Any]
}
