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



class ControllerViewController: UIViewController,CLLocationManagerDelegate, MSPUpdateSubscriber{
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var statusLabel: UILabel!
    
    //MARK: MSP
    private let slowMSPCodes = [MSP_SET_WP,MSP_STATUS]
    ///Timer for follow me func - sent every 5 seconds
    var slowTimer = Timer()
    var navWPNumber = 0
    var navAlt = 100.0
    
    //MARK: P2P Comm
    let peerService = MCServiceManager()
    
    //MARK: Location Settings
    let locationManager = CLLocationManager()
    var currentLocation = (CLLocationCoordinate2D.init(latitude: 0, longitude: 0))
    var otherPhonesLocation = (CLLocationCoordinate2D.init(latitude: 0, longitude: 0))
    
    //MARK: GPS Status
    var gpsMode = dataStorage.GPSModeMessages[dataStorage.GPSModeNavStatus]
    var navState = dataStorage.navStateMessages[dataStorage.navStateNavStatus]
    var action = dataStorage.actionNavStatus
    var wpNumber = dataStorage.wpNumberNavStatus
    var navError = dataStorage.navErrorMessages[dataStorage.navErrorNavStatus]
    var targetBearing = dataStorage.targetBearingNavStatus
    

    
    //MARK: - SetUp
    
    
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peerService.delegate = self
        
        self.setupCoreLocation()
        
        msp.addSubscriber(self, forCodes: slowMSPCodes)
        
        
    }
    
    
    //MARK - MSP - Implmentation
    func sendSlowDataRequest() {
        
        for code in slowMSPCodes{
            switch code {
            case MSP_SET_WP:
                
                self.loadMap()
                
                dataStorage.wpNumber = navWPNumber
                dataStorage.wpAction = 0 // ?
                dataStorage.wpLat = currentLocation.latitude
                dataStorage.wpLon = currentLocation.longitude
                dataStorage.wpAlt = navAlt
                
                navWPNumber = navWPNumber + 1
                
            case MSP_STATUS:
                print("sent Status")
            default:
                break
            }
        }
    }
    
    
    
    func mspUpdated(_ code: Int) {
        switch code {
            
        case MSP_NAV_STATUS:
            gpsMode = dataStorage.GPSModeMessages[dataStorage.GPSModeNavStatus]
            navState = dataStorage.navStateMessages[dataStorage.navStateNavStatus]
            action = dataStorage.actionNavStatus
            wpNumber = dataStorage.wpNumberNavStatus
            navError = dataStorage.navErrorMessages[dataStorage.navErrorNavStatus]
            targetBearing = dataStorage.targetBearingNavStatus
            
            print("GPS MODE: \(gpsMode)\n Nav State: \(navState)\n WP NUMBER: \(wpNumber)\n NAV ERR: \(navError)\n TARGET BEARING: \(targetBearing)\n ACTION: \(action)\n")
            
        default:
            log(.Warn, "Invalid MSP code update sent to HomeViewController: \(code)")
        }
    }
    
    //MARK - Location Implementation
    
    @IBAction func getCurrentLocation(_ sender: Any) {
        
        let currentLocationString = "CL,\(currentLocation.latitude),\(currentLocation.longitude)"
        
        print(currentLocationString)
        
        peerService.send(command: currentLocationString) // send current location
        
        self.loadMap()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        currentLocation = (manager.location?.coordinate)!
        
    }
    
    //MARK: - P2P Commincation
    
    @IBAction func browse(_ sender: Any) {
        peerService.browse()
    }
    
    @IBAction func advertise(_ sender: Any) {
        peerService.advertise()
    }
    
    //MARK: -  Actions
    
    @IBAction func engageFollowMe(_ FMButton: UIButton){
        
        
        slowTimer = Timer.scheduledTimer( timeInterval: 5,target: self,selector: #selector(sendSlowDataRequest),userInfo: nil,repeats: true)
        
        
    }
    
    
    @IBAction func land(_ landButton: UIButton){
        
        slowTimer.invalidate()
        
        //set MSP to land! for later
        
        
        
    }
    
    
    @IBAction func stepperValueChanged(_ altStepper: UIStepper) {
        
        
        navAlt = altStepper.value
        statusLabel.text = "Alt: \(altStepper.value) cm"
        
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

