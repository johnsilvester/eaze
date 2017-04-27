//
//  ControllerViewController.swift
//  Eaze
//
//  Created by John Silvester on 4/25/17.
//  Copyright © 2017 Hangar42. All rights reserved.
//
import Foundation
import UIKit
import MapKit
import CoreLocation


//4/26 NOTES: i believe the connecting and receiving fucks up the connection.
//when you do both connecting and receiving.


class ControllerViewController: UIViewController,CLLocationManagerDelegate, MSPUpdateSubscriber{

    @IBOutlet var mapView: MKMapView!
  
    @IBOutlet var statusLabel: UILabel!
    
    private let fastMSPCodes = [MSP_SET_RAW_RC,MSP_ALTITUDE]
    
    let locationManager = CLLocationManager()
    
    let peerService = MCServiceManager()
    
    var currentLocation = (CLLocationCoordinate2D.init(latitude: 0, longitude: 0))
    
    var otherPhonesLocation = (CLLocationCoordinate2D.init(latitude: 0, longitude: 0))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        peerService.delegate = self
        
        self.setupCoreLocation()
        
       // peerService.browse()
        
        var fastUpdateTimer = Timer.scheduledTimer( timeInterval: 0.15,
                                                                      target: self,
                                                                      selector: #selector(self.sendFastDataRequest),
                                                                      userInfo: nil,
                                                                      repeats: true)
        
        msp.addSubscriber(self, forCodes: fastMSPCodes)
        
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Data request / update
    
    func sendFastDataRequest() {
        
        //test code for splitting up set rc raw
        for code in fastMSPCodes{
            
            if code == MSP_SET_RAW_RC{
                //ROLL/PITCH/YAW/THROTTLE/AUX1/AUX2/AUX3AUX4
                
                //create values
                let rcChannels: [UInt16] = [UInt16(dataStorage.rcRoll),UInt16(dataStorage.rcPitch),UInt16(dataStorage.rcThrottle),UInt16(1500),UInt16(dataStorage.rcAuxOne),UInt16(dataStorage.rcAuxTwo),UInt16(dataStorage.rcAuxThree)]
                
                msp.sendRawRC(channels: rcChannels) //send raw rc
            }
            else{
                
                msp.sendMSP(code)
            }
        }
        
        
        
    }
    
    
    
    func mspUpdated(_ code: Int) {
        switch code {
            
        case MSP_SET_RAW_RC:
            print("")
        case MSP_ALTITUDE:
            altitudeLabel.text = "Altitude: \(dataStorage.altitude)"
            
        default:
            log(.Warn, "Invalid MSP code update sent to HomeViewController: \(code)")
        }
    }
    
    func setBaseValues(){
        
        dataStorage.rcPitch = 1500;
        dataStorage.rcRoll = 1500;
        dataStorage.rcYaw = 1500;
        dataStorage.rcThrottle = 1000;
        dataStorage.rcAuxOne = 1000;
        dataStorage.rcAuxTwo = 1000;
        dataStorage.rcAuxThree = 1000;
        
    }
    

    func setupCoreLocation(){
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
        
    }
    func loadMap() {
        mapView.mapType = MKMapType.hybrid
        
        // 3)
        let span = MKCoordinateSpanMake(0.00005, 0.00005)
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        // 4)
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapView.userLocation.coordinate
        annotation.title = "You Are Here!"
        annotation.subtitle = "Start Walking!"
        mapView.addAnnotation(annotation)
    }

    @IBAction func getCurrentLocation(_ sender: Any) {
        
        let currentLocationString = "CL,\(currentLocation.latitude),\(currentLocation.longitude)"
        
        print(currentLocationString)
        
        peerService.send(command: currentLocationString) // send current location
        
        self.loadMap()

    }
 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        currentLocation = (manager.location?.coordinate)!
        
    }
    
    @IBAction func browse(_ sender: Any) {
        peerService.browse()
    }
   
    @IBAction func advertise(_ sender: Any) {
        peerService.advertise()
    }
}


//MARK: mcservice delegate
extension ControllerViewController : MCServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: MCServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            //self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    func commandChanged(manager: MCServiceManager, command: String) {
        
        OperationQueue.main.addOperation {
            
            switch command {
           
            case _ where command.hasPrefix("CL"):
                
                self.loadMap()
                
                let stringValues = command.components(separatedBy: ",")
                
                
                self.otherPhonesLocation = CLLocationCoordinate2DMake(CLLocationDegrees(stringValues[1].floatValue), CLLocationDegrees(stringValues[2].floatValue)) //cl coordinates
                
                
                
                if self.otherPhonesLocation.longitude != 0{ //there ARE location coordinates
                    //add into map
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = self.otherPhonesLocation
                    self.mapView.addAnnotation(annotation)
                }
       
                
            
            case _ where command.hasPrefix("FM"):
              break
            
            case _ where command.hasPrefix("LD"):
                break
            
            default:
                NSLog("%@", "Unknown command value received: \(command)")
            }
            
        }
        
    }
    
    func isConnected(manager: MCServiceManager, val: Int) {
        
        
        switch val {
        case 1:
            self.statusLabel.text = "Status: Connecting"
            self.statusLabel.textColor = UIColor.green
        case 2:
            self.statusLabel.text = "Status: Connected"
            self.statusLabel.textColor = UIColor.blue
        case 0:
            self.statusLabel.text = "Status: Not Connected"
            self.statusLabel.textColor = UIColor.red
            
        default:
            self.statusLabel.text = "Status: Not Connected \(val)"
        }
        
        
    }
    
    
    
}

