import Foundation
import SwiftMQTT

public typealias successClosure = (_ topic:String,_ data:Data) -> Void
public typealias connectionLostClosure = (Error) -> Void
public typealias connectedClosure = (Dagger) -> Void

public class Dagger : MQTTSessionDelegate{
    
    public var regexTopics = [String: MqttRegex]()
    public var listeners = [String: Array<successClosure>?]()
    private var isConnectedToHost = false
    private var client : MQTTSession? = nil
    private var onConnected : connectedClosure
    private var onConnectionLost : connectionLostClosure
    var processedoptions : Options
    
    
    
    public init(url : String,onConnected:@escaping connectedClosure,onConnectionLost:@escaping connectionLostClosure)throws {
        if (url=="") {
            throw DaggerError(message: "Invalid URL")
        }
        self.onConnected = onConnected
        self.onConnectionLost = onConnectionLost
        processedoptions =  Options()
        client = MQTTSession(host: url, port: 1883, clientID: processedoptions.clientId, cleanSession: processedoptions.cleanSession, keepAlive: 15, useSSL: false)

        client?.delegate = self
    }
    
    public func mqttDidReceive(message: MQTTMessage, from session: MQTTSession) {
        emit(eventName: message.topic, payload: message.payload)
        // emit events to matching listeners
        for topic in getMatchingTopics(eventName: message.topic) {
            emit(eventName: topic, payload: message.payload)
        }
    }

    public func mqttDidAcknowledgePing(from session: MQTTSession) {
        print("ack ping")
    }

    public func mqttDidDisconnect(session: MQTTSession, error: MQTTSessionError) {
        isConnectedToHost = false
//        processedoptions.callback?.connectionLost(cause: error as NSError)
        onConnectionLost(error)
    }
    
    public func start() -> Bool{
        client!.delegate = self
        client!.connect { (error) in
            if error == .none {
                self.isConnectedToHost = true
//                self.processedoptions.callback?.connected(dagger: self)
                self.onConnected(self)
            } else {
                print(error)
                self.isConnectedToHost = false
            }
        }
        return self.isConnectedToHost
    }

    public func stop() {
        client!.disconnect()
    }

    public func isConnected() -> Bool {
        return self.isConnectedToHost
    }

    
    public func on(eventName: String, listener: successClosure?)throws -> Dagger {
        return try self.addListener(eventName: eventName, listener: listener)
    }


    public func off(eventName: String, listener: successClosure?)throws -> Dagger {
        return try self.removeListener(eventName: eventName, listener: listener)
    }

    public func addListener(eventName: String, listener: successClosure?)throws-> Dagger {
        let mqttRegex = MqttRegex(t: eventName)
        if (regexTopics[mqttRegex.topic] == nil) { // subscribe events from server using topic
            
            client!.subscribe(to: eventName, delivering: .atLeastOnce) { (error) in
                if error == .none {
                    print("Subscribed to \(eventName)")
//                    self.processedoptions.callback?.connected(dagger: self)
                    self.onConnected(self)
                } else {
                    print("Error occurred during subscription:")
                    print(error.description)
                }
            }
            regexTopics[mqttRegex.topic] = mqttRegex
        }
        var list = getEventListeners(eventName: eventName)
        if(listener != nil){
            list.append(listener!)
            listeners[eventName] = list
        }
        return self
    }

    public func removeListener(eventName: String, listener: successClosure?)throws-> Dagger {
        let mqttRegex = MqttRegex(t: eventName)
        // not working
        
        var list: Array<successClosure> = getEventListeners(eventName: eventName)
        print("list size before \(list.count)")
        if(listener != nil){
            for i in 0 ..< list.count {
                if ( hashString(obj: list[i] as AnyObject)  == hashString(obj: listener as AnyObject)) {
                    print("remove")
                    _ = list.remove(at: i)
                    break
                }
            }
        }
        print("list size after \(list.count)")
        listeners[eventName] = list
        print("list size after2 \(getEventListeners(eventName: eventName).count)")
        
         // if listener count is zero, unsubscribe topic and delete from `_regexTopics`
        if (getEventListeners(eventName: eventName).count == 0) { // unsubscribe events from server
            // remove MQTT regex from regex topics
            if (regexTopics[mqttRegex.topic] != nil) {
                regexTopics.removeValue(forKey: mqttRegex.topic)
            }
            // unsubscribe
            client?.unSubscribe(from: eventName, completion: nil)
        }
        return self
    }
    
    private func hashString (obj: AnyObject) -> String {
        return String(UInt(bitPattern: ObjectIdentifier(obj)))
    }

    public func removeAllListeners(eventName: String) {
        let mqttRegex = MqttRegex(t: eventName)
        // if listener count is zero, unsubscribe topic and delete from `_regexTopics`
       // unsubscribe events from server
        client?.unSubscribe(from: eventName, completion: nil)
        // remove MQTT regex from regex topics
        if (regexTopics[mqttRegex.topic] != nil) {
            regexTopics.removeValue(forKey: mqttRegex.topic)
        }

        listeners[eventName] = Array<successClosure>()
    }

    public func getMatchingTopics(eventName: String)-> Array<String> {
        var result =  Array<String>()
        let topics = Array(regexTopics.values)
        for i in 0..<topics.count {
            let mqttRegex = topics[i]
            if (mqttRegex.matches(rawTopic: eventName)) {
                result.append(mqttRegex.topic)
            }
        }
        return result
    }

    public func getAllSubscriptions()-> Dictionary<String, MqttRegex>.Keys{
     return regexTopics.keys
    }
    
    // Get all event listeners
    private func getEventListeners(eventName: String)-> Array<successClosure> {
        if (listeners[eventName] == nil) {
            listeners[eventName] = Array()
        }
     return listeners[eventName]!!
    }
    
    private func emit(eventName: String, payload: Data) { // execute callback in all events
        for listener in getEventListeners(eventName: eventName) {
//            listener.callback(topic: eventName, data: payload)
            
            listener(eventName,payload)
            
        }
    }
}
