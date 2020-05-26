//
//  News.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 4/18/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//

import UIKit

class News {
    //MARK: Properties
    var title: String
    var image: String
    var section: String
    var date: String
    var id: String
    init?(title: String, image: String, section: String, date: String, id: String) {
        // Initialization should fail if there is no name or if the rating is negative.
//        if name.isEmpty || rating < 0  {
//            return nil
//        }
        self.title = title
        self.image = image
        self.section = section
        self.date = date
        self.id = id
    }
}
