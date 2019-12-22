//
//  TripCell.swift
//  Walkabout
//
//  Created by Nabil Haffar on 10/23/19.
//  Copyright © 2019 Nabil Haffar. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TripCell: UITableViewCell {
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
