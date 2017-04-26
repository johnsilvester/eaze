//
//  MCTestViewController.swift
//  Eaze
//
//  Created by John Silvester on 4/21/17.
//  Copyright © 2017 Hangar42. All rights reserved.
//

import UIKit

class MCTestViewController: UIViewController {
    
    let colorService = MCServiceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorService.delegate = self

        // Do any additional setup after loading the view.
    }
    @IBOutlet var connectedLabel: UILabel!

    @IBAction func yellowTap(_ sender: Any) {
        self.change(color: .yellow)
        colorService.send(command: "yellow")
    }
  
    @IBAction func redTap(_ sender: Any) {
        self.change(color: .red)
        colorService.send(command: "red")
    }
    
    func change(color : UIColor) {
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = color
        }
    }
    
    
}
extension MCTestViewController : MCServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: MCServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            //self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    func commandChanged(manager: MCServiceManager, command: String) {
        OperationQueue.main.addOperation {
            switch command {
            case "CL":
                self.change(color: .red)
            case "FM":
                self.change(color: .yellow)
            default:
                NSLog("%@", "Unknown color value received: \(command)")
            }
        }
    }
    
    func isConnected(manager: MCServiceManager, val: Int) {
        
        
        switch val {
        case 1:
            self.connectedLabel.text = "Connecting"
            self.connectedLabel.textColor = UIColor.green
        case 2:
            self.connectedLabel.text = "Connected"
            self.connectedLabel.textColor = UIColor.blue
        case 0:
            self.connectedLabel.text = "Not Connected"
            self.connectedLabel.textColor = UIColor.red
        
        default:
            self.connectedLabel.text = "Not Connected \(val)"
        }

        
    }
    
}
