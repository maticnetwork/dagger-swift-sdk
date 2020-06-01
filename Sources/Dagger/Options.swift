import Foundation

public struct Options {
    var clientId: String
    var keepAlive : Int
    var cleanSession : Bool
    
    public init(clientId: String = UUID().uuidString, keepAlive : Int = 120, cleanSession : Bool = true){
        self.clientId = clientId
        self.keepAlive = keepAlive
        self.cleanSession = cleanSession
    }
}
