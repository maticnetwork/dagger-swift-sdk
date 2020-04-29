import Foundation
import SwiftMQTT

public class Dagger : MQTTSessionDelegate{
    private var client : MQTTSession? = nil
    public var regexTopics = [String: MqttRegex]()
    public var listeners = [String: Array<DaggerEventListener>?]()
    private var isConnectedToHost = false
    var processedoptions : Options
    
    public init(url : String, options : Options?)throws {
        if (url=="") {
            throw DaggerError(message: "Invalid URL")
        }
        if (options == nil) {
            processedoptions = Options()
        } else {
            processedoptions = options!
        }
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
        processedoptions.callback?.connectionLost(cause: error as NSError)
    }
    
    public func start() -> Bool{
        client!.delegate = self
        client!.connect { (error) in
        if error == .none {
            self.isConnectedToHost = true
            self.processedoptions.callback?.connected(dagger: self)
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

    
    public func on(eventName: String, listener: DaggerEventListener?)throws -> Dagger {
        return try self.addListener(eventName: eventName, listener: listener)
    }


    public func off(eventName: String, listener: DaggerEventListener?)throws -> Dagger {
        return try self.removeListener(eventName: eventName, listener: listener)
    }

    public func addListener(eventName: String, listener: DaggerEventListener?)throws-> Dagger {
        let mqttRegex = MqttRegex(t: eventName)
        if (regexTopics[mqttRegex.topic] == nil) { // subscribe events from server using topic
            
            client!.subscribe(to: eventName, delivering: .atLeastOnce) { (error) in
                if error == .none {
                    print("Subscribed to \(eventName)")
                    self.processedoptions.callback?.connected(dagger: self)
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

    public func removeListener(eventName: String, listener: DaggerEventListener?)throws-> Dagger {
        let mqttRegex = MqttRegex(t: eventName)
        // not working
        
        var list: Array<DaggerEventListener> = getEventListeners(eventName: eventName)
        print("list size before \(list.count)")
        if(listener != nil){
            for i in 0 ..< list.count {
                if (list[i] as DaggerEventListener as AnyObject === listener as DaggerEventListener? as AnyObject?) {
                    print("remove")
                    list.remove(at:i)
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

    public func removeAllListeners(eventName: String) {
        let mqttRegex = MqttRegex(t: eventName)
        // if listener count is zero, unsubscribe topic and delete from `_regexTopics`
       // unsubscribe events from server
        client?.unSubscribe(from: eventName, completion: nil)
        // remove MQTT regex from regex topics
        if (regexTopics[mqttRegex.topic] != nil) {
            regexTopics.removeValue(forKey: mqttRegex.topic)
        }

        listeners[eventName] = Array<DaggerEventListener>()
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
    private func getEventListeners(eventName: String)-> Array<DaggerEventListener> {
        if (listeners[eventName] == nil) {
            listeners[eventName] = Array()
        }
     return listeners[eventName]!!
    }
    
    private func emit(eventName: String, payload: Data) { // execute callback in all events
        for listener in getEventListeners(eventName: eventName) {
            listener.callback(topic: eventName, data: payload)
        }
    }
}
