
import UIKit
import DaggerSwift

class ViewController: UIViewController {

    var dagger : Dagger!
    var count = 0
    var listener : successClosure?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listener = { topic, data in
            print(String(data: data, encoding: .utf8) as Any)
        }
        
        let onConnected : connectedClosure = { dagger in
            print("connected")
            do{
                _ = try dagger.on(eventName: "latest:block", listener: self.listener )
            } catch {
                print(error)
            }
            
        }
        
        let onConnectionLost : connectionLostClosure = { err in
            print("Connection Lost \(err)")
        }
        
        //        let options = Options(callback: callback)
        dagger = try! Dagger(url: "matic.dagger2.matic.network",onConnected : onConnected,onConnectionLost:onConnectionLost)
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
              _ = try dagger.removeListener(eventName: "latest:block", listener: listener)
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
