import Foundation

class AttendeeController {
    func attendee(from token: String) -> Attendee? {

        if token.hasPrefix("P-") {
            let pourer = Pourer()
            try? pourer.find([("token", token)])
            return pourer
        } else if token.hasPrefix("D-") {
            let drinker = Drinker()
            try? drinker.find([("token", token)])
            return drinker
        } else {
            return nil
        }
    }
}
