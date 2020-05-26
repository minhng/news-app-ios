//
//  TrendingView.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 5/6/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Charts

class TrendingView: UIViewController, ChartViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var trendingVIew: LineChartView!
    @IBOutlet weak var trendingSearchTerm: UITextField!
    var chartValues: [ChartDataEntry] = []
    var keywordValues: String = "Coronavirus"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trendingSearchTerm.delegate = self
        loadTrending()
    }
    
    func loadTrending() {
        let params:Parameters = [
            "keyword": keywordValues
        ]
        Alamofire.request("https://minh-ios-backend-9.wl.r.appspot.com/googleTrends", parameters: params).responseJSON {
            response in
            if let responseStr = response.result.value {
                self.chartValues = []
                var i = 0
                let jsonResponse = JSON(responseStr)["default"]["timelineData"].arrayValue
                for result in jsonResponse {
                    let value = result["value"][0].doubleValue
                    let dataEntry = ChartDataEntry(x: Double(i), y: value)
                    self.chartValues.append(dataEntry)
                    i += 1
                }
                let set1 = LineChartDataSet(entries: self.chartValues, label: "Trending chart for \(self.keywordValues)")
                let data = LineChartData(dataSet: set1)
                self.trendingVIew.data = data

            }
        }

    }

    //MARK: delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.keywordValues = textField.text!
        loadTrending()
        return true
    }
}
