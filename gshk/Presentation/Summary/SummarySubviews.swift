//
//  SummarySubviews.swift
//  gshk
//
//  Created by Benjamin on 25. 4. 24.
//

import UIKit

class SummaryCell: UITableViewCell {
    static let identifier = "SummaryCell"
    
    @IBOutlet weak var leftTitleLabel: UILabel!
    @IBOutlet weak var rightTitleLabel: UILabel!
    @IBOutlet weak var leftValueLabel: UILabel!
    @IBOutlet weak var rightValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        leftValueLabel.font = leftValueLabel.font.rounded
        rightValueLabel.font = rightValueLabel.font.rounded
    }
    
    func populate(leftTitle: String, leftValue: String, leftLower: [String], rightTitle: String, rightValue: String, rightLower: [String]) {
        leftTitleLabel.text = leftTitle
        rightTitleLabel.text = rightTitle
        leftValueLabel.attributedText = getValueAttributedText(leftValue, lower: leftLower, font: leftValueLabel.font)
        rightValueLabel.attributedText = getValueAttributedText(rightValue, lower: rightLower, font: rightValueLabel.font)
    }
    
    private func getValueAttributedText(_ text: String, lower: [String], font: UIFont) -> NSAttributedString {
        let text = NSMutableAttributedString(string: text)
        
        for low in lower {
            let range = text.mutableString.range(of: low)

            if range.location != NSNotFound {
                text.addAttribute(.font, value: font.withSize(14), range: range)
            }
        }
        
        return text
    }
}

class WorkoutCell: UITableViewCell {
    static let identifier = "WorkoutCell"
    
    @IBOutlet weak var roundedView: RoundedView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundedView.layer.shadowColor = UIColor.black.cgColor
        roundedView.layer.shadowOpacity = 0.08
        roundedView.layer.shadowOffset = .init(width: 0, height: 4)
        roundedView.layer.shadowRadius = 30
        contentView.clipsToBounds = false
        clipsToBounds = false
    }
    
    func populate(title: String, subtitle: String, image: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconImageView.image = UIImage(systemName: image)
    }
}

class RoundedView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        layer.cornerRadius = 26
    }
}

class SummarySectionHeaderView: UITableViewHeaderFooterView {
    static let identifier = "SummarySectionHeaderView"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        backgroundView = .init()
        backgroundView?.backgroundColor = .clear
    }
    
    func populate(title: String) {
        titleLabel.text = title
    }
}

public extension UIFont {
    var rounded: UIFont {
        guard let desc = self.fontDescriptor.withDesign(.rounded) else { return self }
        return UIFont(descriptor: desc, size: self.pointSize)
    }
}
