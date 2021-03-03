//
//  StringExtension.swift
//  Dexy
//
//  Created by Tudor Croitoru on 10/02/2021.
//

import Foundation
import UIKit

extension String {
    
    
    private static func _cleanupTags(openingTag: String, closingTag: String? = nil, toCleanup: NSMutableAttributedString) {
        let oT = openingTag.replacingOccurrences(of: "\\", with: "")
        toCleanup.mutableString.replaceOccurrences(of: oT,
                                                   with: "",
                                                   options: .caseInsensitive,
                                                   range: NSMakeRange(0, toCleanup.mutableString.length))
        if let closingTag = closingTag {
            let ct = closingTag.replacingOccurrences(of: "\\", with: "")
            toCleanup.mutableString.replaceOccurrences(of: ct,
                                                       with: "",
                                                       options: .caseInsensitive,
                                                       range: NSMakeRange(0, toCleanup.mutableString.length))
        }
    }
    
    /// #Bracketed formatted string
    /// - Parameters:
    ///   - tag: meaningful objects exist inside pairs of 'tag's
    ///   - traitsToAdd: traits are stackable and must therefore be treated independently such that they don't
    ///   lose information should the attributed string contain multiple styles.
    ///   - toFormat: NSMutableAttributedString to format
    private static func _bracketedFormat (openingTag: String, closingTag: String? = nil, traitsToAdd: UIFontDescriptor.SymbolicTraits, toFormat: NSMutableAttributedString) {
        
        let searchRange = NSMakeRange(0, toFormat.length)
        
        let regexStr = "(?<!\\\\)" + openingTag + "(.*?)(?<!\\\\)" + (closingTag ?? openingTag)
        let regex = try! NSRegularExpression(pattern: regexStr)

        
        let matches = regex.matches(in: toFormat.string,
                      range: searchRange)
        
        matches.forEach { (match) in
            if match.range.length > 1 {
              
                let matchRange = match.range
                
                toFormat.enumerateAttributes(in: matchRange, options: .longestEffectiveRangeNotRequired) { (attr, range, stop) in
                    if let font = attr[.font] as? UIFont {

                        var fdTraits = font.fontDescriptor.symbolicTraits
                        fdTraits.insert(traitsToAdd)

                        let newFont = UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(fdTraits)!, size: 0)
                        toFormat.addAttribute(.font, value: newFont, range: range)
                    }
                    
                }
            }
        }
        
        
    }
    
    
    /// #Bracketed formatted string
    /// - Parameters:
    ///   - tag: meaningful objects exist inside pairs of 'tag's
    ///   - attributesToAdd: attributes added must not be stackable. Eg. colors, size.
    /// They must also not interact with fonts. Eg. symbolic traits, fonts, ... Use _bracketedFormat (tag: traitsToAdd: toFormat:) instead
    ///   - toFormat: NSMutableAttributedString to format
    private static func _bracketedFormat (openingTag: String, closingTag: String? = nil, attributesToAdd: [NSAttributedString.Key:Any], toFormat: NSMutableAttributedString) {
        
        let searchRange = NSMakeRange(0, toFormat.length)
        
        let regexStr = "(?<!\\\\)" + openingTag + "(.*?)(?<!\\\\)" + (closingTag ?? openingTag)
        let regex = try! NSRegularExpression(pattern: regexStr)

        
        let matches = regex.matches(in: toFormat.string,
                      range: searchRange)
        
        matches.forEach { (match) in
            if match.range.length > 1 {
              
                let matchRange = match.range
                
                toFormat.addAttributes(attributesToAdd, range: matchRange)
            }
        }
    }
    
    ///#Footnote Processor
    private static func _footnotes(toFormat: NSMutableAttributedString) -> [String] {
        var notes = [String]()
        
        let searchRange = NSMakeRange(0, toFormat.length)
        
        let regexStr = #"(?<!\\\\)\{\{(.*?)(?<!\\\\)\}\}"#
        let regex = try! NSRegularExpression(pattern: regexStr)

        
        let matches = regex.matches(in: toFormat.string,
                                    range: searchRange)
        
        matches.reversed().forEach { (match) in
            if match.range.length > 1 {
              
                let matchRange = match.range
                let attachment = NSTextAttachment(image: UIImage(systemName: "info.circle")!.withTintColor(.systemBlue))
                
                let imageString = NSMutableAttributedString(string: " ")
                imageString.append(NSAttributedString(attachment: attachment))
                
                
                let range = Range(matchRange, in: toFormat.string)!
                let footnote = NSMutableString(string: String(toFormat.string[range]))
                footnote.replaceOccurrences(of: #"\/(\d+)"#,
                                            with: "",
                                            options: .regularExpression,
                                            range: NSRange(location: 0, length: footnote.length))
                
                notes.append(String(footnote))

                toFormat.replaceCharacters(in: matchRange,
                                           with: imageString)
            }
        }
        
        notes.reverse()
        return notes
    }
    
    private static func _collectFootnotes(toFormat: NSMutableAttributedString, notes: [String]) -> [NSRange:String] {
        var foundFootnotes = [NSRange:String]()
        var index = 0
        
        toFormat.enumerateAttribute(.attachment, in: NSMakeRange(0, toFormat.length),
                                    options: .longestEffectiveRangeNotRequired) { value, range, _ in
            if value != nil {
                let newRange = NSRange(location: range.location-1, length: 3)
                foundFootnotes[newRange] = notes[index]
                index += 1
            }
        }
    
        return foundFootnotes
    }
    
    
    private static func _unaryFormat (tag: String, attributesToAdd: [NSAttributedString.Key: Any], toFormat: NSMutableAttributedString) {
        
        let searchRange = NSMakeRange(0, toFormat.length)
        
        let regexStr = "(?<!\\\\)" + tag
        let regex = try! NSRegularExpression(pattern: regexStr)
        
        
        let matches = regex.matches(in: toFormat.string,
                      range: searchRange)
        
        if attributesToAdd.keys.contains(.baselineOffset) {
            matches.forEach { (match) in
                
                let matchRange = match.range
                toFormat.enumerateAttribute(.font, in: matchRange, options: .longestEffectiveRangeNotRequired) { font, range, stop in
                    if let font = font as? UIFont {
                        
                        let newFont = font.withSize(font.pointSize * 2/3)
                        toFormat.setAttributes([NSAttributedString.Key.font: newFont], range: range)
                    }
                }
                
            }
        }
        
        matches.forEach { (match) in
            if match.range.length > 1 {
              
                let matchRange = match.range
                toFormat.addAttributes(attributesToAdd, range: matchRange)
            }
        }
        
    }
    
    public func formatString(baseFont: UIFont, footnotes: inout [NSRange:String]?) -> NSAttributedString {
        
        let baseFontAttribute = [NSAttributedString.Key.font: baseFont,
                                 .foregroundColor: UIColor.label]
        
        
        let str = self.replacingOccurrences(of: "\\n", with: "<br>", options: .regularExpression, range: Range<Index>(uncheckedBounds: (lower: self.startIndex, upper: self.endIndex)))
        let stringData = str.data(using: .utf16)!
        var nsMAS = NSMutableAttributedString()
        
        do
        {
            nsMAS = try NSMutableAttributedString(data: stringData,
                                                  options: [.documentType: NSAttributedString.DocumentType.html,
                                                           .characterEncoding: String.Encoding.utf16.rawValue],
                                                  documentAttributes: nil)
            nsMAS.addAttributes(baseFontAttribute, range: NSRange(location: 0, length: nsMAS.length))
        } catch {
            nsMAS = NSMutableAttributedString(string: self, attributes: baseFontAttribute)
        }
        
        
        let searchRange = NSMakeRange(0, nsMAS.length)
        
        let regexStr = #"▶(.*?)◀"#
        
        nsMAS.mutableString.replaceOccurrences(of: regexStr, with: "", options: .regularExpression, range: searchRange)
        
        var notes = [String]()
        if footnotes != nil {
            notes = String._footnotes(toFormat: nsMAS)
        }
        
        String._bracketedFormat(openingTag: "@", traitsToAdd: .traitBold,  toFormat: nsMAS)
        String._bracketedFormat(openingTag: #"\$"#, traitsToAdd: .traitItalic, toFormat: nsMAS)
        String._bracketedFormat(openingTag: "##", attributesToAdd: [.foregroundColor : UIColor.secondaryLabel], toFormat: nsMAS)
        String._bracketedFormat(openingTag: "#", attributesToAdd: [.foregroundColor : UIColor.secondaryLabel], toFormat: nsMAS)
        String._bracketedFormat(openingTag: "%", traitsToAdd: .traitExpanded, toFormat: nsMAS)
        String._bracketedFormat(openingTag: #"\{-"#, closingTag: #"-\}"#, attributesToAdd: [.strikethroughStyle: NSUnderlineStyle.single.rawValue], toFormat: nsMAS)
        String._bracketedFormat(openingTag: #"\{\+"#, closingTag: #"\+\}"#, attributesToAdd: [.underlineStyle: NSUnderlineStyle.single.rawValue], toFormat: nsMAS)
        String._unaryFormat(tag: #"\^\{([^}]*)\}"#, attributesToAdd: [.baselineOffset: baseFont.capHeight / 2], toFormat: nsMAS)
        String._unaryFormat(tag: #"_\{([^}]*)\}"#, attributesToAdd: [.baselineOffset: -5.0], toFormat: nsMAS)
        String._unaryFormat(tag: #"\^(\d+)"#, attributesToAdd: [.baselineOffset: baseFont.capHeight / 2], toFormat: nsMAS)
        String._unaryFormat(tag: #"_(\d+)"#, attributesToAdd: [.baselineOffset: -5.0], toFormat: nsMAS)
        
        let toReplace = [
            " - "  : " – ",  /* U+2013 */
            " ** " : " ♦ ",  /* U+2666 */
            " * "  : " ◊ ",  /* U+25CA */
            "\\'"  : "’",
            #"\{-"#: "",
            #"-\}"#: "",
            #"\{+"#: "",
            #"+\}"#: "",
            "^"    : "",
            "_"    : "",
            "@"    : "",
            "$"    : "",
            "#"    : "",
            "%"    : "",
            "{"   : "",
            "}"   : ""
        ]
        
        for (key, val) in toReplace {
            nsMAS.mutableString.replaceOccurrences(of: key,
                                                       with: val,
                                                       options: .caseInsensitive,
                                                       range: NSMakeRange(0, nsMAS.mutableString.length))
        }
        
        if footnotes != nil {
            footnotes = String._collectFootnotes(toFormat: nsMAS, notes: notes)
        }
        return nsMAS
    }
    
    
    
    func html2AttributedString(font: UIFont?) ->  NSAttributedString? {
        guard
            let data = data(using: .utf16)
            else { return nil }
        do {

            let string = try NSAttributedString(data: data, options: [.documentType : NSAttributedString.DocumentType.html],
                                                documentAttributes: nil)

            let newString = NSMutableAttributedString(attributedString: string)
            newString.enumerateAttributes(in: NSRange(location: 0, length: string.length), options: .longestEffectiveRangeNotRequired, using: { attributes, range, _ in
                if let font = font {
                    newString.removeAttribute(.font, range: range)
                    newString.addAttribute(.font, value: font, range: range)
                }
            })
            newString.addAttribute(.foregroundColor,value: UIColor.label, range: NSRange(location: 0, length: newString.length))
            return newString

        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
}
