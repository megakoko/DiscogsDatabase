//
//  ArtistTableViewCell.swift
//  DiscogsDatabase
//
//  Created by Andy Chukavin on 27/11/2017.
//  Copyright © 2017 Andy Chukavin. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
