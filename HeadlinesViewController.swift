//
//  HeadlinesViewController.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 5/5/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Foundation
import Alamofire
import SwiftyJSON
import SwiftSpinner


class HeadlinesViewController: ButtonBarPagerTabStripViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var headlinesAutoSuggestTable: UITableView!
    var autoSuggestResults = [Any]()
    var jsonResults: Any?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.autoSuggestResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HeadlinesAutoSuggestTableViewCell", for: indexPath) as? HeadlinesAutoSuggestTableViewCell  else {
            fatalError("The dequeued cell is not an instance of HeadlinesAutoSuggestTableViewCell.")
        }
        let result = self.autoSuggestResults[indexPath.row]
        cell.clipsToBounds = true
        cell.headlineResult.text = JSON(result)["displayText"].stringValue
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
                DispatchQueue.main.async(execute: self.headlinesAutoSuggestTable.reloadData)
            }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        loadHeadlines()
        super.viewDidLoad()
        setUpNavBar()
        buttonBarView.backgroundColor = UIColor.white
        headlinesAutoSuggestTable.delegate = self
        headlinesAutoSuggestTable.dataSource = self
        headlinesAutoSuggestTable.isHidden = true
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
////        loadHeadlines()
////        super.viewDidLoad()
//        setUpNavBar()
////        buttonBarView.backgroundColor = UIColor.white
//        headlinesAutoSuggestTable.delegate = self
//        headlinesAutoSuggestTable.dataSource = self
//        headlinesAutoSuggestTable.isHidden = false
//    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WorldTable")
        let child_2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BusinessTable")
        let child_3 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PoliticsTable")
        let child_4 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SportTable")
        let child_5 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TechnologyTable")
        let child_6 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScienceTable")
        return [child_1, child_2, child_3, child_4, child_5, child_6]
    }
    
    func loadHeadlines() {
        self.settings.style.buttonBarItemBackgroundColor = UIColor.white
        // selected bar view is created programmatically so it's important to set up the following 2 properties properly
        self.settings.style.selectedBarBackgroundColor = UIColor.systemBlue
        self.settings.style.selectedBarHeight = 3
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor.gray
            newCell?.label.textColor = UIColor.systemBlue
        }
    }
    
    func setUpNavBar() {
        navigationItem.title = "Headlines"
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController!.navigationBar.isTranslucent = false
        navigationController!.navigationBar.backgroundColor = UIColor.clear
        navigationController!.navigationBar.sizeToFit()
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Enter keyword..."
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self
        definesPresentationContext = true
    }

    
    private func myPerformSegue(identifier: String) {
        performSegue(withIdentifier: identifier, sender: send)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResults" {
            let resultsView: ResultsView = segue.destination as! ResultsView
            resultsView.data = self.jsonResults as AnyObject
        }
    }
}

extension HeadlinesViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    print(searchBar.text!)
//    viewWillAppear(true)
    if !searchBar.text!.isEmpty {
        self.headlinesAutoSuggestTable.isHidden = false
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
        DispatchQueue.main.async(execute: self.headlinesAutoSuggestTable.reloadData)
    } else {
        self.headlinesAutoSuggestTable.isHidden = true
    }
  }
}
