import Foundation

public struct MessageEncodingError : LocalizedError {
    
    var message : String
    
    public init(message : String){
        self.message = message;
    }

}
