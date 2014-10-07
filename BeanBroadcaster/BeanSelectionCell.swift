//
//  BeanSelectionCell.swift
//  BeanBroadcaster
//
//  Created by Evan Mckee on 10/4/14.
//  Copyright (c) 2014 Evan Mckee. All rights reserved.
//
//  Home page's table view cell showing beans selected/deselected for broadcast



import UIKit

class BeanSelectionCell: UITableViewCell {

    
    @IBOutlet weak var beanNameLabel: UILabel!

    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var configButton: UIButton!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    

    

}
