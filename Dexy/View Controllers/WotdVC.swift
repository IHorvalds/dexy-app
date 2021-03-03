//
//  ViewController.swift
//  Dexy
//
//  Created by Tudor Croitoru on 10/02/2021.
//

import UIKit
import Kingfisher
import Alamofire

class WotdVC: UITableViewController {
    
    private let url = "https://dexonline.ro/cuvantul-zilei/##DATE##/json"
    var date: Date = Date()
    private var wordOfTheDay: WordOfTheDay?
    
    private let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "YYYY/MM/dd"
        
        tableView.register(UINib(nibName: "WotdTableViewCell", bundle: nil), forCellReuseIdentifier: "wotdcell")
        tableView.register(UINib(nibName: "SmallWotdTableViewCell", bundle: nil), forCellReuseIdentifier: "smallwotdcell")
        
        update()
    }
    
    private func update() {
        
        let newUrl = url.replacingOccurrences(of: "##DATE##", with: dateFormatter.string(from: self.date))
        
        AF.request(newUrl).response { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
                case .success(let data):
                    if let data = data,
                       let wotd = WordOfTheDay(data: data) {
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            
                            self.wordOfTheDay = wotd
                            self.tableView.reloadData()
                        }
                    }
                case .failure(let error):
                    if self.checkConnectivity() {
                        let alert = UIAlertController(title: "Am dat cu mucii-n fasole...",
                                                      message: "Uite eroarea: \(String(describing: error))",
                                                      preferredStyle: .alert)
                        alert.addAction(.init(title: "Bine", style: .default))
                        self.present(alert, animated: true)
                    } else {
                        let alert = UIAlertController(title: "Nu-ți merge netul",
                                                      message: "Incearcă să pornești WiFi-ul sau datele mobile din setări",
                                                      preferredStyle: .alert)
                        alert.addAction(.init(title: "Haide!", style: .default, handler: { _ in
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }

                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }))
                        alert.addAction(.init(title: "Mai încolo", style: .cancel))
                        self.present(alert, animated: true)
                    }
            }
        }
    }
    
    private func checkConnectivity() -> Bool {
        NetworkReachabilityManager.default?.isReachable ?? false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showdaypickersegue",
           let destVC = segue.destination as? DayPickerViewController {
            destVC.currentDate = self.date
            destVC.delegate = self
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (wordOfTheDay?.others.count ?? 0 > 0) ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            return "Cuvîntul zilei \(dateFormatter.string(from: self.date))"
        } else {
            return "Cuvinte din alți ani"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return wordOfTheDay?.others.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 550.0
        }
        
        return 120.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let wotdCell: WotdTableViewCell = tableView.dequeueReusableCell(withIdentifier: "wotdcell") as! WotdTableViewCell
            
            if let wotd = wordOfTheDay {
                
                // image
                let url = URL(string: wotd.imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                
                wotdCell.wotdImage.kf.indicatorType = .activity
                wotdCell.wotdImage.kf.setImage(
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
                wotdCell.copyrightLabel.attributedText = copyright
                
                // definition
                wotdCell.defTextView.attributedText = wotd.formattedDefinition
                
                // source
                let source = NSMutableAttributedString(string: "Sursa: ", attributes: fieldAttr)
                let sourceName = NSAttributedString(string: wotd.sourceName, attributes: valueAttr)
                source.append(sourceName)
                wotdCell.sourceLabel.attributedText = source
                
                // user
                let addedBy = NSMutableAttributedString(string: "Adăugată de ", attributes: fieldAttr)
                let userNick = NSAttributedString(string: wotd.userNick, attributes: valueAttr)
                addedBy.append(userNick)
                wotdCell.userLabel.attributedText = addedBy
                
                // reason
                wotdCell.reasonTextView.attributedText = wotd.formattedReason
                
            }
            
            return wotdCell
        } else {
            let smallWotdCell: SmallWotdTableViewCell = tableView.dequeueReusableCell(withIdentifier: "smallwotdcell") as! SmallWotdTableViewCell
            
            if let current = wordOfTheDay {
                
                let wotd = current.others[indexPath.row]
                
                let url = URL(string: wotd.imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                
                smallWotdCell.wotdImage.kf.indicatorType = .activity
                smallWotdCell.wotdImage.kf.setImage(
                    with: url,
                    placeholder: UIImage(systemName: "rectangle.and.pencil.and.ellipsis"),
                    options: [
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                    ])
                
                let dateAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10.0, weight: .regular),
                                NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]
                
                let valueAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10.0, weight: .semibold),
                                 NSAttributedString.Key.foregroundColor: UIColor.label]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                
                let dateString = NSMutableAttributedString(string: dateFormatter.string(from: wotd.date) + " ", attributes: dateAttr)
                let wordString = NSAttributedString(string: wotd.word, attributes: valueAttr)
                dateString.append(wordString)
                smallWotdCell.wordLabel.attributedText = dateString
                
                // reason
                smallWotdCell.reasonTextView.attributedText = wotd.formattedReason
            }
            
            return smallWotdCell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1,
           let wotd = wordOfTheDay {
            self.date = wotd.others[indexPath.row].date
            update()
        }
    }
}

extension WotdVC: DayPickerDelegate {
    func didPickDate(date: Date) {
        self.date = date
        self.update()
    }
}

