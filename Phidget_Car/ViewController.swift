//
//  ViewController.swift
//  Phidget_Car
//
//  Created by Christopher Landry on 2018-11-19.
//  Copyright © 2018 Christopher Landry. All rights reserved.
//

import UIKit
import Phidget22Swift
import WebKit

class ViewController: UIViewController {
    
   
    @IBOutlet weak var webCamViewer: WKWebView!
    
    var videoId: String?
    
    let leftside = DCMotor()
    let rightside = DCMotor()
    let Sonar0 = DistanceSensor()
    let xAxis = VoltageRatioInput()
    let yAxis = VoltageRatioInput()
    let click = DigitalInput()
    
    
    @IBOutlet weak var backUp: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    func attach_handler(sender: Phidget) {
        do {
            let hubPort = try sender.getHubPort()
            
            if (hubPort == 0) {
                print("The motor 1 attached")
            }
            else if (hubPort == 5) {
                print("Motor 2 is attached")
            } else if (hubPort == 1) {
                print("Sonar is attached")
            }

        } catch let err as PhidgetError {
            print("Phidget Error " + err.description)
        } catch {
            //catch other errors here
        }
    }
    
    func attach_handler2(sender: Phidget) {
        do {
            let hubPort = try sender.getHubPort()
            
            if (hubPort == 0) {
                print("thumbstick is attached")
                try self.xAxis.setDataInterval(100)
                try self.yAxis.setDataInterval(100)
            }
        }catch let err as PhidgetError {
            print("Phidget Error " + err.description)
        } catch {
            //catch other errors here
        }
    }

    func xfunc_handler(sender: VoltageRatioInput, voltageRatioHorz: Double) {
        do {
            if (voltageRatioHorz > 0.5) {
                try leftside.setAcceleration(100)
                try rightside.setAcceleration(100)
                try leftside.setTargetVelocity(1.0)
                try rightside.setTargetVelocity(-1.0)
            }
            else if (voltageRatioHorz < -0.5) {
                try leftside.setAcceleration(100)
                try rightside.setAcceleration(100)
                try leftside.setTargetVelocity(-1.0)
                try rightside.setTargetVelocity(1.0)
            }
            else if (voltageRatioHorz > -0.5 || voltageRatioHorz < 0.5){
                try rightside.setTargetVelocity(0)
                try leftside.setTargetVelocity(0)

            }
            //print(voltageRatioHorz)
        } catch let err as PhidgetError {
            print("Phidget Error " + err.description)
        } catch {
            //catch other errors here
        }
    }
 
    
    func yfunc_handler(sender: VoltageRatioInput, voltageRatioVert: Double) {
        do{
            if (voltageRatioVert > 0.5) {
                try leftside.setAcceleration(100)
                try rightside.setAcceleration(100)
                try leftside.setTargetVelocity(1.0)
                try rightside.setTargetVelocity(1.0)
            }
            else if (voltageRatioVert < -0.5) {
                try leftside.setAcceleration(100)
                try rightside.setAcceleration(100)
                try leftside.setTargetVelocity(-1.0)
                try rightside.setTargetVelocity(-1.0)
            }
            else if (voltageRatioVert > -0.5 || voltageRatioVert < 0.5){
                try rightside.setTargetVelocity(0)
                try leftside.setTargetVelocity(0)
            }
            //print(voltageRatioVert)
        } catch let err as PhidgetError {
            print("Phidget Error " + err.description)
        } catch {
            //catch other errors here
        }
    }
    
    func state_change (sender: DigitalInput, state: Bool) {
        if (state == true){
            print("You clicked it xd")
        }
    }
    let yeet = 0;
    func distanceChange_handler(sender: DistanceSensor, distance: UInt32){
        do{
            DispatchQueue.main.async {
                self.distanceLabel.text = String(distance)
                self.backUp.text = "Backing Up, one sec"
            }
            print("The distance for sonar is: ", distance, "\n")
            let sensor = sender
            _  = try sensor.getDeviceSerialNumber()
            if (distance <= 90) {
                try yAxis.close()
                try xAxis.close()
                try leftside.setAcceleration(100)
                try rightside.setAcceleration(100)
                try leftside.setTargetVelocity(-1.0)
                try rightside.setTargetVelocity(-1.0)
                
            }
            else if (distance >= 100) {
                DispatchQueue.main.async {
                    self.backUp.text = "All good"
                }
                try yAxis.open()
                try xAxis.open()
                //try leftside.setTargetVelocity(0)
                //try rightside.setTargetVelocity(0)
            }
            else if (distance <= 1) {
                try leftside.setAcceleration(100)
                try rightside.setAcceleration(100)
                try leftside.setTargetVelocity(-1.0)
                try rightside.setTargetVelocity(-1.0)
            }
            else {
                try yAxis.open()
                try xAxis.open()
                DispatchQueue.main.async {
                    self.backUp.text = "All good"
                }
            }

        } catch let err as PhidgetError {
            print("Phidget Error" + err.description)
        } catch {
            //catch other errors here
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try Net.enableServerDiscovery(serverType: .deviceRemote)
            try Net.addServer(serverName: "phidgetsbc", address: "192.168.99.1", port: 5661, password: "", flags: 0);
            
            if let videoId = videoId {
                print(videoId)
            }
            webCamViewer.load(URLRequest(url: URL(fileURLWithPath: "http://192.168.99.1:81/?action=stream")))

            
            //address objects
            // horz for stick
            try xAxis.setDeviceSerialNumber(528038)
            try xAxis.setHubPort(0)
            try xAxis.setIsHubPortDevice(false)
            try xAxis.setChannel(1)
            
            // vert for stick
            try yAxis.setDeviceSerialNumber(528038)
            try yAxis.setHubPort(0)
            try yAxis.setIsHubPortDevice(false)
            try yAxis.setChannel(0)
            
            //click for the stick
            try click.setDeviceSerialNumber(528038)
            try click.setHubPort(0)
            try click.setIsHubPortDevice(false)
            
            //first half of motors
            try leftside.setDeviceSerialNumber(514817)
            try leftside.setHubPort(5)
            try leftside.setIsHubPortDevice(false)
            
            // second half of motors
            try rightside.setDeviceSerialNumber(514817)
            try rightside.setHubPort(0)
            try rightside.setIsHubPortDevice(false)
            
            //sonar
            try Sonar0.setDeviceSerialNumber(514817)
            try Sonar0.setHubPort(1)
            try Sonar0.setIsHubPortDevice(false)
            
            let _ = Sonar0.attach.addHandler(attach_handler)
            let _ = Sonar0.distanceChange.addHandler(distanceChange_handler)
            
            let _ = xAxis.attach.addHandler(attach_handler2)
            let _ = xAxis.voltageRatioChange.addHandler(xfunc_handler)
            
            let _ = yAxis.attach.addHandler(attach_handler2)
            let _ = yAxis.voltageRatioChange.addHandler(yfunc_handler)
            
            let _ = click.attach.addHandler(attach_handler2)
            let _ = click.stateChange.addHandler(state_change)
            
            let _ = leftside.attach.addHandler(attach_handler)
            let _ = rightside.attach.addHandler(attach_handler)
            
            //opens all
            try leftside.open()
            try rightside.open()
            try xAxis.open()
            try yAxis.open()
            try click.open()
            try Sonar0.open()
            
        } catch let err as PhidgetError {
            print ("Phidget Error " + err.description)
        } catch {
            //catch other errors here
        }
    }


}

