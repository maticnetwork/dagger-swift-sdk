//
//  ViewController.swift
//  Example
//
//  Created by Jyoti on 13/05/20.
//  Copyright © 2020 Matic. All rights reserved.
//

import UIKit
import Dagger

class ViewController: UIViewController {

    var dagger : Dagger!
    var count = 0
    var callback : Callback?
    var eventListner : DaggerEventListener?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let options = Options()
        dagger = try! Dagger(url: "matic.dagger2.matic.network", options: options)
        _ = dagger.start()
            
        // Wait and keep listening dagger events
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
        count=count+1;
        do{
             print("Connected: \(dagger.isConnected()), Subscriptions: \(dagger.getAllSubscriptions())")
            
            // sample remove listener after 10 seconds
            if count==2 {
              _ = try dagger.removeListener(eventName: "latest:block", listener: eventListner)
            }
            
            // sample stop dagger
            if count==3 {
               dagger.stop()
            }
        }
        catch{
            print(error)
        }
    }


}

extension ViewController : Callback {
    func connectionLost(cause: NSError?) {
        print("Connection lost. Reason: \(cause)")
    }
    
    func connected(dagger: Dagger) {
        do{
            _ = try dagger.on(eventName: "latest:block", listener: eventListner)
        } catch {
            print(error)
        }
    }
}

extension ViewController : DaggerEventListener {
    func callback(topic: String?, data: Data) {
        print("latest block data is \(String(decoding: data, as: UTF8.self))}")
    }
    
}

