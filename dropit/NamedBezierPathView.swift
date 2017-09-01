//
//  NamedBezierPathView.swift
//  dropit
//
//  Created by Jin on 2/26/17.
//  Copyright © 2017 Jin. All rights reserved.
//

import UIKit

class NamedBezierPathView: UIView {
    
    var bezierPaths = [String:UIBezierPath](){didSet{setNeedsDisplay()}}

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        for (_, path) in bezierPaths{
            path.stroke()
        }
    }
}
