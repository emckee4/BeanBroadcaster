//
//  ManagementTableCellBasic.swift
//  BeanBroadcaster
//
//  Created by Evan Mckee on 10/6/14.
//  Copyright (c) 2014 Evan Mckee. All rights reserved.
//

import UIKit

class ManagementTableCellBasic: UITableViewCell {

    @IBOutlet weak var beanNameTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
