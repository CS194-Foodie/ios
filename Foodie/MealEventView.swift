//
//  MealEventView.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/28/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit

class MealEventView: UIView {

    @IBOutlet var contentView:UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    // Init views and yes/no buttons
    func initSubviews() {
        let nib = UINib(nibName: "MealEventView", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        contentView.frame = bounds
        
        addSubview(contentView)
    }

}
