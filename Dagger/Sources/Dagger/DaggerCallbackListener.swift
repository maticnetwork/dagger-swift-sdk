import Foundation

public protocol DaggerCallbackListener {
    func callback(topic: String?, data: Data)
}
