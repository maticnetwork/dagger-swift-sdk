import Foundation

public struct Options {
    var clientId: String
    var callback: Callback?
    var keepAlive : Int
    var cleanSession : Bool
    
    public init(clientId: String = UUID().uuidString, callback: Callback? = nil, keepAlive : Int = 120, cleanSession : Bool = true){
        self.clientId = clientId
        self.callback = callback
        self.keepAlive = keepAlive
        self.cleanSession = cleanSession
    }
}
