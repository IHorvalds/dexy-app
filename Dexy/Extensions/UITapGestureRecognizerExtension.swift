//
//  UITapGestureRecognizerExtension.swift
//  Dexy
//
//  Created by Tudor Croitoru on 26/02/2021.
//

import UIKit



extension UITapGestureRecognizer {

    func didTapAttributedTextInLabel(textView: UITextView, inRange targetRange: NSRange) -> (Bool, CGRect?) {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: textView.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        let labelSize = textView.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: textView)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        let rect = layoutManager.boundingRect(forGlyphRange: NSRange(location: indexOfCharacter, length: 3), in: textContainer)
        print(textView.attributedText!.string[textView.attributedText!.string.index(textView.attributedText!.string.startIndex, offsetBy: 115)])
        let result = NSLocationInRange(indexOfCharacter, targetRange)
        
        if result {
            return (result, rect)
        }
        return (result, nil)
    }

}

