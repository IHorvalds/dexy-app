//
//  SmallWotdTableViewCell.swift
//  Dexy
//
//  Created by Tudor Croitoru on 11/02/2021.
//

import UIKit

@IBDesignable
class SmallWotdTableViewCell: UITableViewCell {

    @IBOutlet private weak var wotdImage: UIImageView!
    @IBOutlet private weak var wordLabel: UILabel!
    @IBOutlet private weak var reasonTextView: UITextView!
    
    private static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }
    
    public var otherWotd: WordOfTheDay.SmallWordOfTheDay? {
        didSet {
            if let wotd = otherWotd {
                let url = URL(string: wotd.imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                
                self.wotdImage.kf.indicatorType = .activity
                self.wotdImage.kf.setImage(
                    with: url,
                    placeholder: UIImage(systemName: "rectangle.and.pencil.and.ellipsis"),
                    options: [
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                    ])
                
                let dateAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: .regular),
                                NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]
                
                let valueAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: .semibold),
                                 NSAttributedString.Key.foregroundColor: UIColor.label]
                
                let dateString = NSMutableAttributedString(string: SmallWotdTableViewCell.dateFormatter.string(from: wotd.date) + ": ", attributes: dateAttr)
                let wordString = NSAttributedString(string: wotd.word, attributes: valueAttr)
                dateString.append(wordString)
                self.wordLabel.attributedText = dateString
                
                // reason
                self.reasonTextView.attributedText = wotd.formattedReason
            } else {
                self.wotdImage.image = UIImage(systemName: "xmark.circle")
                self.reasonTextView.text = ""
                self.wordLabel.text = ""
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.wotdImage.layer.cornerRadius = 3.0
        self.wotdImage.layer.cornerCurve = .continuous
    }
    
}
