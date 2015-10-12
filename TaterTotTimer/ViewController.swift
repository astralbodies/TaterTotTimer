//
//  ViewController.swift
//  TaterTotTimer
//
//  Created by Aaron Douglas on 10/5/15.
//  Copyright © 2015 Automattic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var totCountLabel: UILabel!
    @IBOutlet var totImage: UIImageView!
    @IBOutlet var startStopButton: UIButton!
    @IBOutlet var timerFace: UILabel!

    var totalNumberOfTots = 5
    var timer: NSTimer?
    var targetDate: NSDate?
    var degrees = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTotLabel()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func updateTotLabel() {
        totCountLabel.text = "Number of Tots: \(totalNumberOfTots)"
    }
    
    @IBAction func changeTotValue(sender: UIStepper) {
        totalNumberOfTots = Int(sender.value)
        updateTotLabel()
    }
    
    @IBAction func startOrStopTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
            targetDate = nil
            totImage.transform = CGAffineTransformIdentity
            degrees = 0.0
            startStopButton.setTitle("Start Timer", forState: .Normal)
            timerFace.hidden = true
            return
        }
        
        let dateComponents = NSDateComponents.init()
        let calendar = NSCalendar.currentCalendar()
        dateComponents.second = timeForNumberOfTots(totalNumberOfTots)
        targetDate = calendar.dateByAddingComponents(dateComponents, toDate: NSDate.init(), options: [])
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTot", userInfo: nil, repeats: true)
        startStopButton.setTitle("Stop Timer", forState: .Normal)
        timerFace.hidden = false
        updateTot()
    }
    
    func updateTot() {
        degrees += 20
        totImage.transform = CGAffineTransformMakeRotation(CGFloat(degrees * M_PI/180));
        
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([.Minute, .Second], fromDate: NSDate.init(), toDate: targetDate!, options: [])
        timerFace.text = "\(dateComponents.minute):\(dateComponents.second)"
    }
    
    func timeForNumberOfTots(numberOfTots:Int) -> Int {
        if (numberOfTots > 0 && numberOfTots <= 20) {
            return 22 * 60;
        } else if (numberOfTots <= 30) {
            return 24 * 60;
        } else {
            return 26 * 60;
        }
    }
    
    func scheduleLocalNotification(targetDate: NSDate) {
        
    }

}

