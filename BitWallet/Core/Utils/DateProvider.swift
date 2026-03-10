import Foundation

protocol DateProviding {
    var now: Date { get }
}

class DateProvider: DateProviding {
    var now: Date {
        return Date()
    }
}
