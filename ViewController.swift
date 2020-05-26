//
//  ViewController.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 4/16/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//
import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import SwiftSpinner
import Kingfisher
import Toast_Swift

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, HomeTableViewCellDelegate {
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadRefreshedData), for: .valueChanged)
        return refreshControl
    }()
    
    @objc
    func loadRefreshedData() {
        loadSampleNews()
        refresher.endRefreshing()
    }
    
    let cellSpacingHeight: CGFloat = 5
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int?
        if tableView == self.homeTable {
            count = 1
        }
        if tableView == self.homeAutoSuggestTable {
            count =  self.autoSuggestResults.count
        }
        return count!
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var count:Int?
        if tableView == self.homeTable {
            count = self.news.count
        }
        if tableView == self.homeAutoSuggestTable {
            count = 1
        }
        return count!
    }
    
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === self.homeTable {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as? HomeTableViewCell  else {
                fatalError("The dequeued cell is not an instance of HomeTableViewCell.")
            }
            let new = news[indexPath.section]
            cell.backgroundColor = UIColor.systemGray5
            cell.layer.borderColor = UIColor.systemGray5.cgColor
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
            cell.delegate = self
            
            cell.homeTitle.text = new.title
            if new.image.isEmpty {
                cell.homeThumbnail.image = UIImage(named: "default-guardian")
            } else {
                let url = URL(string: new.image)
                cell.homeThumbnail.kf.setImage(with: url)
            }
//            let url = URL(string: new.image)
//            cell.homeThumbnail.kf.setImage(with: url)
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
            if isBookmarked[indexPath.section]{
                cell.homeBookmark.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            } else {
                cell.homeBookmark.setImage(UIImage(systemName: "bookmark"), for: .normal)
            }
            return cell
        }
        if tableView === self.homeAutoSuggestTable {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeAutoSuggestTableViewCell", for: indexPath) as? HomeAutoSuggestTableViewCell  else {
                fatalError("The dequeued cell is not an instance of HomeAutoSuggestTableViewCell.")
            }
            let result = self.autoSuggestResults[indexPath.row]
            cell.clipsToBounds = true
            cell.result.text = JSON(result)["displayText"].stringValue
            return cell
        }
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === self.homeTable {
            let new = news[indexPath.section]
            let params:Parameters = [
                "id": new.id
            ]
            SwiftSpinner.show("Loading Detailed Article..")
            Alamofire.request("https://minh-ios-backend-9.wl.r.appspot.com/article", parameters: params).responseJSON {
                response in
                switch response.result {
                case .success: do {
                    self.jsonDetails = JSON(response.value!)
                    print("success get details")
                    self.myPerformSegue(identifier: "showDetails")
                    SwiftSpinner.hide()
                    DispatchQueue.main.async(execute: self.homeTable.reloadData)
                }
                case .failure(let error):
                    print(error)
                }
            }
        }
        if tableView === self.homeAutoSuggestTable {
            let result = self.autoSuggestResults[indexPath.row]
            let params:Parameters = [
                "q": JSON(result)["displayText"].stringValue
            ]
            SwiftSpinner.show("Loading Search Results..")
            Alamofire.request("https://minh-ios-backend-9.wl.r.appspot.com/search", parameters: params).responseJSON {
                response in
                switch response.result {
                case .success: do {
                    self.jsonResults = JSON(response.value!)
                    print("success search results")
                    self.myPerformSegue(identifier: "showResults")
                    SwiftSpinner.hide()
                    DispatchQueue.main.async(execute: self.homeAutoSuggestTable.reloadData)
                }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = news[indexPath.section]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            // Create an action for sharing
            let share = UIAction(title: "Share with Twitter", image: UIImage(named: "twitter")) { action in
                print("Sharing \(item)")
                let csci = "CSCI_571_NewsApp"
                let twitString = "https://theguardian.com/"+item.id
                let twitURL = "https://twitter.com/intent/tweet?text=\(twitString)&hashtags=\(csci)"
                UIApplication.shared.open(NSURL(string: twitURL)! as URL)
            }
            let bookmark = UIAction(title: "Bookmark", image: UIImage(systemName: "bookmark")) { action in
                self.contextTapped(index: indexPath.section)
                print("Bookmarking \(item)")
            }
            return UIMenu(title: "Menu", children: [share, bookmark])
        }
    }
    
    @IBOutlet weak var homeTable: UITableView!
    @IBOutlet weak var homeAutoSuggestTable: UITableView!
    @IBOutlet weak var weatherCity: UILabel!
    @IBOutlet weak var weatherState: UILabel!
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var weatherSummary: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    
    let apiKey = "2784b3aa9d4e0e208de38def8eb5889e"
    var lat = 0.0
    var long = 0.0
    let locationManager = CLLocationManager()
    var details: AnyObject?
    var newsCount = 0
    var userDefault = UserDefaults.standard
    var jsonDetails: Any?
    var jsonResults: Any?
    var news = [News]()
    var autoSuggestResults = [Any]()
    var isBookmarked = [Bool](repeating: false, count: 50)
    var result: NSArray?
    var bookmarkStored: [String: Any]?
    var twitString: String?


    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (CLLocationManager.locationServicesEnabled()) {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            loadSampleNews()
            homeTable.delegate = self
            homeTable.dataSource = self
            homeAutoSuggestTable.delegate = self
            homeAutoSuggestTable.dataSource = self
            homeTable.isHidden = false
            homeAutoSuggestTable.isHidden = true
            setUpNavBar()
            homeTable.refreshControl = refresher

        }
    }
    
    
    func setUpNavBar() {
        navigationItem.title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationController!.navigationBar.sizeToFit()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Enter keyword..."
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self
        definesPresentationContext = true
    }
    
    func setFavorite(cellResult: News) {
        let title = cellResult.title
        let news_id = cellResult.id
        let image = cellResult.image
        let section = cellResult.section
        let date = cellResult.date
        self.view.makeToast("Article bookmarked. Check out the Bookmarks tab to view", duration: 3.0, position: .bottom)
        let bookData = ["title": title, "image": image, "section": section, "date": date]
        self.bookmarkStored![news_id] = bookData
        self.userDefault.set(self.bookmarkStored, forKey: "bookmark")
    }

    func removeFavorite(cellResult: News) {
        let news_id = cellResult.id
        self.view.makeToast("Article removed from Bookmarks", duration: 3.0, position: .bottom)
        self.bookmarkStored?.removeValue(forKey: news_id)
        self.userDefault.set(self.bookmarkStored, forKey: "bookmark")
    }
    
    func buttonTapped(cell: HomeTableViewCell) {
        let index = self.homeTable.indexPath(for: cell)!.section
        if self.isBookmarked[index] {
            removeFavorite(cellResult: self.news[index])
        } else {
            setFavorite(cellResult: self.news[index])
        }
        self.isBookmarked[index] = !self.isBookmarked[index]
        DispatchQueue.main.async(execute: self.homeTable.reloadData)
    }
    
    func contextTapped(index: Int) {
        if self.isBookmarked[index] {
            removeFavorite(cellResult: self.news[index])
        } else {
            setFavorite(cellResult: self.news[index])
        }
        self.isBookmarked[index] = !self.isBookmarked[index]
        DispatchQueue.main.async(execute: self.homeTable.reloadData)
    }
    
    func checkBookmark() {
        self.isBookmarked = [Bool](repeating: false, count: 50)
        if let savedKeys = self.bookmarkStored?.keys {
            for (index, data) in (self.news.enumerated()) {
                if savedKeys.contains(data.id) {
                    self.isBookmarked[index] = true
                }
            }
        }
    }
    
    private func loadSampleNews() {
        SwiftSpinner.show("Loading Home Page...")
        Alamofire.request("https://minh-ios-backend-9.wl.r.appspot.com/guardianHome").responseJSON {
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
                    var tempFlag = false
                    for i in self.news {
                        if i.id == newsId {
                            tempFlag = true
                        }
                    }
                    if !tempFlag {
                        self.news += [new]
                    }
                }
                self.bookmarkStored = self.userDefault.object(forKey: "bookmark") as? [String: Any]
                if self.bookmarkStored == nil {
                    self.bookmarkStored = [:]
                }
                self.checkBookmark()
                DispatchQueue.main.async(execute: self.homeTable.reloadData)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        lat = location.coordinate.latitude
        long = location.coordinate.longitude
        self.getPlace() { placemark in
            guard let placemark = placemark else { return }
            self.weatherCity.text = placemark.locality
            self.weatherState.text = placemark.administrativeArea
        }
        Alamofire.request("https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&units=metric&appid=\(apiKey)").responseJSON {
            response in
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                self.weatherSummary.text = jsonWeather["main"].stringValue
                let jsonTemp = jsonResponse["main"]
                self.weatherTemp.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                if self.weatherSummary.text == "Clouds" {
                    self.weatherImage.image = UIImage(named: "cloudy_weather")
                } else if self.weatherSummary.text == "Clear" {
                    self.weatherImage.image = UIImage(named: "clear_weather")
                } else if self.weatherSummary.text == "Snow" {
                    self.weatherImage.image = UIImage(named: "snowy_weather")
                } else if self.weatherSummary.text == "Rain" {
                    self.weatherImage.image = UIImage(named: "rainy_weather")
                } else if self.weatherSummary.text == "Thunderstorm" {
                    self.weatherImage.image = UIImage(named: "thunder_weather")
                } else {
                    self.weatherImage.image = UIImage(named: "sunny_weather")
                }
            }
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    func getPlace(completionHandler: @escaping (CLPlacemark?)
                    -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
                
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                }
                else {
                 // An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
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
        if segue.identifier == "showResults" {
            let resultsView: ResultsView = segue.destination as! ResultsView
            resultsView.data = self.jsonResults as AnyObject
        }
    }
}

extension ViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    if !searchBar.text!.isEmpty {
        self.homeAutoSuggestTable.isHidden = false
        let headers = [
            "Ocp-Apim-Subscription-Key": "413a61a329e243fc837653de3b99e151"
        ]
        if searchBar.text!.count > 1 {
            Alamofire.request("https://api.cognitive.microsoft.com/bing/v7.0/suggestions?q=\(searchBar.text!.lowercased())", headers: headers).responseJSON {
                        response in
                        if let responseStr = response.result.value {
                            let jsonResponse = JSON(responseStr)
                            self.autoSuggestResults = jsonResponse["suggestionGroups"][0]["searchSuggestions"].arrayValue
                        }
            }
        }
        DispatchQueue.main.async(execute: self.homeAutoSuggestTable.reloadData)
    } else {
        self.homeTable.isHidden = false
        self.homeAutoSuggestTable.isHidden = true
    }
  }
}
