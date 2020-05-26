//
//  HomeViewController.swift
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

class HomeViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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

    @IBOutlet weak var weatherCity: UILabel!
    @IBOutlet weak var weatherState: UILabel!
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var weatherSummary: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()

        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            loadSampleNews()
            homeTable.delegate = self
            homeTable.dataSource = self
        }
    }

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
}
