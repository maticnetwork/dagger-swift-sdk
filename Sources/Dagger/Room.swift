import Foundation

class Room {
    var roomType: RoomType?
    var dagger: Dagger?
    
    init(dagger: Dagger?, roomType: RoomType?) throws {
        self.dagger = dagger
        self.roomType = roomType
        
        if (self.dagger == nil) {
            throw DaggerError(message: "`dagger` object is required")
        }
        if (roomType == nil) {
            throw DaggerError(message: "`room` is required")
        }
    }

    
    func on(eventName: String, listener: successClosure?)throws -> Room {
        try dagger?.on(eventName: "\(roomType?.rawValue):\(eventName)", listener: listener)
        return self
    }

    func off(eventName: String, listener: successClosure?)throws -> Room {
        try dagger?.off(eventName: "\(roomType?.rawValue):\(eventName)", listener: listener)
        return self
    }
}

