//
//  ILPageControllerStyler.swift
//  ILPageController
//
//  Created by TS.MAC on 4/18/18.
//  Copyright © 2018 eul. All rights reserved.
//

import UIKit

protocol ILPageControllerStylerPt {

    var selectedDotColor     :UIColor { get }
    var dotsColor            :UIColor { get }
    var pageControllY        :CGFloat { get }
    var pageControllTrailing :CGFloat { get }
    var maxVisibleDots       :Int     { get }
}

struct ILPageControllerStyler :ILPageControllerStylerPt {

    var selectedDotColor: UIColor {

        return .black
    }

    var dotsColor: UIColor {

        return .white
    }

    var pageControllY: CGFloat {

        return 44.0;
    }

    var pageControllTrailing: CGFloat {

        return 44.0;
    }

    var maxVisibleDots: Int {

        return 5
    }
}

