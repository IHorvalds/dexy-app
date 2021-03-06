//
//  DefinitionTableViewCell.swift
//  Dexy
//
//  Created by Tudor Croitoru on 16/02/2021.
//

import UIKit

protocol DefinitionCellPopoverDelegate: AnyObject {
    func openPopover(sourceView: UIView, sourceRect: CGRect, footnote: String)
}

class DefinitionTableViewCell: UITableViewCell {

    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var addedByLabel: UILabel!
    @IBOutlet private weak var sourceLabel: UILabel!
    
    public var def: DefinitionLookup.Definition? {
        didSet {
            if let def = self.def {
                
                self.textView.attributedText = def.formattedDefinition
                
                let fieldAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10.0, weight: .regular),
                                 NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]
                
                let valueAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10.0, weight: .semibold),
                                 NSAttributedString.Key.foregroundColor: UIColor.label]
                
                // source
                let source = NSMutableAttributedString(string: "Sursa: ", attributes: fieldAttr)
                let sourceName = NSAttributedString(string: def.sourceName, attributes: valueAttr)
                source.append(sourceName)
                self.sourceLabel.attributedText = source
                
                // user
                let addedBy = NSMutableAttributedString(string: "Adăugată de ", attributes: fieldAttr)
                let userNick = NSAttributedString(string: def.userNick, attributes: valueAttr)
                addedBy.append(userNick)
                self.addedByLabel.attributedText = addedBy
            } else {
                self.textView.text = ""
                self.addedByLabel.text = ""
                self.sourceLabel.text = ""
            }
        }
    }
    
    private let tapGR = UITapGestureRecognizer()
    
    weak var delegate: DefinitionCellPopoverDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        tapGR.addTarget(self, action: #selector(openPopover(_:)))
        self.textView.addGestureRecognizer(tapGR)
    }
    
    @objc fileprivate func openPopover(_ sender: UITapGestureRecognizer) {
        
        guard let def = def,
              let footnotes = def.footnotes else { return }
        
        for range in footnotes.keys {
            let (didTap, rect) = tapGR.didTapAttributedTextInLabel(textView: textView, inRange: range)
            if didTap, let footnote = footnotes[range] {
                delegate?.openPopover(sourceView: self.textView, sourceRect: rect!, footnote: footnote)
            }
        }
    }
}
