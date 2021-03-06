//
//  UITapGestureRecognizerExtension.swift
//  Dexy
//
//  Created by Tudor Croitoru on 26/02/2021.
//

import UIKit



extension UITapGestureRecognizer {

    func didTapAttributedTextInLabel(textView: UITextView, inRange targetRange: NSRange) -> (Bool, CGRect?) {

        let layoutManager = textView.layoutManager
        let textContainer = textView.textContainer

        // Find the tapped character location and compare it to the specified range
        var locationOfTouchInTextView = self.location(in: textView)
        locationOfTouchInTextView.x -= textView.textContainerInset.left
        locationOfTouchInTextView.y -= textView.textContainerInset.top

        let characterIndex = layoutManager.characterIndex(for: locationOfTouchInTextView,
                                                          in: textContainer,
                                                          fractionOfDistanceBetweenInsertionPoints: nil)
        
        if textView.attributedText!.attribute(.attachment, at: characterIndex, effectiveRange: nil) != nil {
        
            let rect = layoutManager.boundingRect(forGlyphRange: NSRange(location: characterIndex, length: 1), in: textContainer)
            let result = NSLocationInRange(characterIndex, targetRange)
            
            if result {
                return (result, rect)
            }
            
        }
        
        return (false, nil)
    }

}

