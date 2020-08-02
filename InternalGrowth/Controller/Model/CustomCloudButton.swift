//
//  CustomCloudButton.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 8/2/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import Foundation
import UIKit

class CustomCloudButton : UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = true
        layer.cornerRadius = self.frame.height/2
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
    }

}
