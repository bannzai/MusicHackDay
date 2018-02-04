//
//  SearchTableViewCell.swift
//  MusicHackDayApp
//
//  Created by Yudai.Hirose on 2018/02/04.
//  Copyright © 2018年 廣瀬雄大. All rights reserved.
//

import UIKit
import Nuke

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var soundNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        iconImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
