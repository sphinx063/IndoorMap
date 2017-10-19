//
//  ViewController.swift
//  IndoorMap
//

import UIKit

class ViewController: UIViewController, EILIndoorLocationManagerDelegate, ESTTriggerManagerDelegate, CLLocationManagerDelegate {
    
    let locationManager = EILIndoorLocationManager()
    let clLocationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: NSUUID(uuidString:"00000000-0000-0000-0000-000000001111")! as UUID, identifier:"estimote")
    
    var location: EILLocation!
    
    @IBOutlet weak var locationView: EILIndoorLocationView!
    
    @IBOutlet weak var itemId: UITextField!
    
    
    @IBOutlet weak var BeaconMajor: UILabel!
    
    @IBAction func viewAssets(_sender: Any){
        
        
        
    }
    
    @IBAction func locationUpdate(_ sender: Any) {
        print(x)
        print(y)
        let item = self.itemId.text
        var constructUrl = "http://apps.holtec.com/ICS/pw/AddLoc?zoneID=warehouse&itemID="
        constructUrl+=item!
        constructUrl+="&xcord="
        constructUrl+=String(format:"%f",x)
        constructUrl+="&ycord="
        constructUrl+=String(format:"%f",y)
        print(item ?? "nothing")
        //  if let url = URL(string: constructUrl){
        //     UIApplication.shared.openURL(url)
        //}
        
        
        
        URLSession.shared.dataTask(with: NSURL(string: constructUrl)! as URL) { data, response, error in
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode==200{
                //itemId.text?.removeAll()
            }
            }.resume()
        
    }
    
    
    //-------------------------------------------------------------------
    var beaconsInRange: [CLBeacon] = []
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("beacons detected")
        beaconsInRange.removeAll()
        if(beacons.count>0){
            for i in 0...beacons.count-1{
                if(beacons[i].rssi != 0){
                    print("------")
                    print(beacons[i].major)
                    print(beacons[i].rssi)
                    print("-----")
                    beaconsInRange.append(beacons[i])
                }
            }
            
            if(beaconsInRange.count>0){
                let sortedBeacons = beaconsInRange.sorted { $0.rssi > $1.rssi }
                
                let nearestBeacon = sortedBeacons.first!
                print("beacons sorted")
                print(nearestBeacon.major)
                if(nearestBeacon.rssi != 0){
                    
                    print(nearestBeacon.major)
                    print(nearestBeacon.proximity.hashValue)
                    BeaconMajor.text="Nearest aseet is: "+String(describing: nearestBeacon.major)
                    
                    itemId.text=String(describing: nearestBeacon.major)
                    
                }
                else{
                    print(nearestBeacon.rssi)
                    print("unknown range")
                    BeaconMajor.text="Searching Assets........"
                    itemId.text?.removeAll()
                }
                /*   if nearestBeacon.proximity == CLProximity.immediate  {
                 BeaconMajor.text="At Asset with Id: "+String(describing: nearestBeacon.major)
                 itemId.text=String(describing: nearestBeacon.major)
                 
                 }else if nearestBeacon.proximity == CLProximity.near{
                 BeaconMajor.text="At Asset with Id: "+String(describing: nearestBeacon.major)
                 itemId.text=String(describing: nearestBeacon.major)
                 sleep(5)
                 }else if nearestBeacon.proximity == CLProximity.far{
                 print(nearestBeacon.minor)
                 print("far")
                 
                 BeaconMajor.text="Asset in range with Id: "+String(describing: nearestBeacon.major)
                 
                 itemId.text=String(describing: nearestBeacon.major)
                 
                 }
                 else{
                 print("unknown range")
                 BeaconMajor.text="Searching Assets........"
                 itemId.text?.removeAll()
                 
                 }*/
                
            }else{
                
                BeaconMajor.text="Searching Assets........"
                itemId.text?.removeAll()
            }
        }else{
            BeaconMajor.text="Searching Assets........"
            itemId.text?.removeAll()
        }
    }
    
    
    
    
    
    
    //-------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ESTConfig.setupAppID("archit-asu-gmail-com-s-not-58a", andAppToken: "c7c78b49c21b51fb58f60e639e574bf5")
        
        //nearable app
        //  self.triggerManager.delegate = self
        
        self.locationManager.delegate = self
        clLocationManager.delegate=self
        
        clLocationManager.requestAlwaysAuthorization()
        self.locationManager.mode = EILIndoorLocationManagerMode.light
        
        let fetchLocationRequest = EILRequestFetchLocation(locationIdentifier: "partial-warehouse-7")
        fetchLocationRequest.sendRequest { (location, error) in
            if let location = location {
                self.location = location
                
                // You can configure the location view to your liking:
                self.locationView.showTrace = true
                self.locationView.rotateOnPositionUpdate = false
                self.locationView.traceColor=UIColor.blue
                self.locationView.isUserInteractionEnabled=true
                self.locationView.backgroundColor=UIColor.gray
                // self.locationView.isUserInteractionEnabled=true
                // Consult the full list of properties on:
                // http://estimote.github.io/iOS-Indoor-SDK/Classes/EILIndoorLocationView.html
                
                self.locationView.drawLocation(location)
                self.locationManager.startPositionUpdates(for: self.location)
            } else if let error = error {
                print("can't fetch location: \(error)")
            }
        }
        
        //nearable app
        // let rule1 = ESTOrientationRule.orientationEquals(.horizontalUpsideDown, for: .bike)
        // let rule2 = ESTMotionRule.motionStateEquals(true, forNearableIdentifier: "d547f7cf6bb5ba75")
        // let trigger = ESTTrigger(rules: [rule1], identifier:"d547f7cf6bb5ba75")
        // self.triggerManager.startMonitoring(for: trigger)
        //
        clLocationManager.startRangingBeacons(in: region)
    }
    
    func indoorLocationManager(_ manager: EILIndoorLocationManager, didFailToUpdatePositionWithError error: Error) {
        print("failed to update position: \(error)")
    }
    var x=0.0
    var y=0.0
    func indoorLocationManager(_ manager: EILIndoorLocationManager, didUpdatePosition position: EILOrientedPoint, with positionAccuracy: EILPositionAccuracy, in location: EILLocation) {
        //  print(String(format: "x: %5.2f, y: %5.2f, orientation: %3.0f", position.x, position.y, position.orientation))
        x=position.x
        y=position.y
        //print(x)
        
        self.locationView.updatePosition(position)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* func triggerManager(_ manager: ESTTriggerManager, triggerChangedState trigger: ESTTrigger) {
     print("triggered")
     if(trigger.identifier=="d547f7cf6bb5ba75" && trigger.state==true){
     print("sticker moved")
     }
     else{
     print("sticker stable")
     }
     }
     */
}