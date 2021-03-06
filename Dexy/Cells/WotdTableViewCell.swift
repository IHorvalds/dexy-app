//
//  WotdTableViewCell.swift
//  Dexy
//
//  Created by Tudor Croitoru on 11/02/2021.
//

import UIKit
import Kingfisher

@IBDesignable
class WotdTableViewCell: UITableViewCell {

    @IBOutlet private weak var wotdImage: UIImageView!
    @IBOutlet private weak var copyrightLabel: UILabel!
    @IBOutlet private weak var defTextView: UITextView!
    @IBOutlet private weak var userLabel: UILabel!
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var reasonTextView: UITextView!
    
    public var wotd: WordOfTheDay? {
        didSet {
            if let wotd = wotd {
                // image
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
                
                // copyright label
                let fieldAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10.0, weight: .regular),
                                 NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]
                
                let valueAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10.0, weight: .semibold),
                                  NSAttributedString.Key.foregroundColor: UIColor.label]
                
                let copyright = NSMutableAttributedString(string: "© imagine: ", attributes: fieldAttr)
                let authorName = NSAttributedString(string: wotd.imageAuthor, attributes: valueAttr)
                copyright.append(authorName)
                self.copyrightLabel.attributedText = copyright
                
                // definition
                self.defTextView.attributedText = wotd.formattedDefinition
                
                // source
                let source = NSMutableAttributedString(string: "Sursa: ", attributes: fieldAttr)
                let sourceName = NSAttributedString(string: wotd.sourceName, attributes: valueAttr)
                source.append(sourceName)
                self.sourceLabel.attributedText = source
                
                // user
                let addedBy = NSMutableAttributedString(string: "Adăugată de ", attributes: fieldAttr)
                let userNick = NSAttributedString(string: wotd.userNick, attributes: valueAttr)
                addedBy.append(userNick)
                self.userLabel.attributedText = addedBy
                
                // reason
                self.reasonTextView.attributedText = wotd.formattedReason
            } else {
                self.wotdImage.image = UIImage(systemName: "xmark.circle")
                self.copyrightLabel.text = ""
                self.defTextView.text = ""
                self.reasonTextView.text = ""
                self.sourceLabel.text = ""
                self.userLabel.text = ""
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.wotdImage.layer.cornerRadius = 5.0
        self.wotdImage.layer.cornerCurve = .continuous
    }
}
