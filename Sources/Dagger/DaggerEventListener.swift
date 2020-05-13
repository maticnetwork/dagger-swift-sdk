import Foundation

public protocol DaggerEventListener {
    func callback(topic: String?, data: Data)
}
