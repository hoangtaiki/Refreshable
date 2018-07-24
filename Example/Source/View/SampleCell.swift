//
//  SampleCell.swift
//  iOS Example
//
//  Created by Hoangtaiki on 7/20/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import UIKit

class SampleCell: UITableViewCell {

    static let reuseIdentifier = "SampleCell"

    static func nib() -> UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    var isSeperationLineHidden: Bool = false {
        didSet {
            seperationLine.isHidden = isSeperationLineHidden
        }
    }

    @IBOutlet weak var seperationLine: UIView!
    @IBOutlet weak var secondTitleViewTrailingAnchor: NSLayoutConstraint!
    @IBOutlet weak var thirdTitleViewTrailingAnchor: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        secondTitleViewTrailingAnchor.constant = CGFloat(arc4random() % 100) + 40
        thirdTitleViewTrailingAnchor.constant = CGFloat(arc4random() % 100) + 40
    }

}
