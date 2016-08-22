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
    var timerRunning = Variable(false)
    var targetDate: NSDate?
    var degrees = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timerIsRunning = timerRunning
            .asObservable()
            .map({timerRunning in timerRunning})
            .shareReplay(1)
        
        let timerIsNotRunning = timerRunning
            .asObservable()
            .map({timerRunning in !timerRunning})
            .shareReplay(1)
        
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
        
        startStopButton
            .rx_tap
            .subscribeNext {
                self.timerRunning.value = !self.timerRunning.value
            }
            .addDisposableTo(disposeBag)
        
        timerIsNotRunning
            .bindTo(timerFace.rx_hidden)
            .addDisposableTo(disposeBag)
        
        timerIsRunning
            .bindTo(totCountStepper.rx_hidden)
            .addDisposableTo(disposeBag)
        
        timerIsRunning
            .bindTo(totCountLabel.rx_hidden)
            .addDisposableTo(disposeBag)
        
        timerRunning
            .asObservable()
            .map { $0 ? "Stop Timer" : "Start Timer" }
            .bindTo(startStopButton.rx_title(.Normal))
            .addDisposableTo(disposeBag)

        timerIsNotRunning
            .subscribeNext { value in
                self.targetDate = nil
                self.cancelLocalNotifications()
                self.totImage.transform = CGAffineTransformIdentity
                self.degrees = 0.0
            }
            .addDisposableTo(disposeBag)
        
        Observable<Int>
            .timer(0.0, period: 0.1, scheduler: MainScheduler.instance)
            .pausable(timerRunning.asObservable())
            .subscribeNext({ seconds in
                self.refreshTotAndTimer()
            })
            .addDisposableTo(self.disposeBag)
        
        timerIsRunning
            .subscribeNext { value in
                let dateComponents = NSDateComponents.init()
                let calendar = NSCalendar.currentCalendar()
                dateComponents.second = self.timeForNumberOfTots(self.totalNumberOfTots.value)
                self.targetDate = calendar.dateByAddingComponents(dateComponents, toDate: NSDate.init(), options: [])
                
                self.scheduleLocalNotification(self.targetDate!)
            }
            .addDisposableTo(disposeBag)

    }
    
    func refreshTotAndTimer() {
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([.Minute, .Second], fromDate: NSDate(), toDate: targetDate!, options: [])
        
        guard targetDate!.timeIntervalSinceReferenceDate > NSDate().timeIntervalSinceReferenceDate else {
            self.timerRunning.value = false
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

