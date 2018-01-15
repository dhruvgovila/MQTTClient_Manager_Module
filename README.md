# MQTTClient Manager Module

MQTT is a publish-subscribe-based messaging protocol. It works on top of the TCP/IP protocol. 
It is designed for connections with remote locations where a "small code footprint" is required or the network bandwidth is limited. 
The publish-subscribe messaging pattern requires a message broker.

Mqtt Client Manager Module helps the app to connect with the message broker.
This is written in Swift Programming Language. It also contains RxSwift to let the developer subscribe the new message event.
This module consist of 3 Files:
1. MQTT.swift
   This file helps the user to create/disable a connection, subscribe/ unsubscribe a topic. 
   This is a singleton class that can be accessed from anywhere in the code.
   
2. MQTTDelegate.swift
   This file helps a user to let know 
   a) If the message broken is connected/disconnected
   b) When a new message comes via message broker. It also contains a function to parse NSData to JSON.
   c) When QOS level is set to Exactly Once then there is a function to let know the app that the message has been delivered
   
3. MQTTConstant.swift
   This file lets the user declare the constant like host name, port no, client id, username and password at one place
   
