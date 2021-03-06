//
//  DefinitionLookup.swift
//  Dexy
//
//  Created by Tudor Croitoru on 13/02/2021.
//

import SwiftyJSON
import UIKit

class DefinitionLookup {
    
    struct Definition: Hashable {
        let id: Int
        private let internalRep: String
        let formattedDefinition: NSAttributedString
        let userNick: String
        let sourceName: String
        let createdDate: Date
        let modifiedDate: Date
        var footnotes: [NSRange:String]? = [:]
        
        init?(json: JSON) {
            if let jsonId = json["id"].string,
               let id = Int(jsonId) {
                self.id = id
            } else {
                return nil
            }
            
            if let jsonInternalRep = json["internalRep"].string {
                self.internalRep = jsonInternalRep
                self.formattedDefinition = jsonInternalRep.formatString(baseFont: .systemFont(ofSize: 14.0), footnotes: &footnotes)
            } else {
                return nil
            }
            
            if let jsonUser = json["userNick"].string {
                self.userNick = jsonUser
            } else {
                return nil
            }
            
            if let jsonSource = json["sourceName"].string {
                self.sourceName = jsonSource
            } else {
                return nil
            }
            
            if let jsonCreated = json["createDate"].string,
               let seconds = Double(jsonCreated) {
                self.createdDate = Date(timeIntervalSince1970: seconds)
            } else {
                return nil
            }
            
            if let jsonMod = json["modDate"].string,
               let seconds = Double(jsonMod) {
                self.modifiedDate = Date(timeIntervalSince1970: seconds)
            } else {
                return nil
            }
        }
    }
    
    let id: UUID
    let word: String
    var definitions: [Definition] = []
    
    init?(data: Data) {
        let json = try? JSON(data: data)
        
        if let json = json {
            if let jsonWord = json["word"].string {
                word = jsonWord
            } else {
                return nil
            }
            
            if let jsonDefinitions = json["definitions"].array {
                for def in jsonDefinitions {
                    if let definition = Definition(json: def) {
                        self.definitions.append(definition)
                    }
                }
            } else {
                return nil
            }
            
            self.id = UUID()
            
        } else {
            return nil
        }
    }
}

