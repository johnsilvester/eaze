//
//  ScratchPad.swift
//  Eaze
//
//  Created by John Silvester on 4/30/17.
//  Copyright © 2017 Hangar42. All rights reserved.
//

import Foundation




//taken From ControllerViewController.swift - used for RC override via MSP

// MARK: - Data request / update
private let fastMSPCodes = [MSP_STATUS]
func sendFastDataRequest() {
//    
//    //test code for splitting up set rc raw
//    for code in fastMSPCodes{
//        if code == MSP_STATUS{
//            print("Reading MSP_STATUS")
//        }
//        
//        
//        
//        if code == MSP_SET_RAW_RC{
//            //ROLL/PITCH/YAW/THROTTLE/AUX1/AUX2/AUX3AUX4
//            
//            //create values
//            let rcChannels: [UInt16] = [UInt16(dataStorage.rcRoll),UInt16(dataStorage.rcPitch),UInt16(dataStorage.rcThrottle),UInt16(1500),UInt16(dataStorage.rcAuxOne),UInt16(dataStorage.rcAuxTwo),UInt16(dataStorage.rcAuxThree)]
//            
//            msp.sendRawRC(channels: rcChannels) //send raw rc
//        }
//        else{
//            
//            msp.sendMSP(code)
//        }
//    }
    
    
    
}

///*Sanity* check for making sure RC Values will not cuase craft to fly away
func setBaseValues(){
    
    dataStorage.rcPitch = 1500;
    dataStorage.rcRoll = 1500;
    dataStorage.rcYaw = 1500;
    dataStorage.rcThrottle = 1000;
    dataStorage.rcAuxOne = 1000;
    dataStorage.rcAuxTwo = 1000;
    dataStorage.rcAuxThree = 1000;
    
}
