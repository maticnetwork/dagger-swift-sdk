import Foundation

public struct DaggerError : LocalizedError {
    var message : String
    init(message : String?) {
        self.message = message ?? "Dagger exception"
    }
}

