//
//  ViewController.swift
//  DaggerSwiftExample
//
//  Created by Abhriya Roy on 29/04/20.
//  Copyright © 2020 Matic Network. All rights reserved.
//

import UIKit
import Dagger

class ViewController: UIViewController {
    var dagger : Dagger!

    override func viewDidLoad() {
        super.viewDidLoad()
        let options = Options(callback : CallbackReceiver())
        dagger = try! Dagger(url: "matic.dagger2.matic.network", options: options)
        dagger.start()
            
            
            
        // Wait and keep listening dagger events
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
        do{
            try print("Connected: \(dagger.isConnected()), Subscriptions: \(dagger.getAllSubscriptions())")
        }
        catch{
            print(error)
        }
    }
        
        class CallbackReceiver : Callback {
            func connected(dagger : Dagger) {
                do{
                    try dagger.on(eventName: "latest:block", listener: ListenerImpl())
                } catch {
                    print(error)
                }
            }
            
            func connectionLost(cause: NSError?) {
                print("Connection lost. Reason: \(cause)")
            }
        }
        
        class ListenerImpl : DaggerCallbackListener{
            
            func callback(topic: String?, data: Data) {
                print("latest block data is \(String(decoding: data, as: UTF8.self))}")
            }
            
        }


}

