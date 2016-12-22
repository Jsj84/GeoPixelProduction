//
//  ViewController.swift
//  Geo Pixel
//
//  Created by Jesse St. John on 12/7/16.
//  Copyright © 2016 Jesse St. John. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate, CLLocationManagerDelegate {
    
    // set the constants, varibles and outlets
    let now = Date()
    var player: AVAudioPlayer?
    
    // class constants and variables I'm using for
    let locationManager = CLLocationManager()
    var center = CLLocationCoordinate2D()
    let radius = 30 as CLLocationDistance
    var coordinates: [CLLocationCoordinate2D] = []
    let notification = UILocalNotification()
    
    @IBOutlet weak var tableView: UITableView!
    
    //  set the titles for the tableView
    let items = ["JFK International Airport", "Terminal 1", "Terminal 2", "Terminal 4", "Terminal 5", "Terminal 7", "Terminal 8"]
    
    // create an array of locations.
    let locationsArray = [
        CLLocation(latitude: 40.69633569999999, longitude: -73.99167620000003), // my house and test location
        CLLocation(latitude: 40.757365, longitude: -73.975393), // 437 Madison Avenue
        CLLocation(latitude: 40.6924582, longitude: -73.99121760000003), // Starbucks on Court St. and Jerolomon
        CLLocation(latitude: 40.6903611, longitude: -73.98617489999998), // Macy's on Fulton St.
        CLLocation(latitude: 40.748441, longitude: -73.985664),
        CLLocation(latitude: 40.756359, longitude: -73.988873),
        CLLocation(latitude: 40.756359, longitude: -73.988873)
        //        CLLocation(latitude: 40.643692	, longitude: -73.79008), // terminal one
        //        CLLocation(latitude: 40.642169, longitude: -73.788976), // terminal two
        //        CLLocation(latitude: 40.644535, longitude: -73.782626),  // terminal four
        //        CLLocation(latitude: 40.644831	, longitude: -73.777362), // terminal five
        //        CLLocation(latitude: 40.648505, longitude: -73.782516), // terminal seven
        //        CLLocation(latitude: 40.646471, longitude: -73.78886) // terminal eight

    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the location manager delegate to self, request autorization and set accuracy
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // set the table veiw delage, data source and style
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.isOpaque = true
        
    }
    // check the authorization atatus and proceed if it is set to always or display message if set to never
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isRangingAvailable() {
                locationManager.startUpdatingLocation()
                for index in 0..<self.locationsArray.count{
                    let lat = Double(self.locationsArray[index].coordinate.latitude)
                    let long = Double(self.locationsArray[index].coordinate.longitude)
                    let coordinatesToAppend = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    coordinates.append(coordinatesToAppend)
                    center = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let region = CLCircularRegion.init(center: center, radius: radius, identifier: "\(locationsArray[index].coordinate.latitude)")
                    locationManager.startMonitoring(for: region)
                }
            }
            else if status == .denied {
                let alert = UIAlertController(title: "Warning", message: "You've disabled location update which is required for this app to work. Go to your phone settings and change the permissions.", preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in }
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Region: \(region.identifier)" + " is being monitored")
        region.notifyOnEntry = true
        region.notifyOnEntry = true
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region?.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        notification.fireDate = NSDate(timeIntervalSinceNow: 1) as Date
        notification.alertBody = "You have just entered \(region.identifier)!"
        notification.alertAction = "Please open the app for terminal information"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["CustomField1": "w00t"]
        UIApplication.shared.scheduleLocalNotification(notification)
        guard UIApplication.shared.currentUserNotificationSettings != nil else { return }
        
        greetings()
        terminal1()
        
        NSLog("Did enter region")
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        notification.fireDate = NSDate(timeIntervalSinceNow: 1) as Date
        notification.alertBody = "You have just exited \(region.identifier)!"
        notification.alertAction = "Please open the app for terminal information"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["CustomField1": "w00t"]
        UIApplication.shared.scheduleLocalNotification(notification)
        guard UIApplication.shared.currentUserNotificationSettings != nil else { return }
        
        greetings()
        terminal4()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    func locationManager(_: CLLocationManager, didFinishDeferredUpdatesWithError: Error?){
        print("error")
    }
    func greetings() {
        let one_am = now.dateAt(hours: 1, minutes: 0)
        let twleve_pm = now.dateAt(hours: 12, minutes: 0)
        let fivePm_today = now.dateAt(hours: 17, minutes: 0)
        
        if now >= one_am && now <= twleve_pm
        {
            goodMorning()
        }
        else if now > twleve_pm && now < fivePm_today {
            goodAfternoon()
        }
        else if now >= fivePm_today && now < one_am {
            goodEvening()
        }
        
    }
    func terminal1() {
        guard let url = Bundle.main.url(forResource: "Terminal 1", withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        do {
            /// this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /// change fileTypeHint according to the type of your audio file (you can omit this)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            
            // no need for prepareToPlay because prepareToPlay is happen automatically when calling play()
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    func terminal2() {
        guard let url = Bundle.main.url(forResource: "Terminal 2", withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    func terminal4() {
        guard let url = Bundle.main.url(forResource: "Terminal 4", withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    func terminal5() {
        guard let url = Bundle.main.url(forResource: "Terminal 5", withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    func terminal7() {
        guard let url = Bundle.main.url(forResource: "Terminal 7", withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    func terminal8() {
        guard let url = Bundle.main.url(forResource: "Terminal 8", withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    func goodMorning() {
        guard let url = Bundle.main.url(forResource: "Good Morning", withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    func goodAfternoon() {
        guard let url = Bundle.main.url(forResource: "Good Afternoon", withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    func goodEvening() {
        guard let url = Bundle.main.url(forResource: "Good Evening", withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    func jfk() {
        guard let url = Bundle.main.url(forResource: "JFK - Where America Greets the World", withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.items.count
        }
        else {
            return 1
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.tableFooterView = UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }
        return 25
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = items[indexPath.row]
            cell.layer.cornerRadius = 15
            if indexPath.row == 0 {
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = UIColor.blue
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "STOP AUDIO"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor.red
            cell.backgroundColor = UIColor.lightText
            cell.layer.cornerRadius = 15
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            jfk()
        }
        if indexPath.section == 0 && indexPath.row == 1 {
            terminal1()
        }
        else if indexPath.section == 0 && indexPath.row == 2 {
            terminal2()
        }
        else if indexPath.section == 0 && indexPath.row == 3 {
            terminal4()
        }
        else if indexPath.section == 0 && indexPath.row == 4 {
            terminal5()
        }
        else if indexPath.section == 0 && indexPath.row == 5 {
            terminal7()
        }
        else if indexPath.section == 0 && indexPath.row == 6 {
            terminal8()
        }
        else if indexPath.section == 1 {
            player?.stop()
        }
        
    }
}
extension Date
{
    func dateAt(hours: Int, minutes: Int) -> Date
    {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        calendar.timeZone = NSTimeZone.system
        
        //get the month/day/year componentsfor today's date.
        var date_components = calendar.components(
            [NSCalendar.Unit.year,
             NSCalendar.Unit.month,
             NSCalendar.Unit.day],
            from: self)
        
        //Create an NSDate for the specified time today.
        date_components.hour = hours
        date_components.minute = minutes
        date_components.second = 0
        
        let newDate = calendar.date(from: date_components)!
        return newDate
    }
}
extension String {
    var coordinateValue: CLLocationDegrees {
        return (self as NSString).doubleValue
    }
}
