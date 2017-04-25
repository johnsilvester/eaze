//
//  MCTestViewController.swift
//  Eaze
//
//  Created by John Silvester on 4/21/17.
//  Copyright © 2017 Hangar42. All rights reserved.
//

import UIKit

class MCTestViewController: UIViewController {
    let colorService = ColorServiceManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        colorService.delegate = self

        // Do any additional setup after loading the view.
    }
    @IBOutlet var connectedLabel: UILabel!

    @IBAction func yellowTap(_ sender: Any) {
        self.change(color: .yellow)
        colorService.send(colorName: "yellow")
    }
  
    @IBAction func redTap(_ sender: Any) {
        self.change(color: .red)
        colorService.send(colorName: "red")
    }
    
    func change(color : UIColor) {
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = color
        }
    }
    
    
}
extension MCTestViewController : ColorServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: ColorServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            //self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    func colorChanged(manager: ColorServiceManager, colorString: String) {
        OperationQueue.main.addOperation {
            switch colorString {
            case "red":
                self.change(color: .red)
            case "yellow":
                self.change(color: .yellow)
            default:
                NSLog("%@", "Unknown color value received: \(colorString)")
            }
        }
    }
    
    func isConnected(manager: ColorServiceManager, val: Int) {
        
        if val==1 {
            self.connectedLabel.text = "Connecting"
            self.connectedLabel.textColor = UIColor.green
        }
        else if val == 2{
            self.connectedLabel.text = "Connected"
            self.connectedLabel.textColor = UIColor.blue

        }
        
        else{
            self.connectedLabel.text = "Not Connected"
            self.connectedLabel.textColor = UIColor.red
        }
    }
    
}
