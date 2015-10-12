//
//  ViewController.swift
//  TaterTotTimer
//
//  Created by Aaron Douglas on 10/5/15.
//  Copyright © 2015 Automattic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var totalNumberOfTots = 0
    @IBOutlet var totCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTotLabel()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func updateTotLabel() {
        totCountLabel.text = "\(totalNumberOfTots)"
    }
    
    @IBAction func changeTotValue(sender: UIStepper) {
        totalNumberOfTots = Int(sender.value)
        updateTotLabel()
    }
    

}

