//
//  HomeTableViewController.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 5/1/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import SwiftSpinner
import Kingfisher

class HomeTableViewController: UITableViewController, CLLocationManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
//        homeTable.delegate = self
//        homeTable.dataSource = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.news.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        guard let cell: HomeTableViewCell = self.homeTable.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as? HomeTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        let new = news[indexPath.row]
        cell.homeTitle.text = new.title
        let url = URL(string: new.image)
        cell.homeThumbnail.kf.setImage(with: url)
        cell.homeSection.text = new.section
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let newsDate = formatter.date(from: new.date)!
        let elapsedTime = currentDate.timeIntervalSince(newsDate)
        // convert from seconds to hours, rounding down to the nearest hour
        let hours = floor(elapsedTime / 60 / 60)
        let minutes = floor((elapsedTime - (hours * 60 * 60)) / 60)
        let seconds = floor((elapsedTime - (hours * 60 * 60)) / 60 / 60)
        if (hours != 0) {
            cell.homeTime.text = String(Int(hours))+"h ago"
        } else if (minutes != 0) {
            cell.homeTime.text = String(Int(minutes))+"m ago"
        } else {
            cell.homeTime.text = String(Int(seconds))+"s ago"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let new = news[indexPath.row]
        let params:Parameters = [
            "id": new.id
        ]
        SwiftSpinner.show("Loading Detailed Article..")
        Alamofire.request("http://127.0.0.1:9000/article", parameters: params).responseJSON {
            response in
            switch response.result {
            case .success: do {
                self.jsonDetails = JSON(response.value)
                print("success get details")
                self.myPerformSegue(identifier: "showDetails")
                SwiftSpinner.hide()
            }
            case .failure(let error):
                print(error)
            }
        }
    }

//    @IBOutlet weak var weatherCity: UILabel!
//    @IBOutlet weak var weatherState: UILabel!
//    @IBOutlet weak var weatherTemp: UILabel!
//    @IBOutlet weak var weatherSummary: UILabel!
//    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var homeTable: UITableView!
    
    let apiKey = "2784b3aa9d4e0e208de38def8eb5889e"
    var lat = 0.0
    var long = 0.0
    let locationManager = CLLocationManager()
    var newsStored: [String: Any] = [:]
    var details: AnyObject?
    var newsCount = 0
    var userDefault = UserDefaults.standard
    var jsonDetails: Any?
    var news = [News]()

   
//   override func viewDidLoad() {
//       super.viewDidLoad()
//
//       locationManager.requestWhenInUseAuthorization()
//
//       if (CLLocationManager.locationServicesEnabled()) {
//           locationManager.delegate = self
//           locationManager.desiredAccuracy = kCLLocationAccuracyBest
//           locationManager.startUpdatingLocation()
//           loadSampleNews()
//           homeTable.delegate = self
//           homeTable.dataSource = self
//       }
//   }

    private func loadSampleNews() {
        SwiftSpinner.show("Loading Home Page...")
        Alamofire.request("http://127.0.0.1:9000/guardianHome").responseJSON {
            response in
            SwiftSpinner.hide()
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)["response"]["results"].arrayValue
                for result in jsonResponse {
                    let newsTitle = result["webTitle"].stringValue
                    let newsThumbnail = result["fields"]["thumbnail"].stringValue
                    let newsSection = result["sectionName"].stringValue
                    let newsDate = result["webPublicationDate"].stringValue
                    let newsId = result["id"].stringValue
                    guard let new = News(title: newsTitle, image: newsThumbnail, section: newsSection, date: newsDate, id: newsId) else {
                        fatalError("Unable to instantiate meal1")
                    }
                    self.news += [new]
                }
                DispatchQueue.main.async(execute: self.homeTable.reloadData)
            }
        }
    }

    private func myPerformSegue(identifier: String) {
        performSegue(withIdentifier: identifier, sender: send)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let detailView: DetailView = segue.destination as! DetailView
            detailView.data = self.jsonDetails as AnyObject
        }
    }


//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
