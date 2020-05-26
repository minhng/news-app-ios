//
//  TechnologyTableViewCell.swift
//  NewsApp
//
//  Created by Minh Nguyen  on 5/6/20.
//  Copyright © 2020 Minh Nguyen . All rights reserved.
//

import UIKit

protocol TechnologyTableViewCellDelegate {
    func buttonTapped(cell: TechnologyTableViewCell)
}

class TechnologyTableViewCell: UITableViewCell {

    var delegate: TechnologyTableViewCellDelegate?
    @IBOutlet weak var technologyThumbnail: UIImageView!
    @IBOutlet weak var technologyTitle: UILabel!
    @IBOutlet weak var technologyTime: UILabel!
    @IBOutlet weak var technologySection: UILabel!
    @IBOutlet weak var technologyBookmark: UIButton!
    
    
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

