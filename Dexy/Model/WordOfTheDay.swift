//
//  WordOfTheDay.swift
//  Dexy
//
//  Created by Tudor Croitoru on 11/02/2021.
//

import SwiftyJSON
import UIKit

/// # WordOfTheDay
///
/// • The `definition` property is in internal representation of DexOnline. Use `.formatString(baseFont:)`
/// to create an NSAttributedString instace of the formatted string.
///
/// • The `reason` property can sometimes be an HTML string. Format accordingly.
///
class WordOfTheDay: Identifiable {
    
    static let calendar = Calendar(identifier: .gregorian)
    static let timeZone = TimeZone(abbreviation: "EET")
    
    struct SmallWordOfTheDay: Identifiable {
        let id: UUID
        let word: String
        let date: Date
        private let reason: String
        let formattedReason: NSAttributedString
        let imageUrl: String
        let imageAuthor: String
        
        init?(json: JSON, date: Date) {

            if let stringYear = json["year"].string,
               let jsonYear = Int(stringYear) {
                
                let dateComponents = DateComponents(calendar: WordOfTheDay.calendar, timeZone: WordOfTheDay.timeZone,
                                                    year: jsonYear,
                                                    month: WordOfTheDay.calendar.component(.month, from: date),
                                                    day: WordOfTheDay.calendar.component(.day, from: date))
                if dateComponents.isValidDate {
                    self.date = dateComponents.date!
                } else {
                    return nil
                }
            } else {
                return nil
            }
            
            if let jsonWord = json["word"].string {
                self.word = jsonWord
            } else {
                return nil
            }
            
            if let jsonReason = json["reason"].string {
                self.reason = jsonReason
                self.formattedReason = jsonReason.html2AttributedString(font: .systemFont(ofSize: 16.0)) ?? NSAttributedString(string: jsonReason, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0), .foregroundColor: UIColor.label])
            } else {
                return nil
            }
            
            if let jsonAuthor = json["imageAuthor"].string {
                self.imageAuthor = jsonAuthor
            } else {
                return nil
            }
            
            if let jsonImage = json["image"].string {
                self.imageUrl = jsonImage
            } else {
                return nil
            }
            
            self.id = UUID()
        }
    }
    
    let id: Int
    private let definition: String
    let formattedDefinition: NSAttributedString
    let date: Date
    let userNick: String
    let sourceName: String
    let imageAuthor: String
    let imageUrl: String
    private let reason: String
    let formattedReason: NSAttributedString
    let word: String
    var footnotes: [NSRange:String]? = [:]
    var others: [SmallWordOfTheDay] = []
    
    init?(data: Data) {
        let json = try? JSON(data: data)
        
        if let json = json {
            
            //id
            if let stringId = json["requested"]["record"]["definition"]["id"].string,
               let jsonId = Int(stringId) {
                self.id = jsonId
            } else {
                return nil
            }
            
            //definition
            if let jsonDef = json["requested"]["record"]["definition"]["internalRep"].string {
                self.definition = jsonDef
                self.formattedDefinition = self.definition.formatString(baseFont: .systemFont(ofSize: 16.0), footnotes: &footnotes)
            } else {
                return nil
            }
            
            //date
            if let stringDay = json["day"].string,
               let stringMonth = json["month"].string,
               let stringYear = json["requested"]["record"]["year"].string,
               let jsonDay = Int(stringDay),
               let jsonMonth = Int(stringMonth),
               let jsonYear = Int(stringYear) {
                
                let dateComponents = DateComponents(calendar: Self.calendar, timeZone: Self.timeZone,
                                                    year: jsonYear, month: jsonMonth, day: jsonDay)
                
                self.date = dateComponents.date ?? Date()
            } else {
                return nil
            }
            
            //user nick
            if let jsonUser = json["requested"]["record"]["definition"]["userNick"].string {
                self.userNick = jsonUser
            } else {
                return nil
            }
            
            //source name
            if let jsonSource = json["requested"]["record"]["definition"]["sourceName"].string {
                self.sourceName = jsonSource
            } else {
                return nil
            }
            
            //image author
            if let jsonAuthor = json["requested"]["record"]["imageAuthor"].string {
                self.imageAuthor = jsonAuthor
            } else {
                return nil
            }
            
            //image url
            if let jsonImage = json["requested"]["record"]["image"].string {
                self.imageUrl = jsonImage
            } else {
                return nil
            }
            
            //reason
            if let jsonReason = json["requested"]["record"]["reason"].string {
                self.reason = jsonReason
                self.formattedReason = jsonReason.html2AttributedString(font: .systemFont(ofSize: 16.0)) ?? NSAttributedString(string: jsonReason, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0), .foregroundColor: UIColor.label])
            } else {
                return nil
            }
            
            //word
            if let jsonWord = json["requested"]["record"]["word"].string {
                self.word = jsonWord
            } else {
                return nil
            }
            
            
            //others
            if let jsonOthers = json["others"]["record"].array {
                for other in jsonOthers {
                    
                    if let otherWotd = SmallWordOfTheDay(json: other, date: self.date) {
                        others.append(otherWotd)
                    }
                    
                }
            }
            
        } else {
            return nil
        }
    }
}


