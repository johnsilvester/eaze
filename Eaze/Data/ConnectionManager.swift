//
//  ConnectionManager.swift
//  CardsAgainst
//
//  Created by JP Simard on 11/2/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

//used for example - will make my own version

import Foundation
import PeerKit
import MultipeerConnectivity

protocol MPCSerializable {
    var mpcSerialized: NSData { get }
    init(mpcSerialized: NSData)
}

enum Event: String {
    case sendData = "sendData", sayHello = "hello"
}

struct ConnectionManager {

//    // MARK: Properties
//
//    private static var peers: [MCPeerID] {
//        return PeerKit.session?.connectedPeers as [MCPeerID]? ?? []
//    }
    
    // MARK: Start

    static func start() {
        PeerKit.transceive(("eaze-transfer" ), discoveryInfo: ["hello": "hello there"])
        
    }

    // MARK: Event Handling

    static func onConnect(run: PeerBlock?) {
        PeerKit.onConnect = run
        
            }

    static func onDisconnect(run: PeerBlock?) {
        PeerKit.onDisconnect = run
    }

    static func onEvent(event: Event, run: ObjectBlock?) {
        print("Saw event")
        
        print(PeerKit.eventBlocks[event.rawValue]!)
        
        if event == Event.sayHello {
            print("Saw Hello")
        }
        
        
        if let run = run {
            
            PeerKit.eventBlocks[event.rawValue] = run
            
           
            
        } else {
            PeerKit.eventBlocks.removeValue(forKey: event.rawValue)
        }
    }

    // MARK: Sending

    static func sendEvent(event: Event, object: [String: MPCSerializable]? = nil) {
        var anyObject: [String: NSData]?
        if let object = object {
            anyObject = [String: NSData]()
            for (key, value) in object {
                anyObject![key] = value.mpcSerialized
            }
        }
        PeerKit.sendEvent(event.rawValue, object: anyObject as AnyObject )
    }

    
}
