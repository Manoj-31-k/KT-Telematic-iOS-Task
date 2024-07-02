//
//  DashboardMapCell.swift
//  IOS Developer Task
//
//  Created by Manoj on 29/06/24.
//

import UIKit

class DashboardMapCell: UITableViewCell {
    
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var latitudeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
