//
//  MQTTModule.swift
//  MQTT Chat Module
//
//  Created by Dhruv Govila on 11/07/17.
//  Copyright © 2017 Dhruv Govila. All rights reserved.
//

import UIKit
import MQTTClient
import Foundation
import RxSwift

protocol MQTTManagerDelegate {
    func receivedMessage(_ message:[AnyHashable : Any]!, andChannel channel: String!)
}


/// This class is a model for interacting with the SwiftMQTT library.
class MQTT : NSObject {
    
    struct Constants {
        ///Ask server guy for host and port.
        fileprivate static let host = MQTTConstants.host
        fileprivate static let port:UInt32 = MQTTConstants.port
        
        /// your current userID
        fileprivate static let userID = MQTTConstants.userID
    }
    
    var delegate: MQTTManagerDelegate? = nil {
        didSet {
            
            print("set")
            
        }
    }
    
    //mqtt delegate
    static let sharedDelegateInstance = MQTTDelegate()
    
    /// Shared instance object for gettting the singleton object
    static let sharedInstance = MQTT()
    
    ///current session object will going to store in this.
    var mqttSession: MQTTSession!
    
    ///Used for running the task in the background.
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    /// MQTT delegate object, its going to store the objects of the delegate receiver class.
    //    let mqttMessageDelegate = MQTTDelegate()
    var isConnected: Bool = false;
    
    //RxSwift variable to notify for new message
    var mqttNewMessage = PublishSubject<([String: Any])>()

    //MQTTOn
    
    /// Used for creating the initial connection.
    func createConnection() {
        
        /// Observer for app coming in foreground.
        NotificationCenter.default.addObserver(self, selector: #selector(MQTT.reinstateBackgroundTask), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        registerBackgroundTask()
        
        ///creating connection with the proper client ID.
        self.connect(withClientId: Constants.userID)        
    }
    
    /// Used for subscribing the channel
    ///
    /// - Parameter channelName: current channel which you want to subscribe.
    func subscribeChannel(withChannelName channelName : String ) {
        let topicToSubscribe = channelName
        self.subscribe(topic: "\(topicToSubscribe)", withDelivering: .exactlyOnce)
    }
    
    
    
    /// Used for Unsubscribing the channel
    ///
    /// - Parameter channelName: current channel which you want to Unsubscribing.
    func unsubscribeTopic(topic : String) {
        mqttSession.unsubscribeTopic(topic) { (error) in
            print(error ?? "Unsubscribe Succesfully")
        }
    }
    
    /// Used for subscribing the channel
    ///
    /// - Parameters:
    ///   - topic: name of the current topic (It should contain the name of the topic with saperators)
    ///
    /// eg- Message/UserName
    ///   - Delivering: Type of QOS // can be 0,1 or 2.
    fileprivate func subscribe(topic : String, withDelivering Delivering : MQTTQosLevel) {
        mqttSession.subscribe(toTopic: topic, at: Delivering) { (error, subscriptionArray) in
            print(error ?? "", subscriptionArray ?? "")
        }
    }
    
    /// Used for reinstate the background task
    @objc func reinstateBackgroundTask() {
        if (backgroundTask == UIBackgroundTaskInvalid) {
            registerBackgroundTask()
        }
    }
    
    ///Here I am registering for the background task.
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    ///Before background task ending this method is going to be called.
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    /// Used for pubishing the data in between channels.
    ///
    /// - Parameters:
    ///   - jsonData: Data in JSON format.
    ///   - channel: current channel name to publish the data to.
    ///   - messageID: current message ID (this ID should be unique)
    ///   - Delivering: Type of QOS // can be 0,1 or 2.
    ///   - retain: true if you wanted to retain the messages or False if you don't
    ///   - completion: This will going to return MQTTSessionCompletionBlock.
    
    func publishData(wthData jsonData: Data, onTopic topic : String, retain : Bool, withDelivering delivering : MQTTQosLevel) {
        mqttSession.publishData(jsonData, onTopic: topic, retain:retain , qos: delivering) { (error) in
            if let error = error {
                print("failed with error",error)
            }
        }
    }
    
    
    /// Used for creating the initial connection.
    func connect() {
        guard let newSession = MQTTSession() else {
            fatalError("Could not create MQTTSession")
        }
        
        newSession.connect(toHost: Constants.host, port: Constants.port, usingSSL: false)
        
        newSession.publishData("sent from Xcode using Swift".data(using: String.Encoding.utf8, allowLossyConversion: false),
                               onTopic: "testtopic",
                               retain: false,
                               qos: .atMostOnce)        
        newSession.close()
    }
    
    /// Used for connecting with the server.
    ///
    /// - Parameter clientId: current Client ID.
    func connect(withClientId clientId :String) {
        let host = Constants.host
        let port: UInt32 = Constants.port
        guard let newSession = MQTTSession() else {
            fatalError("Could not create MQTTSession")
        }
        mqttSession = newSession
        newSession.delegate = MQTT.sharedDelegateInstance
        newSession.keepAliveInterval = 60 
        newSession.userName = MQTTConstants.userName
        newSession.password = MQTTConstants.password
        newSession.clientId = clientId
        
        newSession.connect(toHost: host, port: port, usingSSL: false) { (error) in
            if let error = error {
                print("Session is unable to connect",error)
            } else {
                print("Connected")
            }
        }
    }
}





