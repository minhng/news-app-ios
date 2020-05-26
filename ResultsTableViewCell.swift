//
//  ResultsTableViewCell.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 5/5/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//

import UIKit

protocol ResultsTableViewCellDelegate {
    func buttonTapped(cell: ResultsTableViewCell)
}

class ResultsTableViewCell: UITableViewCell {

    var delegate: ResultsTableViewCellDelegate?
    @IBOutlet weak var resultsThumbnail: UIImageView!
    @IBOutlet weak var resultsTitle: UILabel!
    @IBOutlet weak var resultsTime: UILabel!
    @IBOutlet weak var resultsSection: UILabel!
    @IBOutlet weak var resultsBookmark: UIButton!
    
    @IBAction func setBookmark(_ sender: UIButton) {
        self.delegate?.buttonTapped(cell: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
