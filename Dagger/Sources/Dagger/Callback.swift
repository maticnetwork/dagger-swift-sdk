import Foundation
public protocol Callback {
    /**
     * This method is called when the connection to the server is lost.
     *
     * @param cause the reason behind the loss of connection.
     */
    func connectionLost(cause: NSError?)
    
    func connected(dagger : Dagger)
}
