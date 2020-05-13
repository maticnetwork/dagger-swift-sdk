import Foundation

public struct MessageDecodingError : LocalizedError {
    
    var message : String
    
    public init(message : String){
        self.message = message;
    }

}
