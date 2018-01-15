//
//  MQTTDelegate.swift
//  KarruPro
//
//  Created by Dhruv Govila on 24/11/17.
//  Copyright © 2017 Dhruv Govila. All rights reserved.
//
import MQTTClient

class MQTTDelegate:NSObject, MQTTSessionDelegate
{
    //RxSwift variable to notify for new message
    
    let mqttOnDemandManager = MQTTOnDemandAppManager()
    func handleEvent(_ session: MQTTSession!, event eventCode: MQTTSessionEvent, error: Error!) {
        switch eventCode {
            
        case .connected:
            print("connected")
            MQTT.sharedInstance.isConnected = true
            session.subscribe(toTopic:"test", at: .atLeastOnce)
            
            
        case .connectionClosed:
            print("disconnected")
            MQTT.sharedInstance.isConnected = false
            
        default:
            print("disconnected")
            MQTT.sharedInstance.isConnected = false
        }
    }
    
    func newMessage(_ session: MQTTSession!, data: Data!, onTopic topic: String!, qos: MQTTQosLevel, retained: Bool, mid: UInt32) {
        print("Message Received: \(data) on:\(topic) q\(qos) r\(retained) m\(mid)")
        let response = nsdataToJSON(data: data)
        print(response as Any)
        if let mqttData : [String: Any] = response as? [String: Any]
        {
            MQTT.sharedInstance.mqttNewMessage.onNext((mqttData))
        }
    }
    
    /// Function to parse NSData to JSON
    func nsdataToJSON(data: Data) -> Any? {
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
    
    func subAckReceived(_ session: MQTTSession!, msgID: UInt16, grantedQoss qoss: [NSNumber]!) {
        print(msgID,"sub Ack Recieved")
    }
    
    
}
