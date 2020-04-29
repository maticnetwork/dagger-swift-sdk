import UIKit
import Dagger

class ViewController: UIViewController {
    var dagger : Dagger!
    var count = 0;
    var callback = CallbackReceiver()
    var eventListner = ListenerImpl()

    override func viewDidLoad() {
        super.viewDidLoad()
        callback.parent = self
        let options = Options(callback : callback)
        dagger = try! Dagger(url: "matic.dagger2.matic.network", options: options)
        dagger.start()
            
            
            
        // Wait and keep listening dagger events
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
        count=count+1;
        do{
            try print("Connected: \(dagger.isConnected()), Subscriptions: \(dagger.getAllSubscriptions())")
            
            // sample remove listener after 10 seconds
            if count==2 {
               try dagger.removeListener(eventName: "latest:block", listener: eventListner)
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
    
    class CallbackReceiver : Callback {
        weak var parent : ViewController! // Can be any parent class
    
        func connected(dagger : Dagger) {
            do{
                try dagger.on(eventName: "latest:block", listener: parent!.eventListner)
            } catch {
                print(error)
            }
        }
        
        func connectionLost(cause: NSError?) {
            print("Connection lost. Reason: \(cause)")
        }
    }
    
    class ListenerImpl : DaggerEventListener{
        
        func callback(topic: String?, data: Data) {
            print("latest block data is \(String(decoding: data, as: UTF8.self))}")
        }
        
    }

}

