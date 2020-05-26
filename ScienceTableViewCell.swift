//
//  ScienceTableViewCell.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 5/6/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//

import UIKit

protocol ScienceTableViewCellDelegate {
    func buttonTapped(cell: ScienceTableViewCell)
}

class ScienceTableViewCell: UITableViewCell {

    var delegate: ScienceTableViewCellDelegate?
    @IBOutlet weak var scienceThumbnail: UIImageView!
    @IBOutlet weak var scienceTitle: UILabel!
    @IBOutlet weak var scienceTime: UILabel!
    @IBOutlet weak var scienceSection: UILabel!
    @IBOutlet weak var scienceBookmark: UIButton!
    @IBAction func setBookmark(_ sender: Any) {
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