extension DefinitionLookup {
    private static let _dictionaries = [
        ""                      : "Toate dicționarele",
        "dex09"                 : "(DEX '09) Dicționarul explicativ al limbii române (ediția a II-a revăzută și adăugită)",
        "doom2"                 : "(DOOM 2) Dicționar ortografic, ortoepic și morfologic al limbii române, ediția a II-a revăzută și adăugită",
        "sinonime"              : "(Sinonime) Dicționar de sinonime",
        "das"                   : "(DAS) Dicționar analogic și de sinonime al limbii române",
        "antonime"              : "(Antonime) Dicționar de antonime",
        "dlr"                   : "(DLR) Dicționar al limbii române (Dicționarul Academiei)",
        "dex16"                 : "(DEX '16) Dicționarul explicativ al limbii române (ediția a II-a revăzută și adăugită)",
        "dex12"                 : "(DEX '12) Dicționarul explicativ al limbii române (ediția a II-a revăzută și adăugită)",
        "mda2"                  : "(MDA2) Micul dicționar academic, ediția a II-a",
        "DEXI"                  : "(DEXI) Dicționar explicativ ilustrat al limbii române",
        "dex"                   : "(DEX '98) Dicționarul explicativ al limbii române, ediția a II-a",
        "dex96"                 : "(DEX '96) Dicționarul explicativ al limbii române, ediția a II-a",
        "dexs88"                : "(DEX-S) Supliment la Dicționarul explicativ al limbii române",
        "dex84"                 : "(DEX '84) Dicționarul explicativ al limbii române",
        "dex75"                 : "(DEX '75) Dicționarul explicativ al limbii române",
        "dlrlc"                 : "(DLRLC) Dicționarul limbii romîne literare contemporane",
        "dlrm"                  : "(DLRM) Dicționarul limbii române moderne",
        "mda"                   : "(MDA) Micul dicționar academic",
        "dor"                   : "(DOR) Marele dicționar ortografic al limbii române",
        "do"                    : "(Ortografic) Dicționar ortografic al limbii române",
        "doom"                  : "(DOOM) Dicționar ortografic, ortoepic și morfologic al limbii române",
        "dmlr"                  : "(DMLR) Dictionnaire morphologique de la langue roumaine",
        "intern"                : "(dexonline) Dicționar intern dexonline",
        "DGS"                   : "(DGS) Dicționar General de Sinonime al Limbii Române",
        "Sinonime82"            : "(Sinonime82) Dicționarul de sinonime al limbii române",
        "dn"                    : "(DN) Dicționar de neologisme",
        "mdn08"                 : "(MDN '08) Marele dicționar de neologisme (ediția a 10-a, revăzută, augmentată și actualizată)",
        "mdn00"                 : "(MDN '00) Marele dicționar de neologisme",
        "dcr2"                  : "(DCR2) Dicționar de cuvinte recente, ediția a II-a",
        "dlrc"                  : "(DLRC) Dicționar al limbii române contemporane",
        "der"                   : "(DER) Dicționarul etimologic român",
        "ger"                   : "(GER) Etimologii romînești",
        "gaer"                  : "(GAER) Alte etimologii românești",
        "dei"                   : "(DEI) Dicționar enciclopedic ilustrat",
        "nodex"                 : "(NODEX) Noul dicționar explicativ al limbii române",
        "dlrlv"                 : "(DLRLV) Dicționarul limbii române literare vechi (1640-1780) - Termeni regionali",
        "dar"                   : "(DAR) Dicționar de arhaisme și regionalisme",
        "dsl"                   : "(DSL) Dicționar General de Științe. Științe ale limbii",
        "mitologică"            : "(Mitologic) Mic dicționar mitologic greco-roman",
        "dulr6"                 : "(Șăineanu, ed. VI) Dicționar universal al limbei române, ediția a VI-a",
        "scriban"               : "(Scriban) Dicționaru limbii românești",
        "dgl"                   : "(DGL) Dicționar al greșelilor de limbă",
        "dps"                   : "(Petro-Sedim) Dicționar de termeni – Sedimentologie - Petrologie sedimentară - Sisteme depoziționale",
        "gta"                   : "(GTA) Glosar de termeni aviatici",
        "dge"                   : "(DGE) Dicționar gastronomic explicativ",
        "dtm"                   : "(DTM) Dicționar de termeni muzicali",
        "religios"              : "(D.Religios) Dicționar religios",
        "argou"                 : "(Argou) Dicționar de argou al limbii române",
        "dram15"                : "(DRAM 2015) Dicționar de regionalisme și arhaisme din Maramureș, ediția a doua",
        "dram"                  : "(DRAM) Dicționar de regionalisme și arhaisme din Maramureș",
        "de"                    : "(DE) Dicționar enciclopedic",
        "dtl"                   : "(DTL) Dicționar de termeni lingvistici",
        "dmg"                   : "(DMG) Dicționar de matematici generale",
        "don"                   : "(Onomastic) Dicționar Onomastic Romînesc",
        "CADE"                  : "(CADE) Dicționarul enciclopedic ilustrat",
        "DifSem"                : "(DifSem) Dificultăți semantice",
        "neoficial"             : "(Neoficial) Definiții ale unor cuvinte care nu există în alte dicționare",
        "dendrofloricol"        : "(DFL) Dicționar dendrofloricol",
        "dlra"                  : "(DLRA) Dicționar al limbii române actuale (ediția a II-a revăzută și adăugită)",
        "dets"                  : "(DETS) Dicționar etimologic de termeni științifici",
        "dfs"                   : "(DFS) Dicționarul figurilor de stil",
        "dan"                   : "(DAN) Dicționarul Actualizat de Neologisme",
        "lex"                   : "(Legislație) Legislația României",
        "psi"                   : "(psi) Dicționar de psihologie",
        "mdo"                   : "(MDO) Mic Dicționar Ortografic",
        "dex-scolar"            : "(DEX-școlar) Dicționar explicativ școlar",
        "ivo3"                  : "(IVO-III) Îndreptar și vocabular ortografic (ediția a III-a, revăzută și completată)",
        "meo"                   : "(MEO) Mică Enciclopedie Onomastică",
        "din"                   : "(DIN) Dicționar normativ al limbii române ortografic, ortoepic, morfologic și practic",
        "terminologie-literara" : "(MDTL) Mic dicționar îndrumător în terminologia literară"
    ]
    
    public static let dictionaryUrls: NSOrderedSet = {
        return NSOrderedSet(array: Array(_dictionaries.keys.sorted()))
    }()
    
    public static func dictionaryName(url: String) -> String {
        _dictionaries[url] ?? ""
    }
}
