import UIKit
import CoreGraphics

class ViewController: UIViewController {
    @IBOutlet var totCountLabel: UILabel!
    @IBOutlet var totCountStepper: UIStepper!
    @IBOutlet var totImage: UIImageView!
    @IBOutlet var startStopButton: UIButton!
    @IBOutlet var timerFace: UILabel!

    var totalNumberOfTots = 5
    var timer: Timer?
    var targetDate: Date?
    var degrees = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTotLabel()
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
            cancelLocalNotifications()
            totImage.transform = .identity
            degrees = 0.0
            startStopButton.setTitle("Start Timer", for: .normal)
            timerFace.isHidden = true
            totCountStepper.isHidden = false
            totCountLabel.isHidden = false
            return
        }
        
        let dateComponents = DateComponents(second: timeForNumberOfTots(totalNumberOfTots))
        let calendar = Calendar.current
        targetDate = calendar.date(byAdding: dateComponents, to: Date())
        
        scheduleLocalNotification(targetDate: targetDate!)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.refreshTotAndTimer), userInfo: nil, repeats: true)
        startStopButton.setTitle("Stop Timer", for: .normal)
        timerFace.isHidden = false
        totCountStepper.isHidden = true
        totCountLabel.isHidden = true
        refreshTotAndTimer()
    }
    
    @objc func refreshTotAndTimer() {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.minute, .second], from: Date(), to: targetDate!)
        
        guard targetDate!.timeIntervalSinceReferenceDate > NSDate().timeIntervalSinceReferenceDate else {
            startOrStopTimer()
            return
        }
        
        degrees += 20
        totImage.transform = .init(rotationAngle: CGFloat(degrees * .pi/180))
        
        let dateDiff = calendar.date(from: dateComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "mm:ss"
        let formattedTime = dateFormatter.string(from: dateDiff)
        timerFace.text = formattedTime
    }
    
    func timeForNumberOfTots(_ numberOfTots:Int) -> Int {
        if (numberOfTots > 0 && numberOfTots <= 20) {
            return 22 * 60
        } else if (numberOfTots <= 30) {
            return 24 * 60
        } else {
            return 26 * 60
        }
    }
    
    func scheduleLocalNotification(targetDate: Date) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = targetDate
        localNotification.alertTitle = "Tater Tot Timer"
        localNotification.alertBody = "Your tots are done!"
        
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    
    func cancelLocalNotifications() {
        UIApplication.shared.cancelAllLocalNotifications()
    }
}

