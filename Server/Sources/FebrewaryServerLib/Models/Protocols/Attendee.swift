
import Foundation

protocol Attendee: class {
    var id: Int { get }
    var token: String { get }
    var name: String { get }

    func asDictionary() -> [String: Any]
}
