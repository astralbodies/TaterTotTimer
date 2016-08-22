import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    @IBOutlet var totCountLabel: UILabel!
    @IBOutlet var totCountStepper: UIStepper!
    @IBOutlet var totImage: UIImageView!
    @IBOutlet var startStopButton: UIButton!
    @IBOutlet var timerFace: UILabel!

    let disposeBag = DisposeBag()
    
    var totalNumberOfTots = Variable(5)
    var timer: NSTimer?
    var targetDate: NSDate?
    var degrees = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalNumberOfTots
            .asObservable()
            .subscribeNext { tots in
                self.totCountLabel.text = "Number of Tots: \(tots)"
            }
            .addDisposableTo(disposeBag)
        
        totCountStepper
            .rx_value
            .subscribeNext { value in
                self.totalNumberOfTots.value = Int(value)
            }
            .addDisposableTo(disposeBag)
    }
    
    @IBAction func startOrStopTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
            targetDate = nil
            cancelLocalNotifications()
            totImage.transform = CGAffineTransformIdentity
            degrees = 0.0
            startStopButton.setTitle("Start Timer", forState: .Normal)
            timerFace.hidden = true
            totCountStepper.hidden = false
            totCountLabel.hidden = false
            return
        }
        
        let dateComponents = NSDateComponents.init()
        let calendar = NSCalendar.currentCalendar()
        dateComponents.second = timeForNumberOfTots(totalNumberOfTots.value)
        targetDate = calendar.dateByAddingComponents(dateComponents, toDate: NSDate.init(), options: [])
        
        scheduleLocalNotification(targetDate!)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.refreshTotAndTimer), userInfo: nil, repeats: true)
        startStopButton.setTitle("Stop Timer", forState: .Normal)
        timerFace.hidden = false
        totCountStepper.hidden = true
        totCountLabel.hidden = true
        refreshTotAndTimer()
    }
    
    func refreshTotAndTimer() {
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([.Minute, .Second], fromDate: NSDate(), toDate: targetDate!, options: [])
        
        guard targetDate!.timeIntervalSinceReferenceDate > NSDate().timeIntervalSinceReferenceDate else {
            startOrStopTimer()
            return
        }
        
        degrees += 20
        totImage.transform = CGAffineTransformMakeRotation(CGFloat(degrees * M_PI/180))
        
        let dateDiff = calendar.dateFromComponents(dateComponents)!
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateFormat = "mm:ss"
        let formattedTime = dateFormatter.stringFromDate(dateDiff)
        timerFace.text = formattedTime
    }
    
    func timeForNumberOfTots(numberOfTots:Int) -> Int {
        if (numberOfTots > 0 && numberOfTots <= 20) {
            return 22 * 60
        } else if (numberOfTots <= 30) {
            return 24 * 60
        } else {
            return 26 * 60
        }
    }
    
    func scheduleLocalNotification(targetDate: NSDate) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = targetDate
        localNotification.alertTitle = "Tater Tot Timer"
        localNotification.alertBody = "Your tots are done!"
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    func cancelLocalNotifications() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
}

