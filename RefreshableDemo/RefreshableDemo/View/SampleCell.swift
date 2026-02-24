//
//  SampleCell.swift
//  Refreshable
//
//  Created by Hoangtaiki on 7/20/18.
//  Copyright © 2018 Hoangtaiki. All rights reserved.
//

import UIKit

class SampleCell: UITableViewCell {
    static let reuseIdentifier = "SampleCell"

    static func nib() -> UINib {
        UINib(nibName: reuseIdentifier, bundle: nil)
    }

    var isSeparationLineHidden: Bool = false {
        didSet {
            separationLine.isHidden = isSeparationLineHidden
        }
    }

    @IBOutlet weak var indexNumberLabel: UILabel!
    @IBOutlet weak var separationLine: UIView!
    @IBOutlet weak var secondTitleViewTrailingAnchor: NSLayoutConstraint!
    @IBOutlet weak var thirdTitleViewTrailingAnchor: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        secondTitleViewTrailingAnchor.constant = CGFloat(Int.random(in: 0..<100)) + 40
        thirdTitleViewTrailingAnchor.constant = CGFloat(Int.random(in: 0..<100)) + 40
    }
}
